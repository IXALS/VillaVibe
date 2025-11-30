import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:villavibe/features/guest/presentation/screens/guest_home_screen.dart';
import 'package:villavibe/features/host/presentation/providers/host_mode_provider.dart';
import 'package:villavibe/features/host/presentation/screens/dashboard/host_main_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isHostMode = ref.watch(hostModeProvider);

    if (isHostMode) {
      return const HostMainScreen();
    }

    // We don't block the UI if user is null, we just show GuestHomeScreen
    // The modal will pop up on top.
    return GuestHomeScreen(initialIndex: widget.initialIndex);
  }
}
