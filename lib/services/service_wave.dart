import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/service_base_de_donnees.dart';
import '../services/service_authentification.dart';
import '../data/profil_utilisateur.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ServiceWave — Paiement Premium via lien marchand Wave.
//
// Lien marchand : https://pay.wave.com/m/M_sn_tH1ZQo00ZVko/c/sn/
// Le paramètre ?amount=XXXX ajoute le montant dynamiquement.
//
// Flux de paiement :
//   1. App Flutter → construit l'URL Wave avec le montant
//   2. url_launcher → ouvre l'app Wave (ou le navigateur)
//   3. Utilisateur paie dans Wave
//   4. Revient dans l'app → confirme en tapant "J'ai payé"
//   5. Firebase → nœud users/{uid}/premium = true
//
// Note : en production, une vérification webhook côté serveur serait ajoutée.
// ─────────────────────────────────────────────────────────────────────────────

const _waveBaseUrl = 'https://pay.wave.com/m/M_sn_tH1ZQo00ZVko/c/sn/';

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

  String get amountDisplay {
    final s = amountXof.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '$buf FCFA / mois';
  }

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

  /// URL Wave avec montant pré-rempli.
  String get waveUrl =>
      '$_waveBaseUrl?amount=$amountXof'
      '&label=Abonnement+Premium+DIAPALER+AFRICA';
}

class WaveService {
  /// Ouvre l'URL Wave (app ou navigateur).
  static Future<void> openPayment(PremiumPlan plan) async {
    final uri = Uri.parse(plan.waveUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Impossible d\'ouvrir Wave. Vérifie que l\'app Wave est installée.');
    }
  }

  /// Marque l'utilisateur Premium dans Firebase ET met à jour le profil en mémoire.
  static Future<void> activatePremium(PremiumPlan plan) async {
    final uid = AuthService.currentUid;
    if (uid == null) return;
    // 1. Persistance Firebase
    await DatabaseService.setPremium(uid: uid, plan: plan.name);
    // 2. Mise à jour immédiate en mémoire → badge visible instantanément
    final updated = UserProfileController.profile.value.copyWith(
      isPremium: true,
      premiumPlan: plan.name,
    );
    UserProfileController.update(updated);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WavePremiumSheet — Bottom sheet d'abonnement Premium.
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
  // Étape : false = avant paiement, true = après retour de Wave
  bool _waitingConfirmation = false;
  bool _activating = false;

  Future<void> _openWave() async {
    try {
      await WaveService.openPayment(widget.plan);
      // Après retour de Wave, on passe en mode confirmation
      if (mounted) setState(() => _waitingConfirmation = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _confirmPayment() async {
    setState(() => _activating = true);
    try {
      await WaveService.activatePremium(widget.plan);
      if (!mounted) return;
      Navigator.of(context).pop(true); // retourne true = Premium activé
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('🌟 Compte Premium activé ! Merci.'),
        backgroundColor: Color(0xFF22C55E),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur activation : $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _activating = false);
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
              child: const Icon(Icons.star_rounded,
                  color: Color(0xFFF59E0B), size: 24),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(plan.label,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0A1628))),
              Text(plan.amountDisplay,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600)),
            ]),
          ]),
          const SizedBox(height: 20),

          // Avantages
          ...plan.benefits.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF22C55E), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(b,
                          style: const TextStyle(
                              fontSize: 13.5, color: Color(0xFF334155)))),
                ]),
              )),

          const SizedBox(height: 20),

          // Bouton principal
          if (!_waitingConfirmation) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _openWave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BA9FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.waves_rounded),
                label: Text(
                  'Payer avec Wave — ${plan.amountDisplay}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
          ] else ...[
            // Après retour de Wave
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
              ),
              child: const Row(children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: Color(0xFF22C55E), size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Paiement effectué sur Wave ?\nClique ci-dessous pour activer ton compte.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF166534)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _activating ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: _activating
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.verified_rounded),
                label: Text(
                  _activating ? 'Activation…' : 'Oui, j\'ai payé — Activer Premium',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => setState(() => _waitingConfirmation = false),
                child: const Text('← Revenir au paiement',
                    style: TextStyle(color: Color(0xFF64748B))),
              ),
            ),
          ],

          const SizedBox(height: 8),
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
