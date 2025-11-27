import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:villavibe/features/search/presentation/providers/search_provider.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  final calculatedHeight = constraints.maxHeight - (2 * inactiveHeight) - (2 * spacing) - 32;
                  final expandedHeight = calculatedHeight > 0 ? calculatedHeight - 1 : 0.0;

                  // Positions
                  double top1 = 0;
                  double h1 = searchState.currentStep == SearchStep.where ? expandedHeight : inactiveHeight;
                  
                  double top2 = h1 + spacing;
                  double h2 = searchState.currentStep == SearchStep.when ? expandedHeight : inactiveHeight;
                  
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
                              value: searchState.startDate != null
                                  ? '${searchState.startDate.toString().split(' ')[0]} - ${searchState.endDate.toString().split(' ')[0]}'
                                  : 'Add dates',
                              isActive: searchState.currentStep == SearchStep.when,
                              onTap: () => notifier.setStep(SearchStep.when),
                              content: _buildWhenContent(ref),
                              expandedHeight: expandedHeight,
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
                        // TODO: Navigate to results
                        context.push('/search/results');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE31C5F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(LucideIcons.search, size: 18),
                      label: const Text(
                        'Search',
                        style: TextStyle(
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
      children: [
        TextField(
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
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSuggestionItem(Icons.near_me_outlined, 'Nearby'),
                _buildSuggestionItem(Icons.map_outlined, 'Yogyakarta, Indonesia'),
                _buildSuggestionItem(Icons.map_outlined, 'Bali, Indonesia'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionItem(IconData icon, String text) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
      title: Text(text),
      onTap: () {
        // TODO: Select location
      },
    );
  }

  Widget _buildWhenContent(WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTabItem('Dates', true),
                    _buildTabItem('Months', false),
                    _buildTabItem('Flexible', false),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SfDateRangePicker(
            selectionMode: DateRangePickerSelectionMode.range,
            headerStyle: const DateRangePickerHeaderStyle(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            monthViewSettings: const DateRangePickerMonthViewSettings(
              firstDayOfWeek: 1,
            ),
            onSelectionChanged: (args) {
              if (args.value is PickerDateRange) {
                ref.read(searchNotifierProvider.notifier).setDates(
                      args.value.startDate,
                      args.value.endDate,
                    );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(String text, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isSelected ? Colors.black : Colors.grey[600],
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
}
