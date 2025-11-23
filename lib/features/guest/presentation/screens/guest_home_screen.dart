import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import 'package:villavibe/core/presentation/widgets/property_card.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/bookings/presentation/screens/my_bookings_screen.dart';
import 'package:villavibe/features/favorites/presentation/screens/wishlist_screen.dart';
import 'package:villavibe/features/guest/presentation/widgets/authenticated_profile_view.dart';
import 'package:villavibe/features/guest/presentation/widgets/category_selector.dart';
import 'package:villavibe/features/guest/presentation/widgets/login_prompt_view.dart';
import 'package:villavibe/features/guest/presentation/widgets/profile_login_view.dart';
import 'package:villavibe/features/home/presentation/providers/search_provider.dart';
import 'package:villavibe/features/home/presentation/widgets/destination_card.dart';
import 'package:villavibe/features/home/presentation/widgets/floating_bottom_nav_bar.dart';
import 'package:villavibe/features/home/presentation/widgets/home_hero_section.dart';
import 'package:villavibe/features/home/presentation/widgets/search_filter_modal.dart';
import 'package:villavibe/features/home/presentation/widgets/top_search_bar.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class GuestHomeScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const GuestHomeScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends ConsumerState<GuestHomeScreen> {
  int _currentNavIndex = 0;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    // Watch both providers
    final allPropertiesAsync = ref.watch(allPropertiesProvider);
    final filteredPropertiesAsync = ref.watch(filteredPropertiesProvider);

    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;

    Widget buildBody() {
      switch (_currentNavIndex) {
        case 0: // Explore
          // Use filtered properties ONLY if search is active
          return _buildExploreContent(
            _isSearchActive ? filteredPropertiesAsync : allPropertiesAsync,
          );
        case 1: // Wishlists
          if (user == null) {
            return const LoginPromptView(
              title: 'Wishlists',
              subtitle: 'Log in to view your wishlists',
              description:
                  'You can create, view, or edit wishlists once you\'ve logged in.',
            );
          }
          return const WishlistScreen();
        case 2: // Trips
          if (user == null) {
            return const LoginPromptView(
              title: 'Trips',
              subtitle: 'No trips yet',
              description:
                  'When you\'re ready to plan your next trip, we\'re here to help.',
            );
          }
          return const MyBookingsScreen();
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
          return _buildExploreContent(
            _isSearchActive ? filteredPropertiesAsync : allPropertiesAsync,
          );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          buildBody(),

          // Top Search Bar (only visible when search is active)
          if (_isSearchActive)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TopSearchBar(
                onBack: () {
                  setState(() {
                    _isSearchActive = false;
                  });
                  ref.read(searchFilterStateProvider.notifier).reset();
                },
                onFilterTap: () {
                  WoltModalSheet.show(
                    context: context,
                    pageListBuilder: (modalSheetContext) {
                      return [
                        WoltModalSheetPage(
                          child: const SearchFilterModal(),
                        ),
                      ];
                    },
                  );
                },
              ),
            ),

          // Bottom Nav (hidden when search is active)
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

  Widget _buildExploreContent(AsyncValue<List<Property>> propertiesAsync) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: _isSearchActive ? 100 : 0, // Add padding for search bar
        bottom: 100, // Space for floating nav
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section (Only show if search is NOT active)
          if (!_isSearchActive)
            HomeHeroSection(
              user: ref.watch(currentUserProvider).value,
              onSearchTap: () {
                setState(() {
                  _isSearchActive = true;
                });
              },
            ).animate().fadeIn(duration: 600.ms),

          const SizedBox(height: 24),
          if (!_isSearchActive) ...[
            const CategorySelector(),
            const SizedBox(height: 24),
          ],

          // Content
          propertiesAsync.when(
            data: (properties) {
              if (properties.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(LucideIcons.searchX,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            // Clear filters but keep search active if they want to try another query
                            // Or maybe just clear query?
                            ref
                                .read(searchFilterStateProvider.notifier)
                                .reset();
                            // If we reset, we might want to exit search mode too?
                            // Let's just clear filters for now.
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "The most relevant" section (or "Search Results" if active)
                  _buildSection(
                    context,
                    title: _isSearchActive
                        ? 'Search Results'
                        : 'The most relevant',
                    properties: properties,
                    delay: 200.ms,
                  ),

                  const SizedBox(height: 32),

                  // "Discover new places" section - Hide if search is active
                  if (!_isSearchActive) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Discover new places',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideX(begin: -0.1, end: 0),
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
                    )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideX(begin: 0.1, end: 0),
                  ],
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
              if (!_isSearchActive) ...[
                const SizedBox(width: 8),
                const Icon(LucideIcons.chevronRight,
                    size: 16, color: Colors.black),
              ],
            ],
          ),
        ).animate().fadeIn(delay: delay).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 16),
        // If search is active, use vertical list, otherwise horizontal
        _isSearchActive
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final property = properties[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: PropertyCard(
                      property: property,
                      onTap: () {
                        context.push('/property/${property.id}',
                            extra: property);
                      },
                    ),
                  )
                      .animate()
                      .fadeIn(delay: delay + (100 * index).ms)
                      .slideX(begin: 0.1, end: 0);
                },
              )
            : SizedBox(
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
                        context.push('/property/${property.id}',
                            extra: property);
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
