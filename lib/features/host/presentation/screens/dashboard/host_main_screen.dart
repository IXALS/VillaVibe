import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/host/presentation/screens/dashboard/tabs/host_calendar_tab.dart';
import 'package:villavibe/features/host/presentation/screens/dashboard/tabs/host_inbox_tab.dart';
import 'package:villavibe/features/host/presentation/screens/dashboard/tabs/host_listings_tab.dart';
import 'package:villavibe/features/host/presentation/screens/dashboard/tabs/host_menu_tab.dart';
import 'package:villavibe/features/host/presentation/screens/dashboard/tabs/host_today_tab.dart';

class HostMainScreen extends ConsumerStatefulWidget {
  const HostMainScreen({super.key});

  @override
  ConsumerState<HostMainScreen> createState() => _HostMainScreenState();
}

class _HostMainScreenState extends ConsumerState<HostMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HostTodayTab(),
    HostCalendarTab(),
    HostListingsTab(),
    HostInboxTab(),
    HostMenuTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.02),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _tabs[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(LucideIcons.layoutDashboard, 'Today', 0),
                _buildNavItem(LucideIcons.calendar, 'Calendar', 1),
                _buildNavItem(LucideIcons.list, 'Listings', 2),
                _buildNavItem(LucideIcons.messageSquare, 'Inbox', 3),
                _buildNavItem(LucideIcons.menu, 'Menu', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final activeColor = const Color(0xFFE91E63);
    final inactiveColor = Colors.grey[600];

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? activeColor : inactiveColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : inactiveColor,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
