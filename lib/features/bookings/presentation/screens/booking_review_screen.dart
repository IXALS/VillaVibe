import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/bookings/presentation/controllers/booking_controller.dart';
import 'package:villavibe/features/bookings/presentation/widgets/booking_progress_bar.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class BookingReviewScreen extends ConsumerWidget {
  final Property property;

  const BookingReviewScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingControllerProvider(property));
    final controller = ref.read(bookingControllerProvider(property).notifier);

    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Review and continue',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildVillaSummaryCard(property),
                  const SizedBox(height: 32),
                  _buildTripDetailsSection(context, bookingState, controller),
                  const SizedBox(height: 32),
                  _buildPriceDetailsSection(
                      context, bookingState, property, currencyFormat),
                  const SizedBox(height: 32),
                  _buildCancellationPolicy(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, controller),
        ],
      ),
    );
  }

  Widget _buildVillaSummaryCard(Property property) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              property.images.first,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.star,
                            size: 14, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          '${property.rating} (${property.reviewsCount})',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    if (property.rating >= 4.8)
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.trophy,
                              size: 14, color: Colors.black54),
                          SizedBox(width: 4),
                          Text(
                            'Guest favorite',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
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

  Widget _buildTripDetailsSection(BuildContext context, dynamic bookingState,
      BookingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          context,
          'Dates',
          '${DateFormat('MMM d').format(bookingState.checkInDate)} – ${DateFormat('d, yyyy').format(bookingState.checkOutDate)}',
          'Change',
          () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDateRange: DateTimeRange(
                start: bookingState.checkInDate,
                end: bookingState.checkOutDate,
              ),
            );
            if (picked != null) {
              controller.updateDates(picked.start, picked.end);
            }
          },
        ),
        const Divider(height: 32),
        _buildDetailRow(
          context,
          'Guests',
          '${bookingState.guestCount} guest${bookingState.guestCount > 1 ? 's' : ''}',
          'Change',
          () {
            _showGuestEditModal(context, bookingState.guestCount, controller);
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, String value,
      String actionText, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          child: Text(actionText),
        ),
      ],
    );
  }

  Widget _buildPriceDetailsSection(BuildContext context, dynamic bookingState,
      Property property, NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total price',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${currencyFormat.format(bookingState.totalPrice)} IDR',
              style: const TextStyle(
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
            TextButton(
              onPressed: () {
                _showPriceDetailsModal(
                    context, bookingState, property, currencyFormat);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCancellationPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Free cancellation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Cancel before check-in for a full refund.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Full policy',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, BookingController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Colors.black12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BookingProgressBar(currentStep: 1),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.nextStep();
                  context.push('/booking/payment', extra: property);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Airbnb uses black for "Next"
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuestEditModal(
      BuildContext context, int currentGuests, BookingController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        int guests = currentGuests;
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Guests',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Adults', style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: guests > 1
                                ? () {
                                    setState(() => guests--);
                                    controller.updateGuests(guests);
                                  }
                                : null,
                            icon: const Icon(LucideIcons.minusCircle),
                          ),
                          Text('$guests', style: const TextStyle(fontSize: 16)),
                          IconButton(
                            onPressed: () {
                              setState(() => guests++);
                              controller.updateGuests(guests);
                            },
                            icon: const Icon(LucideIcons.plusCircle),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPriceDetailsModal(BuildContext context, dynamic bookingState,
      Property property, NumberFormat currencyFormat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${bookingState.nights} nights x ${currencyFormat.format(property.pricePerNight)}'),
                  Text(currencyFormat.format(bookingState.totalPrice)),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total IDR',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    currencyFormat.format(bookingState.totalPrice),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Price breakdown',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
