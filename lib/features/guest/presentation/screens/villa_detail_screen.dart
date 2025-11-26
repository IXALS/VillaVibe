import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/auth/presentation/widgets/login_modal.dart';
import 'package:villavibe/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';

import 'dart:async';
import 'package:villavibe/core/presentation/widgets/three_dots_loader.dart';

class VillaDetailScreen extends ConsumerStatefulWidget {
  final Property property;
  final String? heroTagPrefix;

  const VillaDetailScreen({
    super.key,
    required this.property,
    this.heroTagPrefix,
  });

  @override
  ConsumerState<VillaDetailScreen> createState() => _VillaDetailScreenState();
}

class _VillaDetailScreenState extends ConsumerState<VillaDetailScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate network delay for premium feel
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch for updates, but use passed property as initial data
    final propertyAsync = ref.watch(propertyProvider(widget.property.id));
    final authState = ref.watch(authStateProvider);

    // Use the latest data if available, otherwise use the passed property
    final currentProperty = propertyAsync.value ?? widget.property;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildContent(context, currentProperty),
      bottomNavigationBar: _buildBottomBar(
        context,
        currentProperty,
        authState.maybeWhen(
          data: (user) => user != null,
          orElse: () => false,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Property property) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, property),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24), // Standard top padding
                    _buildHeader(property), // Instant Header
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      switchInCurve: Curves.easeOutCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _isLoading
                          ? Container(
                              key: const ValueKey('loader'),
                              height: 200,
                              alignment: Alignment.center,
                              child: const ThreeDotsLoader(size: 10),
                            )
                          : Column(
                              key: const ValueKey('content'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(height: 1),
                                const SizedBox(height: 24),
                                _buildHostSection(property),
                                const Divider(height: 48),
                                _buildHighlights(),
                                const Divider(height: 48),
                                _buildDescription(property),
                                const Divider(height: 48),
                                _buildAmenities(property),
                                const Divider(height: 48),
                                _buildReviewsSection(property),
                                const Divider(height: 48),
                                _buildMeetYourHost(property),
                                const Divider(height: 48),
                                _buildAvailability(property),
                                const Divider(height: 48),
                                _buildThingsToKnow(property),
                                const Divider(height: 48),
                                _buildLocation(property),
                                const SizedBox(height: 32),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        _buildFixedHeaderIcons(context, property),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Property property) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: '${widget.heroTagPrefix ?? ''}villa_img_${property.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.antiAlias,
              children: [
                property.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: property.images.first,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration.zero,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child:
                              const Icon(LucideIcons.image, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child:
                            const Icon(LucideIcons.image, color: Colors.grey),
                      ),
                if (property.images.isNotEmpty)
                  Positioned(
                    bottom: 40 + 32, // Adjusted for the bottom rounded cap
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '1/${property.images.length}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                // Fake Cap for Hero Transition Smoothness
                Positioned(
                  bottom: -1, // Slight overlap to prevent gaps
                  left: 0,
                  right: 0,
                  height: 33, // +1px to ensure full coverage
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(32),
        child: Container(
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedHeaderIcons(BuildContext context, Property property) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft,
                      color: Colors.black, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ).animate().fadeIn(delay: 200.ms),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(LucideIcons.share,
                          color: Colors.black, size: 20),
                      onPressed: () {},
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: FavoriteButton(
                      villaId: property.id,
                      color: Colors.black,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(width: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: Color(0xFF212121), // Dark Grey
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Entire rental unit in ${property.city}, Indonesia',
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          '${property.specs.maxGuests} guests · ${property.specs.bedrooms} bedroom · ${property.specs.bedrooms} bed · ${property.specs.bathrooms} bath',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(LucideIcons.star, size: 16, color: Colors.black),
            const SizedBox(width: 4),
            Text(
              '${property.rating} · ${property.reviewsCount} reviews',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHostSection(Property property) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: property.hostAvatar.isNotEmpty
              ? NetworkImage(property.hostAvatar)
              : null,
          child: property.hostAvatar.isEmpty && property.hostName.isNotEmpty
              ? Text(property.hostName[0])
              : const Icon(LucideIcons.user, size: 24, color: Colors.grey),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hosted by ${property.hostName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            Text(
              '${property.hostYearsHosting} years hosting',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHighlights() {
    return Column(
      children: [
        _buildHighlightItem(
          LucideIcons.waves,
          'Dive right in',
          'This is one of the few places in the area with a pool.',
        ),
        const SizedBox(height: 24),
        _buildHighlightItem(
          LucideIcons.key,
          'Exceptional check-in experience',
          'Recent guests gave the check-in process a 5-star rating.',
        ),
        const SizedBox(height: 24),
        _buildHighlightItem(
          LucideIcons.messageSquare,
          'Great host communication',
          'Recent guests loved the host\'s communication.',
        ),
      ],
    );
  }

  Widget _buildHighlightItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.black87),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F7F7),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Some info has been automatically translated.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Show original',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          property.description,
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Text(
              'Show more',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(width: 4),
            Icon(LucideIcons.chevronRight, size: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenities(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What this place offers',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 24),
        ...property.amenities.take(5).map((amenity) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(_getAmenityIcon(amenity),
                      size: 24, color: Colors.black87),
                  const SizedBox(width: 16),
                  Text(
                    amenity,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: Colors.black),
            ),
            child: Text(
              'Show all ${property.amenities.length} amenities',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return LucideIcons.wifi;
      case 'pool':
        return LucideIcons.waves;
      case 'kitchen':
        return LucideIcons.utensils;
      case 'gym':
        return LucideIcons.dumbbell;
      case 'ac':
        return LucideIcons.wind; // Approximate for AC
      case 'workspace':
        return LucideIcons.monitor;
      case 'garden':
        return LucideIcons.flower; // Approximate for Garden
      case 'breakfast':
        return LucideIcons.coffee;
      default:
        return LucideIcons.checkCircle;
    }
  }

  Widget _buildReviewsSection(Property property) {
    if (property.reviews.isEmpty) return const SizedBox.shrink();

    final firstReview = property.reviews.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.star, size: 20, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              '${property.rating} · ${property.reviewsCount} reviews',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: firstReview.authorAvatar.isNotEmpty
                        ? NetworkImage(firstReview.authorAvatar)
                        : null,
                    child: firstReview.authorAvatar.isEmpty
                        ? const Icon(LucideIcons.user,
                            size: 20, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstReview.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${firstReview.date.year} years on Airbnb', // Placeholder logic
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ...List.generate(
                      5,
                      (index) => const Icon(LucideIcons.star,
                          size: 14, color: Colors.black)),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMMM yyyy').format(firstReview.date),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                firstReview.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Show more',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: Colors.black),
            ),
            child: Text(
              'Show all ${property.reviewsCount} reviews',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeetYourHost(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meet your host',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EFE9), // Light beige background
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: property.hostAvatar.isNotEmpty
                            ? NetworkImage(property.hostAvatar)
                            : null,
                        child: property.hostAvatar.isEmpty
                            ? const Icon(LucideIcons.user,
                                size: 40, color: Colors.grey)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE91E63),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.shieldCheck,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    property.hostName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Host',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${property.reviewsCount}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('Reviews', style: TextStyle(fontSize: 12)),
                  const Divider(),
                  Text(
                    '${property.rating}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('Rating', style: TextStyle(fontSize: 12)),
                  const Divider(),
                  Text(
                    '${property.hostYearsHosting}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('Years hosting', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(width: 24),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (property.hostWork.isNotEmpty) ...[
          Row(
            children: [
              const Icon(LucideIcons.briefcase, size: 20),
              const SizedBox(width: 12),
              Text('My work: ${property.hostWork}'),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Text(
          property.hostDescription,
          style: const TextStyle(height: 1.5),
        ),
        const SizedBox(height: 24),
        const Text(
          'Host details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text('Response rate: ${property.hostResponseRate}'),
        Text('Responds ${property.hostResponseTime}'),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Message host',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(LucideIcons.shieldAlert,
                size: 24,
                color: const Color(0xFFE91E63).withValues(alpha: 0.5)),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'To help protect your payment, always use VillaVibe to send money and communicate with hosts.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailability(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Availability',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Text(property.dateRangeText.isNotEmpty
            ? property.dateRangeText
            : 'Select dates'),
        const SizedBox(height: 24),
        // Placeholder for Calendar
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('Calendar Placeholder')),
        ),
      ],
    );
  }

  Widget _buildThingsToKnow(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Things to know',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 24),
        _buildPolicyItem(LucideIcons.calendarX, 'Cancellation policy',
            property.cancellationPolicy),
        const SizedBox(height: 24),
        _buildPolicyItem(LucideIcons.key, 'House rules',
            property.houseRules.take(3).join('\n')),
        const SizedBox(height: 24),
        _buildPolicyItem(LucideIcons.shield, 'Safety & property',
            property.safetyItems.take(3).join('\n')),
        const SizedBox(height: 48),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(LucideIcons.flag, size: 16, color: Colors.black),
          label: const Text(
            'Report this listing',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyItem(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              const Icon(LucideIcons.chevronRight, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocation(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Where you\'ll be',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${property.city}, Indonesia',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('Map Placeholder')),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
      BuildContext context, Property property, bool isLoggedIn) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currencyFormat.format(property.priceTotal),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  property.dateRangeText.isNotEmpty
                      ? property.dateRangeText
                      : 'Select dates',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (!isLoggedIn) {
                  showLoginModal(context);
                } else {
                  context.push('/booking', extra: property);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63), // Pink-red
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Reserve',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
