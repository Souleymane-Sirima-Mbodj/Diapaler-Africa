import 'dart:math';
import 'package:flutter/material.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_chatbot.dart';
import '../theme/theme_app.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage>
    with TickerProviderStateMixin {
  final _messages = <ChatbotMessage>[];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _loading = false;
  bool _hasKey = false;
  late AnimationController _dotCtrl;

  static const _welcome =
      'Salut ! Je suis **DIALI**, ton assistant entrepreneurial IA de DIAPALER AFRICA. 🇸🇳\n\n'
      'Je peux t\'aider avec :\n'
      '• 💼 Ta stratégie business\n'
      '• 💰 DER/FJ, PAVIE 2, Be Yes (financement)\n'
      '• 🎯 La préparation de ton pitch\n'
      '• 🤝 Trouver mentors et investisseurs\n\n'
      '**Pose-moi ta question — *Jërejëf* !**';

  @override
  void initState() {
    super.initState();
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _checkApiKey();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkApiKey() async {
    final key = await ChatbotService.getApiKey();
    if (!mounted) return;
    if (key == null || key.isEmpty) {
      await _showKeySetup(canCancel: true);
    } else {
      setState(() => _hasKey = true);
    }
  }

  Future<void> _showKeySetup({bool canCancel = false}) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: canCancel,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.psychology_rounded, color: AppColors.blue, size: 22),
            SizedBox(width: 10),
            Text(
              'Activer DIALI IA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDeep,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.blueTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'DIALI utilise l\'API Anthropic (Claude). Obtiens une clé gratuite sur console.anthropic.com puis colle-la ci-dessous.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.navy,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'sk-ant-api03-…',
                prefixIcon: const Icon(
                  Icons.key_rounded,
                  size: 18,
                  color: AppColors.subtle,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (canCancel)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Annuler'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Enregistrer',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    ctrl.dispose();
    if (!mounted) return;

    if (result != null && result.isNotEmpty) {
      await ChatbotService.saveApiKey(result);
      setState(() => _hasKey = true);
    } else if (!_hasKey) {
      Navigator.of(context).pop();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;

    final profile = UserProfileController.profile.value;
    _ctrl.clear();

    setState(() {
      _messages.add(ChatbotMessage(role: 'user', content: text));
      _loading = true;
    });
    _scrollToBottom();

    try {
      final reply = await ChatbotService.sendMessage(
        messages: _messages,
        userName: profile.firstName,
        userRole: profile.role,
        userSector: profile.sector,
        userCity: profile.city,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(ChatbotMessage(role: 'assistant', content: reply));
      });
      _scrollToBottom();
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg == 'no_key') {
        await _showKeySetup(canCancel: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // On retire le message utilisateur si l'envoi a échoué
        setState(() => _messages.removeLast());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.navyDeep,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: AppColors.navyDeep,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DIALI IA',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'Assistant entrepreneurial DIAPALER',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showKeySetup(canCancel: true),
            icon: const Icon(Icons.settings_rounded, size: 20),
            tooltip: 'Changer la clé API',
          ),
        ],
      ),
      body: !_hasKey
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                    children: [
                      const _AiMessage(text: _welcome),
                      ..._messages.map((m) => m.role == 'user'
                          ? _UserMessage(text: m.content)
                          : _AiMessage(text: m.content)),
                      if (_loading) _TypingIndicator(controller: _dotCtrl),
                    ],
                  ),
                ),
                _InputBar(
                  controller: _ctrl,
                  loading: _loading,
                  onSend: _send,
                ),
              ],
            ),
    );
  }
}

// ── Bulle utilisateur ─────────────────────────────────────────────

class _UserMessage extends StatelessWidget {
  final String text;
  const _UserMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.navyDeep, AppColors.blue],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(3),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

// ── Bulle DIALI ───────────────────────────────────────────────────

class _AiMessage extends StatelessWidget {
  final String text;
  const _AiMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              color: AppColors.amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: AppColors.navyDeep,
              size: 17,
            ),
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12, right: 40),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _FormattedText(text: text),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rendu markdown minimal (**gras**, *italique*) ─────────────────

class _FormattedText extends StatelessWidget {
  final String text;
  const _FormattedText({required this.text});

  static final _pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|([^*]+)', dotAll: true);

  List<TextSpan> _parse(String raw) {
    final spans = <TextSpan>[];
    for (final m in _pattern.allMatches(raw)) {
      if (m.group(1) != null) {
        spans.add(TextSpan(
          text: m.group(1),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.navyDeep,
          ),
        ));
      } else if (m.group(2) != null) {
        spans.add(TextSpan(
          text: m.group(2),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else {
        spans.add(TextSpan(text: m.group(3)));
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13.5,
          color: AppColors.navyDeep,
          height: 1.55,
        ),
        children: _parse(text),
      ),
    );
  }
}

// ── Indicateur de frappe (3 points animés) ───────────────────────

class _TypingIndicator extends StatelessWidget {
  final AnimationController controller;
  const _TypingIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              color: AppColors.amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: AppColors.navyDeep,
              size: 17,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(3),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, __) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final phase = (controller.value * 2 * pi) - (i * pi / 2.5);
                    final scale = 0.6 + 0.4 * ((sin(phase) + 1) / 2);
                    return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.muted,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Barre de saisie ───────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSend;
  const _InputBar({
    required this.controller,
    required this.loading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Pose ta question à DIALI…',
                  hintStyle: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.subtle,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide:
                        const BorderSide(color: AppColors.blue, width: 1.5),
                  ),
                  filled: true,
                  fillColor: AppColors.fieldBg,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: loading ? AppColors.border : AppColors.navyDeep,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: loading ? null : onSend,
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.muted,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
