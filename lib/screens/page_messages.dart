import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import '../widgets/carte_lumineuse.dart';

// ─────────────────────────────────────────────────────────────────
// Onglet Messages — liste des conversations avec les mentors.
// Toucher une conversation ouvre le fil de discussion.
// ─────────────────────────────────────────────────────────────────

/// Conversation entre l'utilisateur et un mentor.
class _Conversation {
  final Mentor mentor;
  final String lastMessage;
  final String time;
  final int unread;
  final bool online;
  final Color color;

  const _Conversation({
    required this.mentor,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.online,
    required this.color,
  });
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  /// Conversations de démonstration, basées sur les mentors de la plateforme.
  static final List<_Conversation> _conversations = [
    _Conversation(
      mentor: mentors[3], // Babacar Ngom
      lastMessage: 'Parfait, je t\'envoie le document avant jeudi.',
      time: '09:24',
      unread: 0,
      online: true,
      color: AppColors.amber,
    ),
    _Conversation(
      mentor: mentors[5], // Aminata Niane
      lastMessage: 'Ton idée de marketplace est très prometteuse !',
      time: 'Hier',
      unread: 2,
      online: true,
      color: AppColors.blue,
    ),
    _Conversation(
      mentor: mentors[0], // Anta Diama Kama
      lastMessage: 'On se cale une session la semaine prochaine ?',
      time: 'Hier',
      unread: 0,
      online: false,
      color: AppColors.green,
    ),
    _Conversation(
      mentor: mentors[1], // Yérim Habib Sow
      lastMessage: 'Merci pour ton message, je reviens vers toi vite.',
      time: 'Lun',
      unread: 0,
      online: false,
      color: AppColors.purple,
    ),
    _Conversation(
      mentor: mentors[4], // Mossane Diop
      lastMessage: 'Bravo pour ton avancement sur le projet !',
      time: '12 mai',
      unread: 0,
      online: false,
      color: AppColors.roleEntrepreneur,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadTotal =
        _conversations.fold<int>(0, (sum, c) => sum + c.unread);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          if (unreadTotal > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$unreadTotal non lus',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.amber,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
        itemCount: _conversations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _ConversationTile(
          conversation: _conversations[i],
        ),
      ),
    );
  }
}

/// Ligne de la liste représentant une conversation.
class _ConversationTile extends StatelessWidget {
  final _Conversation conversation;
  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final unread = c.unread > 0;

    return HoverGlowCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _ConversationView(conversation: c)),
      ),
      child: Row(
        children: [
          Avatar(
            initials: c.mentor.initials,
            size: 50,
            background: c.color,
            online: c.online,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.mentor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyDeep,
                        ),
                      ),
                    ),
                    Text(
                      c.time,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: unread ? AppColors.amber : AppColors.subtle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.3,
                          color: unread
                              ? AppColors.navyDeep
                              : AppColors.muted,
                          fontWeight:
                              unread ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (unread) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${c.unread}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Fil de discussion — bulles + champ de saisie fonctionnel.
// ─────────────────────────────────────────────────────────────────

/// Un message du fil de discussion.
class _Msg {
  final String text;
  final bool mine;
  final String time;
  const _Msg({required this.text, required this.mine, required this.time});
}

class _ConversationView extends StatefulWidget {
  final _Conversation conversation;
  const _ConversationView({required this.conversation});

  @override
  State<_ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<_ConversationView> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late final List<_Msg> _messages;

  @override
  void initState() {
    super.initState();
    // Fil de discussion de démonstration.
    _messages = [
      const _Msg(
        text: 'Bonjour ! J\'ai bien reçu ta demande de mentorat.',
        mine: false,
        time: '09:02',
      ),
      const _Msg(
        text: 'Bonjour, merci beaucoup d\'avoir accepté !',
        mine: true,
        time: '09:05',
      ),
      const _Msg(
        text: 'Avec plaisir. Parle-moi un peu de ton projet, je t\'écoute.',
        mine: false,
        time: '09:06',
      ),
      const _Msg(
        text:
            'C\'est une plateforme qui met en relation les producteurs '
            'locaux et les restaurateurs de Dakar.',
        mine: true,
        time: '09:09',
      ),
      const _Msg(
        text: 'Parfait, je t\'envoie le document avant jeudi.',
        mine: false,
        time: '09:24',
      ),
    ];
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text, mine: true, time: 'Maintenant'));
      _inputCtrl.clear();
    });
    // Défile vers le dernier message après le rendu.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conversation;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Avatar(
              initials: c.mentor.initials,
              size: 38,
              background: c.color,
              online: c.online,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.mentor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDeep,
                    ),
                  ),
                  Text(
                    c.online ? 'En ligne' : 'Hors ligne',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: c.online ? AppColors.green : AppColors.subtle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _Bubble(message: _messages[i]),
            ),
          ),
          _InputBar(controller: _inputCtrl, onSend: _send),
        ],
      ),
    );
  }
}

/// Bulle d'un message, stylisée selon l'expéditeur.
class _Bubble extends StatelessWidget {
  final _Msg message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.74,
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: mine ? AppColors.navy : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(mine ? 16 : 4),
                  bottomRight: Radius.circular(mine ? 4 : 16),
                ),
                border: mine
                    ? null
                    : Border.all(color: AppColors.border),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: mine ? Colors.white : AppColors.navyDeep,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            message.time,
            style: const TextStyle(fontSize: 10, color: AppColors.subtle),
          ),
        ],
      ),
    );
  }
}

/// Barre de saisie d'un message en bas du fil de discussion.
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Écris ton message…',
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.navy,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
