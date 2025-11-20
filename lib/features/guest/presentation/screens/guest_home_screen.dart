import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:villavibe/core/presentation/widgets/property_card.dart';

import 'package:villavibe/features/guest/presentation/widgets/login_prompt_view.dart';
import 'package:villavibe/features/guest/presentation/widgets/profile_login_view.dart';
import 'package:villavibe/features/guest/presentation/widgets/authenticated_profile_view.dart';
import 'package:villavibe/features/home/presentation/widgets/home_hero_section.dart';
import 'package:villavibe/features/home/presentation/widgets/floating_bottom_nav_bar.dart';
import 'package:villavibe/features/home/presentation/widgets/destination_card.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class GuestHomeScreen extends ConsumerStatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  ConsumerState<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends ConsumerState<GuestHomeScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final allPropertiesAsync = ref.watch(allPropertiesProvider);
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;

    Widget buildBody() {
      switch (_currentNavIndex) {
        case 0: // Explore
          return _buildExploreContent(allPropertiesAsync);
        case 1: // Wishlists
          if (user == null) {
            return const LoginPromptView(
              title: 'Wishlists',
              subtitle: 'Log in to view your wishlists',
              description:
                  'You can create, view, or edit wishlists once you\'ve logged in.',
            );
          }
          return const Center(child: Text('Wishlists (Logged In)'));
        case 2: // Trips
          if (user == null) {
            return const LoginPromptView(
              title: 'Trips',
              subtitle: 'No trips yet',
              description:
                  'When you\'re ready to plan your next trip, we\'re here to help.',
            );
          }
          return const Center(child: Text('Trips (Logged In)'));
        case 3: // Messages
          if (user == null) {
            return const LoginPromptView(
              title: 'Inbox',
              subtitle: 'Log in to see messages',
              description:
                  'Once you login, you\'ll find messages from hosts here.',
            );
          }
          return const Center(child: Text('Messages (Logged In)'));
        case 4: // Profile
          if (user == null) {
            return const ProfileLoginView();
          }
          return const AuthenticatedProfileView();
        default:
          return _buildExploreContent(allPropertiesAsync);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          buildBody(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNavBar(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                setState(() {
                  _currentNavIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreContent(AsyncValue<List<Property>> allPropertiesAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100), // Space for floating nav
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          HomeHeroSection(
            user: ref.watch(currentUserProvider).value,
            onProfileTap: () {
              setState(() {
                _currentNavIndex = 4; // Switch to Profile tab
              });
            },
            onSearchTap: () {
              WoltModalSheet.show(
                context: context,
                pageListBuilder: (modalSheetContext) {
                  return [
                    WoltModalSheetPage(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text('Search functionality coming soon'),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(modalSheetContext).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
              );
            },
          ).animate().fadeIn(duration: 600.ms),

          const SizedBox(height: 24),

          // Content
          allPropertiesAsync.when(
            data: (properties) {
              // Filter by category (simplified for now as tabs are removed from hero)
              // We can re-introduce tabs below hero if needed, but design shows "The most relevant" directly

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "The most relevant" section
                  _buildSection(
                    context,
                    title: 'The most relevant',
                    properties: properties
                        .take(5)
                        .toList(), // Just take first 5 for now
                    delay: 200.ms,
                  ),

                  const SizedBox(height: 32),

                  // "Discover new places" section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text(
                      'Discover new places',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        DestinationCard(
                          imageUrl:
                              'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?q=80&w=1972&auto=format&fit=crop', // Cinque Terre
                          title: 'Cinque Terre',
                          onTap: () {},
                        ),
                        DestinationCard(
                          imageUrl:
                              'https://images.unsplash.com/photo-1506953823976-52e1fdc0149a?q=80&w=1935&auto=format&fit=crop', // Beach
                          title: 'Bali',
                          onTap: () {},
                        ),
                        DestinationCard(
                          imageUrl:
                              'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?q=80&w=2070&auto=format&fit=crop', // Mountains
                          title: 'Swiss Alps',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Property> properties,
    Duration delay = Duration.zero,
  }) {
    if (properties.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(LucideIcons.chevronRight, size: 16, color: Colors.black),
            ],
          ),
        ).animate().fadeIn(delay: delay).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 16),
        SizedBox(
          height: 360,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return PropertyCard(
                property: property,
                onTap: () {
                  context.push('/property/${property.id}', extra: property);
                },
              )
                  .animate()
                  .fadeIn(delay: delay + (100 * index).ms)
                  .slideX(begin: 0.1, end: 0);
            },
          ),
        ),
      ],
    );
  }
}
