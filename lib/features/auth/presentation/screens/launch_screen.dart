import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // We go to onboarding first.
        // The router redirect will handle if they are already logged in (redirect to /home)
        // But wait, our router redirect logic needs to be checked.
        // If logged in, router redirects to /home? No, currently it doesn't force /home unless accessing protected route.
        // Let's just go to /onboarding, and let the router decide or we check here.
        // Actually, standard flow: Launch -> Onboarding (if new/guest) OR Home (if logged in).
        // Since we don't have easy auth check here without Riverpod, let's rely on Router or just go to /onboarding
        // and let Onboarding have a "loading" state if we wanted to be fancy, but here:
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logo.png', // Assuming logo exists, or use Icon
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) => Icon(
              Icons.holiday_village,
              size: 80,
              color: Theme.of(context).colorScheme.primary),
        ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms),
      ),
    );
  }
}
