import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// ServiceWave — Intégration Wave Checkout API (compte marchand sénégalais).
//
// Architecture sécurisée : la clé API Wave n'est PAS dans le code Flutter.
// Elle est stockée côté Cloudflare Worker (même pattern que DIALI IA).
//
// Proxy endpoint : https://diali-proxy.sirimambodj.workers.dev/wave-checkout
//
// Flux de paiement :
//   1. App Flutter → POST /wave-checkout (montant + metadata)
//   2. Worker → POST api.wave.com/v1/checkout/sessions (clé Wave côté serveur)
//   3. Worker → retourne { wave_launch_url, checkout_id }
//   4. App → ouvre l'URL Wave via url_launcher (app Wave ou navigateur)
//   5. Wave → deep link retour vers diapaler://premium/success?session_id=...
//   6. App → vérifie le statut via GET /wave-checkout?session_id=...
// ─────────────────────────────────────────────────────────────────────────────

/// Plans d'abonnement DIAPALER PREMIUM.
enum PremiumPlan {
  entrepreneur,
  mentor,
  investisseur;

  String get label => switch (this) {
        PremiumPlan.entrepreneur => 'Entrepreneur Premium',
        PremiumPlan.mentor       => 'Mentor Premium',
        PremiumPlan.investisseur => 'Investisseur Premium',
      };

  /// Montant mensuel en FCFA.
  int get amountXof => switch (this) {
        PremiumPlan.entrepreneur => 7500,
        PremiumPlan.mentor       => 5000,
        PremiumPlan.investisseur => 15000,
      };

  String get amountDisplay => '${amountXof.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]} ',
      )} FCFA / mois';

  List<String> get benefits => switch (this) {
        PremiumPlan.entrepreneur => [
            'Pitch épinglé en tête du fil investisseurs',
            'Badge ⭐ Premium visible dans le Matching',
            'Demandes de mentorat illimitées',
            'Statistiques de vues (profil + pitch)',
            'Accès prioritaire aux mentors certifiés',
          ],
        PremiumPlan.mentor => [
            'Accès aux pitchs complets (filtres avancés)',
            'Badge ✅ Mentor Certifié sur le profil',
            'Outils de suivi des mentorés',
            'Planning prioritaire (créneaux réservés)',
          ],
        PremiumPlan.investisseur => [
            'Pitchs complets + données financières',
            'Filtres avancés (secteur, stade, montant)',
            'Messagerie illimitée avec entrepreneurs',
            'Alertes nouvelles opportunités par secteur',
            'Badge 💎 Investisseur Vérifié',
          ],
      };
}

/// Résultat d'une session de paiement Wave.
class WaveCheckoutResult {
  final String checkoutId;
  final String waveLaunchUrl;  // URL à ouvrir dans l'app Wave ou le navigateur
  const WaveCheckoutResult({
    required this.checkoutId,
    required this.waveLaunchUrl,
  });
}

class WaveService {
  static const _proxyBase =
      'https://diali-proxy.sirimambodj.workers.dev';

  /// Crée une session de checkout Wave pour un abonnement Premium.
  /// Retourne l'URL Wave à ouvrir + l'ID de session pour vérification.
  static Future<WaveCheckoutResult> createCheckout({
    required PremiumPlan plan,
    required String userUid,
    required String userEmail,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_proxyBase/wave-checkout'),
          headers: {'content-type': 'application/json'},
          body: jsonEncode({
            'amount':    plan.amountXof,
            'currency':  'XOF',
            'error_url': 'diapaler://premium/error',
            'success_url': 'diapaler://premium/success',
            'client_reference': userUid,
            'restrict_mobile_money_countries': ['SN'],
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return WaveCheckoutResult(
        checkoutId:    data['id'] as String,
        waveLaunchUrl: data['wave_launch_url'] as String,
      );
    }
    throw Exception('Wave API : ${response.statusCode} — ${response.body}');
  }

  /// Vérifie si une session de paiement a bien été complétée.
  static Future<bool> verifyCheckout(String checkoutId) async {
    final response = await http
        .get(Uri.parse('$_proxyBase/wave-checkout?id=$checkoutId'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['payment_status'] == 'succeeded';
    }
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WavePremiumSheet — Bottom sheet d'abonnement Premium.
// S'affiche quand l'utilisateur clique sur un contenu Premium verrouillé.
// ─────────────────────────────────────────────────────────────────────────────

class WavePremiumSheet extends StatefulWidget {
  final PremiumPlan plan;
  const WavePremiumSheet({super.key, required this.plan});

  static Future<bool?> show(BuildContext context, PremiumPlan plan) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WavePremiumSheet(plan: plan),
    );
  }

  @override
  State<WavePremiumSheet> createState() => _WavePremiumSheetState();
}

class _WavePremiumSheetState extends State<WavePremiumSheet> {
  bool _loading = false;

  Future<void> _subscribe() async {
    setState(() => _loading = true);
    try {
      final result = await WaveService.createCheckout(
        plan: widget.plan,
        userUid: 'uid_placeholder',   // à remplacer par AuthService.currentUid
        userEmail: '',
      );
      if (!mounted) return;
      // Ouvre l'URL Wave (app Wave ou navigateur)
      Navigator.of(context).pop();
      // L'URL est gérée par page_wave_checkout.dart
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => WaveCheckoutPage(
          plan: widget.plan,
          checkoutResult: result,
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poignée
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Titre
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 24),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(plan.label,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0A1628))),
              Text(plan.amountDisplay,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ]),
          ]),
          const SizedBox(height: 20),
          // Avantages
          ...plan.benefits.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(b, style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155)))),
            ]),
          )),
          const SizedBox(height: 20),
          // Bouton Wave
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _subscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1BA9FF), // Bleu Wave
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.waves_rounded),
              label: Text(
                _loading ? 'Connexion Wave…' : 'Payer avec Wave — ${plan.amountDisplay}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Paiement sécurisé · Wave Sénégal · Résiliable à tout moment',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WaveCheckoutPage — WebView de confirmation du paiement Wave.
// ─────────────────────────────────────────────────────────────────────────────

class WaveCheckoutPage extends StatefulWidget {
  final PremiumPlan plan;
  final WaveCheckoutResult checkoutResult;
  const WaveCheckoutPage({super.key, required this.plan, required this.checkoutResult});

  @override
  State<WaveCheckoutPage> createState() => _WaveCheckoutPageState();
}

class _WaveCheckoutPageState extends State<WaveCheckoutPage> {
  bool _verifying = false;
  bool? _success;

  Future<void> _verify() async {
    setState(() => _verifying = true);
    try {
      final ok = await WaveService.verifyCheckout(widget.checkoutResult.checkoutId);
      setState(() => _success = ok);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Abonnement ${widget.plan.label}'),
        backgroundColor: const Color(0xFF1BA9FF),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _success == null
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                // QR Code / lien Wave
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1BA9FF).withValues(alpha: 0.3)),
                  ),
                  child: Column(children: [
                    const Icon(Icons.waves_rounded, color: Color(0xFF1BA9FF), size: 48),
                    const SizedBox(height: 12),
                    const Text('Ouvrez l\'application Wave', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('Montant : ${widget.plan.amountDisplay}',
                        style: const TextStyle(color: Color(0xFF64748B))),
                    const SizedBox(height: 16),
                    // Lien de paiement cliquable
                    SelectableText(
                      widget.checkoutResult.waveLaunchUrl,
                      style: const TextStyle(color: Color(0xFF1BA9FF), fontSize: 12),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _verifying ? null : _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                    ),
                    child: _verifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('J\'ai payé — Vérifier', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ])
            : _success!
              ? Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 72),
                  const SizedBox(height: 16),
                  const Text('Paiement confirmé !', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text('Votre compte Premium est activé.', style: TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    child: const Text('Retour à l\'accueil'),
                  ),
                ])
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_rounded, color: Colors.red, size: 72),
                  const SizedBox(height: 16),
                  const Text('Paiement non confirmé', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Réessaie ou contacte le support Wave.', style: TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _verify,
                    child: const Text('Réessayer'),
                  ),
                ]),
        ),
      ),
    );
  }
}
