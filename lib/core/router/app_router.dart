import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:villavibe/features/auth/presentation/screens/launch_screen.dart';
import 'package:villavibe/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:villavibe/features/auth/presentation/screens/login_screen.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';

import 'package:villavibe/features/properties/presentation/screens/host_dashboard_screen.dart';
import 'package:villavibe/features/properties/presentation/screens/host_property_form.dart';
import 'package:villavibe/features/home/presentation/screens/home_screen.dart';
import 'package:villavibe/features/guest/presentation/screens/villa_detail_screen.dart';
import 'package:villavibe/features/bookings/presentation/screens/booking_message_screen.dart';
import 'package:villavibe/features/bookings/presentation/screens/booking_payment_screen.dart';
import 'package:villavibe/features/bookings/presentation/screens/booking_review_screen.dart';
import 'package:villavibe/features/bookings/presentation/screens/booking_success_screen.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable:
        GoRouterRefreshStream(ref.watch(authStateProvider.stream)),
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.uri.toString() == '/login';
      final isLaunch = state.uri.toString() == '/';
      final isOnboarding = state.uri.toString() == '/onboarding';

      // Protected routes that require login
      final isHostRoute = state.uri.toString().startsWith('/host') ||
          state.uri.toString() == '/add-property';
      final isBookingRoute = state.uri.toString().startsWith('/booking');

      if (isLaunch) return null;
      if (isOnboarding) return null;

      if (!isLoggedIn) {
        if (isHostRoute || isBookingRoute) {
          return '/home';
        }
      }

      // If logged in and on login page or onboarding page, go home
      if (isLoggedIn && (isLoggingIn || isOnboarding)) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LaunchScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add-property',
        builder: (context, state) => const HostPropertyForm(),
      ),
      GoRoute(
        path: '/host-dashboard',
        builder: (context, state) => const HostDashboardScreen(),
      ),
      GoRoute(
        path: '/property/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VillaDetailScreen(propertyId: id);
        },
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) {
          final property = state.extra as Property?;
          if (property == null) {
            return const Scaffold(
                body: Center(child: Text('Error: Property data missing')));
          }
          return BookingReviewScreen(property: property);
        },
        routes: [
          GoRoute(
            path: 'payment',
            builder: (context, state) {
              final property = state.extra as Property?;
              if (property == null) {
                return const Scaffold(
                    body: Center(child: Text('Error: Property data missing')));
              }
              return BookingPaymentScreen(property: property);
            },
          ),
          GoRoute(
            path: 'message',
            builder: (context, state) {
              final property = state.extra as Property?;
              if (property == null) {
                return const Scaffold(
                    body: Center(child: Text('Error: Property data missing')));
              }
              return BookingMessageScreen(property: property);
            },
          ),
          GoRoute(
            path: 'success',
            builder: (context, state) => const BookingSuccessScreen(),
          ),
        ],
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
