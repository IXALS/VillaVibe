import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_repository.g.dart';

class OnboardingRepository {
  final SharedPreferences _prefs;
  static const _keyOnboardingCompleted = 'onboarding_completed';

  OnboardingRepository(this._prefs);

  bool get isOnboardingCompleted =>
      _prefs.getBool(_keyOnboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(_keyOnboardingCompleted, true);
  }
}

@riverpod
OnboardingRepository onboardingRepository(OnboardingRepositoryRef ref) {
  throw UnimplementedError(); // Override in main.dart
}
