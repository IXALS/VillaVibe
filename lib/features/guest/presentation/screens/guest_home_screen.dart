import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';

import 'package:villavibe/core/presentation/widgets/bottom_nav_bar.dart';
import 'package:villavibe/core/presentation/widgets/custom_search_bar.dart';
import 'package:villavibe/core/presentation/widgets/category_tabs.dart';
import 'package:villavibe/core/presentation/widgets/property_card.dart';
import 'package:villavibe/core/presentation/widgets/property_card_shimmer.dart';
import 'package:villavibe/features/guest/presentation/widgets/login_prompt_view.dart';
import 'package:villavibe/features/guest/presentation/widgets/profile_login_view.dart';

class GuestHomeScreen extends ConsumerStatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  ConsumerState<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends ConsumerState<GuestHomeScreen> {
  int _currentNavIndex = 0;
  String _selectedCategory = 'Homes';

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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome, ${user.displayName}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(authRepositoryProvider).signOut();
                  },
                  child: const Text('Log out'),
                ),
              ],
            ),
          );
        default:
          return _buildExploreContent(allPropertiesAsync);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: buildBody(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ).animate().slideY(
          begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
    );
  }

  Widget _buildExploreContent(AsyncValue<List<Property>> allPropertiesAsync) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Custom Search Bar
          CustomSearchBar(
            onTap: () {
              // TODO: Navigate to search screen
            },
          ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
          // Category Tabs
          CategoryTabs(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
          // Content
          Expanded(
            child: allPropertiesAsync.when(
              data: (properties) {
                // Filter by category
                final filteredProperties = properties.where((p) {
                  if (_selectedCategory == 'Homes') {
                    return true;
                  } else if (_selectedCategory == 'Beaches') {
                    return p.description.toLowerCase().contains('beach') ||
                        p.description.toLowerCase().contains('ocean') ||
                        p.amenities.contains('Beach access');
                  } else if (_selectedCategory == 'Mountain') {
                    return p.description.toLowerCase().contains('mountain') ||
                        p.description.toLowerCase().contains('hill') ||
                        p.amenities.contains('Mountain view');
                  } else if (_selectedCategory == 'City') {
                    return p.description.toLowerCase().contains('city') ||
                        p.description.toLowerCase().contains('jakarta') ||
                        p.description.toLowerCase().contains('urban');
                  }
                  return true;
                }).toList();

                if (filteredProperties.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_selectedCategory.toLowerCase()} found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn();
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Popular homes section
                      _buildSection(
                        context,
                        title: 'Popular homes in Jakarta',
                        properties: filteredProperties.take(5).toList(),
                        delay: 400.ms,
                      ),
                      const SizedBox(height: 32),
                      // Available this weekend section
                      _buildSection(
                        context,
                        title: 'Available this weekend',
                        properties: filteredProperties.skip(5).take(5).toList(),
                        delay: 600.ms,
                      ),
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                itemBuilder: (context, index) => const PropertyCardShimmer(),
              ),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
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
