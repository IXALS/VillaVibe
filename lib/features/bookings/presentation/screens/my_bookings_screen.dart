import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/bookings/presentation/controllers/booking_controller.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

final userBookingsProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(bookingRepositoryProvider).getUserBookings(user.uid);
});

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Trips',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null, // No back button for main tab
        automaticallyImplyLeading: false,
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.calendarX, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No trips yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _BookingCard(booking: booking);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyProvider(booking.propertyId));

    return propertyAsync.when(
      data: (property) {
        if (property == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () {
            if (booking.status == Booking.statusPending) {
              _resumeBooking(context, ref, booking, property);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: property.images.isNotEmpty
                          ? Image.network(
                              property.images.first,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 180,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Icon(LucideIcons.image,
                                      size: 48, color: Colors.white),
                                );
                              },
                            )
                          : Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(LucideIcons.image,
                                  size: 48, color: Colors.white),
                            ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: _buildStatusTag(booking.status),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${DateFormat('MMM d').format(booking.startDate)} – ${DateFormat('MMM d, yyyy').format(booking.endDate)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        height: 250,
        margin: const EdgeInsets.only(bottom: 24),
        color: Colors.grey[100],
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color;
    String text;

    switch (status) {
      case Booking.statusPending:
        color = Colors.orange;
        text = 'Awaiting Payment';
        break;
      case Booking.statusPaid:
      case Booking.statusCompleted:
        color = Colors.green;
        text = 'Confirmed';
        break;
      case Booking.statusCancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _resumeBooking(
      BuildContext context, WidgetRef ref, Booking booking, Property property) {
    // Initialize controller with existing booking data
    ref
        .read(bookingControllerProvider(property).notifier)
        .resumeBooking(booking);

    // Navigate to QRIS screen with bookingId
    context.push('/booking/qris', extra: {
      'property': property,
      'bookingId': booking.id,
    });
  }
}
