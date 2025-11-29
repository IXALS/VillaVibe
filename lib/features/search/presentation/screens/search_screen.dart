import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:villavibe/features/search/presentation/providers/search_provider.dart';
import 'package:villavibe/features/search/presentation/widgets/dates_tab_view.dart';
import 'package:villavibe/features/search/presentation/widgets/flexible_tab_view.dart';
import 'package:villavibe/features/search/presentation/widgets/months_tab_view.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final bool? isEditing;

  const SearchScreen({
    super.key,
    this.isEditing,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _locationController;
  bool _areInteractionsEnabled = false;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(
      text: ref.read(searchNotifierProvider).location ?? '',
    );

    // Frame Deferral: Wait for the transition animation to complete before rendering heavy widgets.
    // The transition duration is 400ms (defined in app_router.dart), so we wait 450ms to be safe.
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) {
        setState(() {
          _areInteractionsEnabled = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);

    final routeAnimation = ModalRoute.of(context)?.animation;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Glass Blur Effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: routeAnimation ?? const AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                final double blurValue = (routeAnimation?.value ?? 1.0) * 20;
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                  child: Container(
                    color: Colors.white.withOpacity(0.6 * (routeAnimation?.value ?? 1.0)),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // TODO: Switch to Stays/Experiences
                        },
                        child: const Text(
                          'Stays',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Balance the close button
                    ],
                  ),
                ),

            // Accordion Sections
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate available height for the active section
                  final inactiveHeight = 84.0;
                  final spacing = 12.0;
                  
                  // If 'When' is active, it takes up all space below 'Where' (collapsed)
                  // 'Who' is pushed off screen or hidden
                  final isWhenActive = searchState.currentStep == SearchStep.when;
                  
                  // Use almost all available space (minus small padding) to maximize the view area.
                  // This increases the chance of cutting off an item mid-way on various screen sizes.
                  final calculatedHeight = constraints.maxHeight - (2 * inactiveHeight) - (2 * spacing) - 10;
                  final expandedHeight = calculatedHeight > 0 ? calculatedHeight - 1 : 0.0;
                  
                  // Special height calculation for full-screen 'When'
                  final whenExpandedHeight = constraints.maxHeight - inactiveHeight - spacing - 32;

                  // Positions
                  double top1 = 0;
                  double h1 = searchState.currentStep == SearchStep.where ? expandedHeight : inactiveHeight;
                  
                  double top2 = h1 + spacing;
                  // If When is active, use the larger height. Otherwise, it's inactive.
                  double h2 = isWhenActive ? whenExpandedHeight : inactiveHeight;
                  
                  // If When is active, Who is pushed down (potentially off screen)
                  double top3 = top2 + h2 + spacing;
                  double h3 = searchState.currentStep == SearchStep.who ? expandedHeight : inactiveHeight;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Who Section (Bottom Layer)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          top: top3,
                          left: 0,
                          right: 0,
                          height: h3,
                          child: _buildEntranceExitAnimation(
                            routeAnimation: routeAnimation,
                            beginInterval: 0.2,
                            endInterval: 0.6,
                            exitBeginInterval: 0.5, // Start fading out earlier
                            exitEndInterval: 0.8,
                            child: _buildSection(
                              context,
                              title: 'Who',
                              value: searchState.totalGuests > 0
                                  ? '${searchState.totalGuests} guests'
                                  : 'Add guests',
                              isActive: searchState.currentStep == SearchStep.who,
                              onTap: () => notifier.setStep(SearchStep.who),
                              content: _buildWhoContent(ref),
                              expandedHeight: expandedHeight,
                            ),
                          ),
                        ),

                        // When Section (Middle Layer)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          top: top2,
                          left: 0,
                          right: 0,
                          height: h2,
                          child: _buildEntranceExitAnimation(
                            routeAnimation: routeAnimation,
                            beginInterval: 0.1,
                            endInterval: 0.5,
                            exitBeginInterval: 0.5, // Start fading out earlier
                            exitEndInterval: 0.8,
                            child: _buildSection(
                              context,
                              title: 'When',
                              value: _formatDateRange(searchState),
                              isActive: searchState.currentStep == SearchStep.when,
                              onTap: () => notifier.setStep(SearchStep.when),
                              content: _buildWhenContent(ref),
                              expandedHeight: whenExpandedHeight,
                            ),
                          ),
                        ),

                        // Where Section (Top Layer)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          top: top1,
                          left: 0,
                          right: 0,
                          height: h1,
                          child: _buildSection(
                            context,
                            title: 'Where',
                            value: searchState.location ?? 'I\'m flexible',
                            isActive: searchState.currentStep == SearchStep.where,
                            onTap: () => notifier.setStep(SearchStep.where),
                            content: _buildWhereContent(ref),
                            heroTag: 'search_bar', // Re-add Hero tag for simple transition
                            expandedHeight: expandedHeight,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Bar
            _buildEntranceExitAnimation(
              routeAnimation: routeAnimation,
              beginInterval: 0.3,
              endInterval: 0.7,
              exitBeginInterval: 0.6, // Start fading out earlier
              exitEndInterval: 0.9,
              slideBegin: const Offset(0, 1.0),
              child: Container(
                padding: const EdgeInsets.all(16) +
                    EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => notifier.reset(),
                      child: const Text(
                        'Clear all',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (searchState.currentStep == SearchStep.who) {
                            if (widget.isEditing == true) {
                              context.pop();
                            } else {
                              context.pushReplacement('/search/results');
                            }
                          } else {
                          // Move to next step
                          if (searchState.currentStep == SearchStep.where) {
                            notifier.setStep(SearchStep.when);
                          } else if (searchState.currentStep == SearchStep.when) {
                            notifier.setStep(SearchStep.who);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: searchState.currentStep == SearchStep.who
                            ? const Color(0xFFE31C5F)
                            : Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: searchState.currentStep == SearchStep.who
                          ? const Icon(LucideIcons.search, size: 18)
                          : const SizedBox.shrink(),
                      label: Text(
                        searchState.currentStep == SearchStep.who ? 'Search' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
  }

  Widget _buildEntranceExitAnimation({
    required Widget child,
    required Animation<double>? routeAnimation,
    required double beginInterval,
    required double endInterval,
    double? exitBeginInterval,
    double? exitEndInterval,
    Offset slideBegin = const Offset(0, 0.1),
  }) {
    if (routeAnimation == null) return child;

    final animation = CurvedAnimation(
      parent: routeAnimation,
      curve: Interval(beginInterval, endInterval, curve: Curves.easeOut),
      reverseCurve: Interval(
        exitBeginInterval ?? beginInterval,
        exitEndInterval ?? endInterval,
        curve: Curves.easeIn,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String value,
    required bool isActive,
    required VoidCallback onTap,
    required Widget content,
    String? heroTag,
    required double expandedHeight,
  }) {
    // Common decoration for both states
    final decoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
      boxShadow: isActive
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ]
          : [],
    );

    Widget container = Container(
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: isActive
              ? OverflowBox(
                  minHeight: expandedHeight, 
                  maxHeight: expandedHeight,
                  alignment: Alignment.topCenter,
                  child: Padding(
                    key: const ValueKey('expanded'),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: heroTag != null
                              ? content
                              : content
                                  .animate()
                                  .fadeIn(duration: 300.ms, delay: 150.ms)
                                  .slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
                        ),
                      ],
                    ),
                  ),
                )
              : (heroTag != null
                      ? GestureDetector(
                          key: const ValueKey('collapsed'),
                          onTap: onTap,
                          child: Container(
                            color: Colors.transparent, // Ensure hit test works
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GestureDetector(
                          key: const ValueKey('collapsed'),
                          onTap: onTap,
                          child: Container(
                            color: Colors.transparent, // Ensure hit test works
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                          .animate()
                          .fadeIn(duration: 200.ms)),
        ),
      ),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag,
        child: container,
      );
    }

    return container;
  }

  Widget _buildWhereContent(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Search destinations',
            prefixIcon: const Icon(LucideIcons.search),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onChanged: (value) {
            ref.read(searchNotifierProvider.notifier).setLocation(value);
          },
        ),
        const SizedBox(height: 24),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'Suggested destinations',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      const SizedBox(height: 16),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSuggestionItem(
                Icons.near_me_outlined,
                'Nearby',
                'Find what\'s around you',
                Colors.blue,
                onTap: () async {
                  LocationPermission permission = await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location permission denied')),
                        );
                      }
                      return;
                    }
                  }
                  
                  if (permission == LocationPermission.deniedForever) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Location permission permanently denied')),
                      );
                    }
                    return;
                  } 

                  final position = await Geolocator.getCurrentPosition();
                  
                  if (context.mounted) {
                    _locationController.text = 'Current Location';
                    ref.read(searchNotifierProvider.notifier).setNearbySearch(
                      GeoPoint(position.latitude, position.longitude)
                    );
                    ref.read(searchNotifierProvider.notifier).setStep(SearchStep.when);
                  }
                },
              ),
              _buildSuggestionItem(
                Icons.map_outlined,
                'Ubud, Bali',
                'Popular with travelers near you',
                Colors.teal,
              ),
              _buildSuggestionItem(
                Icons.location_city,
                'Yogyakarta, Yogyakarta',
                'For sights like Borobudur Temple',
                Colors.orange,
              ),
              _buildSuggestionItem(
                Icons.landscape_outlined,
                'Malang, East Java',
                'For nature-lovers',
                Colors.pink,
              ),
              _buildSuggestionItem(
                Icons.beach_access_outlined,
                'Lombok, West Nusa Tenggara',
                'Beautiful beaches and islands',
                Colors.cyan,
              ),
              _buildSuggestionItem(
                Icons.temple_buddhist_outlined,
                'Borobudur, Central Java',
                'Historic temple sites',
                Colors.purple,
              ),
              const SizedBox(height: 24), // Add padding at bottom to show scrollability
            ],
          ),
        ),
      ),
    ],
  );
}

  Widget _buildSuggestionItem(
    IconData icon, String title, String description, Color iconColor, {VoidCallback? onTap}) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    leading: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 24, color: iconColor),
    ),
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.black87,
      ),
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
    ),
    onTap: onTap ?? () {
      _locationController.text = title.split(',')[0]; // Use first part of title
      ref.read(searchNotifierProvider.notifier).setLocation(title.split(',')[0]);
      ref.read(searchNotifierProvider.notifier).setStep(SearchStep.when);
    },
  );
}

  int _selectedDateTab = 0;

  Widget _buildWhenContent(WidgetRef ref) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.all(4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  _buildTabItem('Dates', 0),
                  _buildTabItem('Months', 1),
                  _buildTabItem('Flexible', 2),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: !_areInteractionsEnabled
              ? const Center(child: CircularProgressIndicator())
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: KeyedSubtree(
                    key: ValueKey(_selectedDateTab),
                    child: _buildTabContent(ref),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTabContent(WidgetRef ref) {
    final searchState = ref.watch(searchNotifierProvider);
    switch (_selectedDateTab) {
      case 0:
        return DatesTabView(
          initialStartDate: searchState.specificStartDate,
          initialEndDate: searchState.specificEndDate,
          onDatesChanged: (start, end) {
            if (start != null) {
              ref.read(searchNotifierProvider.notifier).setSpecificDates(start, end);
            }
          },
        );
      case 1:
        return MonthsTabView(
          startDate: searchState.monthsStartDate,
          onRangeChanged: (start, months) {
            ref.read(searchNotifierProvider.notifier).setMonthsConfig(start, months);
          },
          onDateTap: () {
            setState(() {
              _selectedDateTab = 0;
            });
            ref.read(searchNotifierProvider.notifier).setActiveDateTab(SearchDateTab.dates);
          },
        );
      case 2:
        return FlexibleTabView(
          onSelectionChanged: (duration, months) {
            ref.read(searchNotifierProvider.notifier).setFlexibleConfig(duration, months);
          },
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildTabItem(String text, int index) {
    final isSelected = _selectedDateTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDateTab = index;
          });
          final tab = index == 0 
              ? SearchDateTab.dates 
              : index == 1 
                  ? SearchDateTab.months 
                  : SearchDateTab.flexible;
          ref.read(searchNotifierProvider.notifier).setActiveDateTab(tab);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhoContent(WidgetRef ref) {
    final searchState = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildGuestCounter(
            'Adults',
            'Ages 13 or above',
            searchState.adults,
            (val) => notifier.updateGuestCount(adults: val),
          ),
          const Divider(),
          _buildGuestCounter(
            'Children',
            'Ages 2-12',
            searchState.children,
            (val) => notifier.updateGuestCount(children: val),
          ),
          const Divider(),
          _buildGuestCounter(
            'Infants',
            'Under 2',
            searchState.infants,
            (val) => notifier.updateGuestCount(infants: val),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCounter(
    String title,
    String subtitle,
    int count,
    Function(int) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: count > 0 ? () => onChanged(count - 1) : null,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: count > 0 ? Colors.grey[400]! : Colors.grey[200]!,
                ),
              ),
              child: Icon(
                LucideIcons.minus,
                size: 16,
                color: count > 0 ? Colors.black : Colors.grey[300],
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              count.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => onChanged(count + 1),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: const Icon(
                LucideIcons.plus,
                size: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
  String _formatDateRange(SearchState state) {
    if (state.startDate == null) return 'I\'m flexible';
    
    final start = DateFormat('d MMM').format(state.startDate!);
    if (state.endDate == null) return start;
    
    final end = DateFormat('d MMM').format(state.endDate!);
    return '$start - $end';
  }
}
