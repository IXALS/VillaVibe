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
import 'package:villavibe/features/home/presentation/screens/destination_detail_screen.dart';
import 'package:villavibe/features/bookings/presentation/screens/booking_flow_wrapper.dart';
import 'package:villavibe/features/bookings/presentation/screens/booking_success_screen.dart';
import 'package:villavibe/features/bookings/presentation/screens/qris_payment_screen.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/messages/presentation/screens/chat_list_screen.dart';
import 'package:villavibe/features/messages/presentation/screens/chat_room_screen.dart';


part 'app_router.g.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    observers: [routeObserver],
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
        builder: (context, state) {
          final initialIndex = state.extra as int? ?? 0;
          return HomeScreen(initialIndex: initialIndex);
        },
      ),
      GoRoute(
        path: '/add-property',
        builder: (context, state) => const HostPropertyForm(),
      ),
      GoRoute(
        path: '/host-dashboard',
        builder: (context, state) => const HostDashboardScreen(),
      ),
      // Removed /my-bookings as it's now part of Home (Tab 2)
      GoRoute(
        path: '/property/:id',
        builder: (context, state) {
          final property = state.extra as Property?;
          if (property == null) {
            return const Scaffold(
              body: Center(
                  child: Text(
                      'Error: Property data missing (Deep link not supported yet)')),
            );
          }
          return VillaDetailScreen(property: property);
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
          return BookingFlowWrapper(property: property);
        },
        routes: [
          GoRoute(
            path: 'qris',
            pageBuilder: (context, state) {
              final extra = state.extra;
              Property? property;
              String? bookingId;

              if (extra is Property) {
                property = extra;
              } else if (extra is Map<String, dynamic>) {
                property = extra['property'] as Property?;
                bookingId = extra['bookingId'] as String?;
              }

              return CustomTransitionPage(
                key: state.pageKey,
                child: property == null
                    ? const Scaffold(
                        body:
                            Center(child: Text('Error: Property data missing')))
                    : QrisPaymentScreen(
                        property: property,
                        bookingId: bookingId,
                      ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'success',
            builder: (context, state) => const BookingSuccessScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/destination',
        builder: (context, state) {
          if (state.extra is Map<String, dynamic>) {
            final extra = state.extra as Map<String, dynamic>;
            return DestinationDetailScreen(
              destinationName: extra['name'],
              imageUrl: extra['image'],
            );
          } else {
            return const Scaffold(
              body: Center(child: Text('Error: Destination data missing')),
            );
          }
        },
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/message-room',
        builder: (context, state) {
          final chat = state.extra as Map<String, String>;
          return ChatRoomScreen(chat: chat);
        },
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
