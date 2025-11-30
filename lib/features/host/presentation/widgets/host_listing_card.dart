import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import '../../../bookings/data/repositories/booking_repository.dart';
import '../../../bookings/domain/models/booking.dart';
import '../../../bookings/domain/models/booking.dart';
import '../../../properties/data/repositories/property_repository.dart';
import '../../../properties/domain/models/property.dart';

class HostListingCard extends ConsumerWidget {
  final Property property;

  const HostListingCard({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image & Status Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: CachedNetworkImage(
                    imageUrl: property.images.isNotEmpty
                        ? property.images.first
                        : 'https://via.placeholder.com/400x300',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Title, Location & Price Overlay
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Title & Location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.name,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(LucideIcons.mapPin,
                                  color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  property.city,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Price Edit Button
                    GestureDetector(
                      onTap: () => _showPriceEditDialog(context, ref),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(
                                  currencyFormat.format(property.pricePerNight),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(LucideIcons.pencil,
                                    size: 12, color: Colors.white70),
                              ],
                            ),
                            Text(
                              'per night',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge (Top Right)
              Positioned(
                top: 16,
                right: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: property.isListed
                            ? const Color(0xFF10B981).withValues(alpha: 0.8)
                            : Colors.grey[800]!.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        property.isListed ? 'LIVE' : 'UNLISTED',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inline Price Edit (Removed)

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Async Booking Count & Earnings
                    StreamBuilder<List<Booking>>(
                      stream: ref
                          .read(bookingRepositoryProvider)
                          .getPropertyBookingsStream(property.id),
                      builder: (context, snapshot) {
                        final bookings = snapshot.data ?? [];
                        final count = bookings.length;

                        // Calculate Earnings (Current Month)
                        final now = DateTime.now();
                        final earnings = bookings
                            .where((b) =>
                                b.startDate.month == now.month &&
                                b.startDate.year == now.year &&
                                (b.status == Booking.statusPaid ||
                                    b.status == Booking.statusCompleted))
                            .fold<int>(0, (sum, b) => sum + b.totalPrice);

                        return Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStat(
                                LucideIcons.star,
                                '${property.rating}',
                                '${property.reviewsCount} reviews',
                              ),
                              _buildStat(
                                LucideIcons.calendarCheck,
                                '$count',
                                'Bookings',
                              ),
                              _buildStat(
                                LucideIcons.wallet,
                                NumberFormat.compactCurrency(
                                        locale: 'id_ID', symbol: 'Rp')
                                    .format(earnings),
                                'Est. Earnings',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Availability Strip
                StreamBuilder<List<Booking>>(
                  stream: ref
                      .read(bookingRepositoryProvider)
                      .getPropertyBookingsStream(property.id),
                  builder: (context, snapshot) {
                    final bookings = snapshot.data ?? [];
                    return _AvailabilityStrip(bookings: bookings);
                  },
                ),

                const SizedBox(height: 24),

                // Quick Actions Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickAction(
                      context,
                      icon: property.isListed
                          ? LucideIcons.eyeOff
                          : LucideIcons.eye,
                      label: property.isListed ? 'Snooze' : 'Activate',
                      onTap: () {
                        final updated =
                            property.copyWith(isListed: !property.isListed);
                        ref
                            .read(propertyRepositoryProvider)
                            .updateProperty(updated);
                      },
                    ),
                    _buildQuickAction(
                      context,
                      icon: LucideIcons.smartphone,
                      label: 'Preview',
                      onTap: () {
                        context.push('/property/${property.id}', extra: property);
                      },
                    ),
                    // Share button removed to prevent overflow
                    _buildQuickAction(
                      context,
                      icon: LucideIcons.edit,
                      label: 'Edit',
                      onTap: () {
                        context.push('/host/onboarding', extra: property);
                      },
                    ),

                    _buildQuickAction(
                      context,
                      icon: LucideIcons.trash2,
                      label: 'Delete',
                      onTap: () => _showDeleteConfirmation(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.black87),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return _ScaleButton(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 18, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceEditDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PriceEditSheet(
        initialPrice: property.pricePerNight,
        onSave: (newPrice) {
          final updated = property.copyWith(pricePerNight: newPrice);
          ref.read(propertyRepositoryProvider).updateProperty(updated);
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeleteConfirmationSheet(
        propertyName: property.name,
        onConfirm: () {
          ref.read(propertyRepositoryProvider).deleteProperty(property.id);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ScaleButton({required this.child, required this.onTap});

  @override
  State<_ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<_ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

class _AvailabilityStrip extends StatelessWidget {
  final List<Booking> bookings;

  const _AvailabilityStrip({required this.bookings});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next7Days = List.generate(7, (index) => today.add(Duration(days: index)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AVAILABILITY (NEXT 7 DAYS)',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
                letterSpacing: 1,
              ),
            ),
            // Legend
            Row(
              children: [
                _buildLegendDot(Colors.green, 'Free'),
                const SizedBox(width: 8),
                _buildLegendDot(Colors.red, 'Booked'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: next7Days.map((date) {
            final isBooked = bookings.any((b) {
              if (b.status == Booking.statusCompleted || b.status == Booking.statusCancelled) {
                return false;
              }
              
              // Check if date falls within booking range
              // Start date is inclusive, End date is exclusive for "stay" purposes usually,
              // but let's check overlap.
              // A booking from 1st to 3rd means nights of 1st and 2nd.
              // So if date is 1st or 2nd, it's booked.
              final bookingStart = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
              final bookingEnd = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
              
              // Check if date is >= start AND < end
              return (date.isAtSameMomentAs(bookingStart) || date.isAfter(bookingStart)) && 
                     date.isBefore(bookingEnd);
            });

            final isToday = date.isAtSameMomentAs(today);
            final color = isBooked ? Colors.red : Colors.green;
            final bgColor = color.withValues(alpha: 0.1);
            final borderColor = color.withValues(alpha: 0.3);

            return Tooltip(
              message: DateFormat('EEEE, MMM d').format(date) + (isBooked ? ' (Booked)' : ' (Available)'),
              triggerMode: TooltipTriggerMode.tap,
              child: Container(
                width: 40,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(date)[0], // M, T, W
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: color.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d').format(date), // 12
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

class _PriceEditSheet extends StatefulWidget {
  final int initialPrice;
  final Function(int) onSave;

  const _PriceEditSheet({required this.initialPrice, required this.onSave});

  @override
  State<_PriceEditSheet> createState() => _PriceEditSheetState();
}

class _PriceEditSheetState extends State<_PriceEditSheet> {
  late int _price;
  late TextEditingController _controller;
  final _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _price = widget.initialPrice;
    _controller = TextEditingController(
        text: _currencyFormat.format(_price).replaceAll('Rp', '').trim());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updatePrice(int delta) {
    setState(() {
      _price = (_price + delta).clamp(0, 100000000); // Max 100jt
      _controller.text =
          _currencyFormat.format(_price).replaceAll('Rp', '').trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 12,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Set your price',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'per night',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),

          // Price Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircleButton(
                icon: LucideIcons.minus,
                onTap: () => _updatePrice(-50000),
                enabled: _price > 0,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    // Simple parsing for now, could be more robust
                    final clean = value.replaceAll('.', '').replaceAll(',', '');
                    final newPrice = int.tryParse(clean);
                    if (newPrice != null) {
                      setState(() => _price = newPrice);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              _buildCircleButton(
                icon: LucideIcons.plus,
                onTap: () => _updatePrice(50000),
                enabled: true,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(_price);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(
      {required IconData icon,
      required VoidCallback onTap,
      required bool enabled}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? Colors.grey[300]! : Colors.grey[100]!,
          ),
          color: enabled ? Colors.white : Colors.grey[50],
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.black : Colors.grey[300],
          size: 24,
        ),
      ),
    );
  }
}

class _DeleteConfirmationSheet extends StatelessWidget {
  final String propertyName;
  final VoidCallback onConfirm;

  const _DeleteConfirmationSheet({
    required this.propertyName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.trash2, color: Colors.red[400], size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Delete Listing?',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Are you sure you want to delete "$propertyName"?\nThis action cannot be undone.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Yes, Delete',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
