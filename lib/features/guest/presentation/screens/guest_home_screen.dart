import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/bookings/presentation/screens/my_bookings_screen.dart';
import 'package:villavibe/features/favorites/presentation/screens/wishlist_screen.dart';
import 'package:villavibe/features/guest/presentation/widgets/authenticated_profile_view.dart';
import 'package:villavibe/features/guest/presentation/widgets/category_selector.dart';
import 'package:villavibe/features/guest/presentation/widgets/login_prompt_view.dart';
import 'package:villavibe/features/guest/presentation/widgets/profile_login_view.dart';
import 'package:villavibe/features/home/presentation/providers/search_provider.dart';
import 'package:villavibe/features/home/presentation/widgets/destination_card.dart';
import 'package:villavibe/features/home/presentation/widgets/home_hero_section.dart';
import 'package:villavibe/features/home/presentation/widgets/search_filter_modal.dart';
import 'package:villavibe/features/home/presentation/widgets/standard_bottom_nav_bar.dart';
import 'package:villavibe/features/home/presentation/widgets/top_search_bar.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/properties/presentation/widgets/villa_compact_card.dart';

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

  void _onNavTapped(int index) {
    setState(() {
      _currentNavIndex = index;
      _isSearchActive = false;
      FocusScope.of(context).unfocus();
    });
  }

  void _onSearchBack() {
    setState(() {
      _isSearchActive = false;
    });
    ref.read(searchFilterStateProvider.notifier).reset();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final allPropertiesAsync = ref.watch(allPropertiesProvider);
    final filteredPropertiesAsync = ref.watch(filteredPropertiesProvider);
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;

    Widget buildBody() {
      switch (_currentNavIndex) {
        case 0:
          return _buildExploreContent(
            _isSearchActive ? filteredPropertiesAsync : allPropertiesAsync,
          );
        case 1:
          if (user == null) {
            return const LoginPromptView(
              title: 'Wishlists',
              subtitle: 'Log in to view your wishlists',
              description:
                  'You can create, view, or edit wishlists once you\'ve logged in.',
            );
          }
          return const WishlistScreen();
        case 2:
          if (user == null) {
            return const LoginPromptView(
              title: 'Trips',
              subtitle: 'No trips yet',
              description:
                  'When you\'re ready to plan your next trip, we\'re here to help.',
            );
          }
          return const MyBookingsScreen();
        case 3:
          if (user == null) {
            return const LoginPromptView(
              title: 'Inbox',
              subtitle: 'Log in to see messages',
              description:
                  'Once you login, you\'ll find messages from hosts here.',
            );
          }
          return const Center(child: Text('Messages (Logged In)'));
        case 4:
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

    final bool shouldHideNavBar = _isSearchActive && _currentNavIndex == 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          buildBody(),
          if (_isSearchActive && _currentNavIndex == 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TopSearchBar(
                onBack: _onSearchBack,
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
              ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.2, end: 0),
            ),
        ],
      ),
      bottomNavigationBar: shouldHideNavBar
          ? null
          : StandardBottomNavBar(
              currentIndex: _currentNavIndex,
              onTap: _onNavTapped,
            ),
    );
  }

  Widget _buildExploreContent(AsyncValue<List<Property>> propertiesAsync) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: _isSearchActive ? 100 : 0,
        bottom: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isSearchActive)
            HomeHeroSection(
              user: ref.watch(currentUserProvider).value,
              onSearchTap: () {
                setState(() {
                  _isSearchActive = true;
                });
              },
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuad),
          const SizedBox(height: 24),
          if (!_isSearchActive) ...[
            CategorySelector(
              onCategoryChanged: (category) {
                print("User memilih kategori: $category");
              },
            ),
            const SizedBox(height: 32),
          ],
          propertiesAsync.when(
            data: (properties) {
              if (properties.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(LucideIcons.searchX,
                            size: 64, color: Colors.black12),
                        const SizedBox(height: 16),
                        const Text(
                          'No results found',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: _onSearchBack,
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().scale(),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    title: _isSearchActive
                        ? 'Search Results'
                        : 'Recommended for you',
                    properties: properties,
                    delay: 200.ms,
                  ),
                  const SizedBox(height: 40),
                  if (!_isSearchActive) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Discover new places',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5),
                          ),
                          Icon(LucideIcons.arrowRight,
                              size: 20, color: Colors.grey[400]),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideX(begin: -0.1, end: 0),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildAnimatedDestinationCard(
                              'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?q=80&w=1972&auto=format&fit=crop',
                              'Bali',
                              0,
                              context),
                          _buildAnimatedDestinationCard(
                              'https://images.unsplash.com/photo-1506953823976-52e1fdc0149a?q=80&w=1935&auto=format&fit=crop',
                              'Malang',
                              1,
                              context),
                          _buildAnimatedDestinationCard(
                              'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?q=80&w=2070&auto=format&fit=crop',
                              'Batu',
                              2,
                              context),
                        ],
                      ),
                    ),
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

  Widget _buildAnimatedDestinationCard(
      String url, String title, int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: DestinationCard(
        imageUrl: url,
        title: title,
        onTap: () {
          context.push('/destination', extra: {'name': title, 'image': url});
        },
      ),
    )
        .animate()
        .fadeIn(delay: (600 + (index * 100)).ms)
        .slideX(begin: 0.2, end: 0, curve: Curves.easeOut);
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
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          ),
        ).animate().fadeIn(delay: delay).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        _isSearchActive
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final property = properties[index];
                  return VillaCompactCard(
                    property: property,
                    onTap: () {
                      context.push('/property/${property.id}', extra: property);
                    },
                  )
                      .animate()
                      .fadeIn(delay: delay + (50 * index).ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
                },
              )
            : SizedBox(
                height: 340,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    final property = properties[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: VillaCompactCard(
                        property: property,
                        onTap: () {
                          context.push('/property/${property.id}',
                              extra: property);
                        },
                      ),
                    )
                        .animate()
                        .fadeIn(delay: delay + (100 * index).ms)
                        .slideX(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
                  },
                ),
              ),
      ],
    );
  }
}
