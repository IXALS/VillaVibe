import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/data/repositories/onboarding_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      onboardingRepositoryProvider
          .overrideWithValue(OnboardingRepository(prefs)),
    ],
    child: const VillaVibeApp(),
  ));
}

class VillaVibeApp extends ConsumerWidget {
  const VillaVibeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'VillaVibe',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
