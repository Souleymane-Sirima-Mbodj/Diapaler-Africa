import 'package:flutter/material.dart';
import '../data/interactions.dart';
import '../services/service_authentification.dart';
import '../services/service_interactions.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import '../widgets/carte_lumineuse.dart';
import 'page_chat.dart';

// ─────────────────────────────────────────────────────────────────
// Onglet Messages — liste Firebase des conversations en temps réel.
// ─────────────────────────────────────────────────────────────────

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String _search = '';

  static const _colors = <Color>[
    AppColors.amber,
    AppColors.blue,
    AppColors.green,
    AppColors.purple,
    AppColors.navy,
  ];

  Color _colorFor(int index) => _colors[index % _colors.length];

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (now.year == dt.year && now.month == dt.month && now.day == dt.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.year == dt.year &&
        yesterday.month == dt.month &&
        yesterday.day == dt.day) {
      return 'Hier';
    }
    if (now.difference(dt).inDays < 7) {
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[dt.weekday - 1];
    }
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = AuthService.currentUid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<List<Conversation>>(
        stream: InteractionsService.getConversations(currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur de chargement.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
            );
          }

          final all = snapshot.data ?? [];
          final filtered = _search.isEmpty
              ? all
              : all.where((c) {
                  final otherName = c.user1Id == currentUid
                      ? c.user2Name
                      : c.user1Name;
                  return otherName
                      .toLowerCase()
                      .contains(_search.toLowerCase());
                }).toList();

          final unreadTotal =
              all.fold<int>(0, (sum, c) => sum + c.unreadCount);

          return Column(
            children: [
              if (all.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded,
                          size: 20, color: AppColors.subtle),
                      hintText: 'Rechercher une conversation…',
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                if (unreadTotal > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$unreadTotal non lu${unreadTotal > 1 ? "s" : ""}',
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
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(hasSearch: _search.isNotEmpty)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final conv = filtered[i];
                          final otherName = conv.user1Id == currentUid
                              ? conv.user2Name
                              : conv.user1Name;
                          final otherId = conv.user1Id == currentUid
                              ? conv.user2Id
                              : conv.user1Id;
                          final unread = conv.unreadCount > 0;

                          return HoverGlowCard(
                            padding: const EdgeInsets.all(12),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  conversationId: conv.id,
                                  otherUserName: otherName,
                                  otherUserId: otherId,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Avatar(
                                  initials: _initials(otherName),
                                  size: 50,
                                  background: _colorFor(i),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              otherName,
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
                                            _formatTime(conv.lastMessageTime),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: unread
                                                  ? AppColors.amber
                                                  : AppColors.subtle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              conv.lastMessage,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                height: 1.3,
                                                color: unread
                                                    ? AppColors.navyDeep
                                                    : AppColors.muted,
                                                fontWeight: unread
                                                    ? FontWeight.w700
                                                    : FontWeight.w400,
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
                                                '${conv.unreadCount}',
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
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  const _EmptyState({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.blueTint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 36, color: AppColors.blue),
            ),
            const SizedBox(height: 18),
            Text(
              hasSearch ? 'Aucun résultat' : 'Aucune conversation',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDeep,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Essaie un autre nom.'
                  : 'Tes échanges avec les mentors\napparaîtront ici automatiquement.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
