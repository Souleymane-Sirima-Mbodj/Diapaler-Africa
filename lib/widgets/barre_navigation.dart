import 'package:flutter/material.dart';
import '../services/service_notifications.dart';
import '../theme/theme_app.dart';

class DiapalerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DiapalerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = <_NavItem>[
    _NavItem(
      icon: Icons.home_outlined,
      active: Icons.home_rounded,
      label: 'Accueil',
    ),
    _NavItem(
      icon: Icons.handshake_outlined,
      active: Icons.handshake_rounded,
      label: 'Matching',
    ),
    _NavItem(
      icon: Icons.chat_bubble_outline_rounded,
      active: Icons.chat_bubble_rounded,
      label: 'Messages',
    ),
    _NavItem(
      icon: Icons.event_outlined,
      active: Icons.event_rounded,
      label: 'Agenda',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      active: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<NotificationItem>>(
      valueListenable: NotificationService.notifications,
      builder: (context, notifs, _) {
        final unreadCount = notifs.where((n) => !n.isRead).length;
        return Material(
          color: Colors.white,
          elevation: 8,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_items.length, (i) {
                  return Expanded(
                    child: _NavButton(
                      item: _items[i],
                      selected: currentIndex == i,
                      badge: i == 0 ? unreadCount : 0,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navy : AppColors.muted;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.blueTint.withValues(alpha: 0.6)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    selected ? item.active : item.icon,
                    color: color,
                    size: 22,
                  ),
                  if (badge > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            badge > 9 ? '9+' : '$badge',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  color: color,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData active;
  final String label;
  const _NavItem({
    required this.icon,
    required this.active,
    required this.label,
  });
}
