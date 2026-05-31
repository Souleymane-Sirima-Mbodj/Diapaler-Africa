import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../data/interactions.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_interactions.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import '../widgets/carte_lumineuse.dart';
import 'page_chat.dart';
import 'page_detail_mentor.dart';

// ─────────────────────────────────────────────────────────────────
// Onglet Messages — deux onglets : Contacts (relations acceptées)
// et Messages (conversations existantes).
// ─────────────────────────────────────────────────────────────────

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _contactSearch = '';
  String _msgSearch = '';

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
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Onglet Contacts ─────────────────────────────────────────────

  Widget _buildContactsTab() {
    final currentUid = AuthService.currentUid ?? '';

    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('mentorRequests').onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.snapshot.value as Map?;
        final contacts = <_Contact>[];

        if (data != null) {
          for (final entry in data.entries) {
            final v = entry.value;
            if (v is! Map) continue;
            final m = Map<String, dynamic>.from(v);
            if (m['status'] != 'accepted') continue;

            final fromId = m['fromUserId']?.toString() ?? '';
            final toId = m['toUserId']?.toString() ?? '';
            final type = m['type']?.toString() ?? 'mentor';

            if (fromId == currentUid) {
              contacts.add(_Contact(
                uid: toId,
                name: m['toName']?.toString() ?? 'Contact',
                type: type,
                isInitiator: true,
              ));
            } else if (toId == currentUid) {
              contacts.add(_Contact(
                uid: fromId,
                name: m['fromName']?.toString() ?? 'Contact',
                type: type,
                isInitiator: false,
              ));
            }
          }
        }

        // Dédupliquer par uid
        final seen = <String>{};
        final unique = contacts.where((c) => seen.add(c.uid)).toList();

        // Filtrer par recherche
        final filtered = _contactSearch.isEmpty
            ? unique
            : unique
                .where((c) => c.name
                    .toLowerCase()
                    .contains(_contactSearch.toLowerCase()))
                .toList();

        return Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                onChanged: (v) => setState(() => _contactSearch = v),
                decoration: const InputDecoration(
                  prefixIcon:
                      Icon(Icons.search_rounded, color: AppColors.subtle),
                  hintText: 'Rechercher un contact…',
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            if (unique.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${filtered.length} contact${filtered.length > 1 ? "s" : ""}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_outline_rounded,
                                size: 56, color: AppColors.subtle),
                            const SizedBox(height: 12),
                            Text(
                              unique.isEmpty
                                  ? 'Aucun contact pour l\'instant.\nEnvoie une demande de mentorat ou d\'investissement pour commencer.'
                                  : 'Aucun contact ne correspond à ta recherche.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 13,
                                  height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _ContactCard(
                        contact: filtered[i],
                        currentUid: currentUid,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  // ── Onglet Messages ─────────────────────────────────────────────

  Widget _buildMessagesTab() {
    final currentEmail = UserProfileController.profile.value.email;

    return StreamBuilder<List<Conversation>>(
      stream: InteractionsService.getConversations(currentEmail),
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
        final filtered = _msgSearch.isEmpty
            ? all
            : all.where((c) {
                final otherName = c.user1Id == currentEmail
                    ? c.user2Name
                    : c.user1Name;
                return otherName
                    .toLowerCase()
                    .contains(_msgSearch.toLowerCase());
              }).toList();

        final currentUid = AuthService.currentUid ?? '';
        final unreadTotal = all
            .where((c) => c.lastSenderId != currentUid)
            .fold<int>(0, (sum, c) => sum + c.unreadCount);

        return Column(
          children: [
            if (all.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: TextField(
                  onChanged: (v) => setState(() => _msgSearch = v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded,
                        size: 20, color: AppColors.subtle),
                    hintText: 'Rechercher une conversation…',
                    contentPadding: EdgeInsets.zero,
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
                  ? _EmptyState(hasSearch: _msgSearch.isNotEmpty)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final conv = filtered[i];
                        final otherName = conv.user1Id == currentEmail
                            ? conv.user2Name
                            : conv.user1Name;
                        final otherId = conv.user1Id == currentEmail
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
                              GestureDetector(
                                onLongPress: () {
                                  final found = mentors.where(
                                    (m) =>
                                        m.name == otherName ||
                                        m.uid == otherId,
                                  );
                                  if (found.isNotEmpty) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => MentorDetailPage(
                                            mentor: found.first),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Profil de $otherName non disponible.'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                child: Avatar(
                                  initials: _initials(otherName),
                                  size: 50,
                                  background: _colorFor(i),
                                ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(icon: Icon(Icons.people_rounded, size: 20), text: 'Contacts'),
            Tab(
                icon: Icon(Icons.chat_bubble_outline_rounded, size: 20),
                text: 'Messages'),
          ],
          labelColor: AppColors.navyDeep,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.amber,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildContactsTab(),
          _buildMessagesTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Modèle Contact
// ─────────────────────────────────────────────────────────────────

class _Contact {
  final String uid;
  final String name;
  final String type; // 'mentor' | 'investment'
  final bool isInitiator; // true si c'est moi qui ai initié la demande

  const _Contact({
    required this.uid,
    required this.name,
    required this.type,
    required this.isInitiator,
  });

  String get roleLabel {
    if (type == 'mentor') {
      return isInitiator ? 'Mon mentor' : 'Mon mentoré';
    } else {
      return isInitiator ? 'Mon investisseur' : 'Mon entrepreneur';
    }
  }

  Color get roleColor {
    if (type == 'investment' && !isInitiator) return AppColors.amber; // Entrepreneur
    if (type == 'mentor' && !isInitiator) return AppColors.roleMentor; // Mentoré
    if (type == 'mentor') return AppColors.roleMentor; // Mentor
    return AppColors.blue; // Investisseur
  }
}

// ─────────────────────────────────────────────────────────────────
// Carte Contact
// ─────────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final _Contact contact;
  final String currentUid;
  const _ContactCard({required this.contact, required this.currentUid});

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return HoverGlowCard(
      onTap: () {
        final convId =
            InteractionsService.generateConversationId(currentUid, contact.uid);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              conversationId: convId,
              otherUserName: contact.name,
              otherUserId: contact.uid,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Avatar(
            initials: _initials(contact.name),
            size: 48,
            background: contact.roleColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDeep),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: contact.roleColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    contact.roleLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: contact.roleColor),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.fieldBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 18, color: AppColors.navy),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// État vide (onglet Messages)
// ─────────────────────────────────────────────────────────────────

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
