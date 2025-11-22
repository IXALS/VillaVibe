import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/auth/presentation/widgets/login_modal.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';

class VillaDetailScreen extends ConsumerWidget {
  final String propertyId;

  const VillaDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyProvider(propertyId));
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: propertyAsync.when(
        data: (property) {
          if (property == null) {
            return const Center(child: Text('Property not found'));
          }
          return _buildContent(context, property);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: propertyAsync.value != null
          ? _buildBottomBar(
              context,
              propertyAsync.value!,
              authState.maybeWhen(
                data: (user) => user != null,
                orElse: () => false,
              ))
          : null,
    );
  }

  Widget _buildContent(BuildContext context, Property property) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, property),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildHeader(property),
                const Divider(height: 48),
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
                _buildAvailability(),
                const Divider(height: 48),
                _buildThingsToKnow(property),
                const Divider(height: 48),
                _buildLocation(property),
                const SizedBox(height: 100), // Bottom padding for fixed bar
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Property property) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          icon:
              const Icon(LucideIcons.arrowLeft, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ).animate().fadeIn(delay: 200.ms),
      actions: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(LucideIcons.share, color: Colors.black, size: 20),
            onPressed: () {},
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(width: 12),
        CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(LucideIcons.heart, color: Colors.black, size: 20),
            onPressed: () {},
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(width: 24),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            property.images.isNotEmpty
                ? Image.network(
                    property.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey[200]),
                  )
                : Container(color: Colors.grey[200]),
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '1/${property.images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
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
          child: Column(
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
        Row(
          children: [
            const Text(
              'Show more',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(LucideIcons.chevronRight, size: 16),
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

  Widget _buildAvailability() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Availability',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text('Nov 21 - 23'),
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
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=2074&auto=format&fit=crop', // Placeholder map image
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child:
                            Icon(LucideIcons.map, color: Colors.grey, size: 48),
                      ),
                    );
                  },
                ),
              ),
              // TODO: Replace with real Google Maps implementation using a valid API key
              // 'https://maps.googleapis.com/maps/api/staticmap?center=-6.2088,106.8456&zoom=13&size=600x300&key=YOUR_API_KEY_HERE'
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.home, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
      BuildContext context, Property property, bool isLoggedIn) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currencyFormat.format(property.pricePerNight),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Total before taxes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (isLoggedIn) {
                  context.push('/booking', extra: property);
                } else {
                  showLoginModal(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63), // Pink/Red
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
