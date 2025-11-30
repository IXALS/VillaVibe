import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/bookings/presentation/controllers/booking_controller.dart';
import 'package:villavibe/features/bookings/presentation/screens/trip_details_screen.dart';
import 'package:villavibe/features/bookings/presentation/widgets/hero_boarding_pass.dart';
import 'package:villavibe/features/bookings/presentation/widgets/mini_boarding_pass.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/core/presentation/widgets/custom_snackbar.dart';

import 'package:villavibe/features/bookings/presentation/providers/booking_providers.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _resumeBooking(BuildContext context, Booking booking, Property property) {
    ref.read(bookingControllerProvider(property).notifier).resumeBooking(booking);
    context.push('/booking/qris', extra: {
      'property': property,
      'bookingId': booking.id,
    });
  }

  void _openTripDetails(BuildContext context, Booking booking, Property property) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
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
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: HeroBoardingPass(
                    booking: booking,
                    property: property,
                    isExpandedDefault: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      appBar: AppBar(
        title: Text(
          'My Trips',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.label,
          overlayColor: MaterialStateProperty.all(Colors.transparent), // Remove ripple
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return _buildEmptyState();
          }

          final now = DateTime.now();
          
          // Active = Ongoing OR Upcoming (Paid/Pending AND End > Now AND NOT Checked In)
          final active = bookings.where((b) => 
            (b.status == Booking.statusPaid || b.status == Booking.statusPending) && 
            b.endDate.isAfter(now) &&
            !b.isCheckedIn
          ).toList();
          
          // Sort: Ongoing first, then closest upcoming
          active.sort((a, b) {
             final aIsOngoing = a.startDate.isBefore(now);
             final bIsOngoing = b.startDate.isBefore(now);
             if (aIsOngoing && !bIsOngoing) return -1;
             if (!aIsOngoing && bIsOngoing) return 1;
             return a.startDate.compareTo(b.startDate);
          });

          // History = Completed OR Past OR Checked In
          final history = bookings.where((b) => 
            (b.status == Booking.statusCompleted || b.status == Booking.statusPaid) && 
            (b.endDate.isBefore(now) || b.isCheckedIn)
          ).toList();
          
          // Sort history by end date (newest first)
          history.sort((a, b) => b.endDate.compareTo(a.endDate));

          final cancelled = bookings.where((b) => 
            b.status == Booking.statusCancelled
          ).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildUpcomingList(active),
              _buildList(history),
              _buildList(cancelled),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.plane, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No trips found',
            style: GoogleFonts.outfit(
              fontSize: 18,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingList(List<Booking> bookings) {
    if (bookings.isEmpty) return _buildEmptyState();

    final firstBooking = bookings.first;
    final isOngoing = firstBooking.startDate.isBefore(DateTime.now());

    return ListView(
      padding: const EdgeInsets.only(top: 24, bottom: 100),
      children: [
        // Hero Section for the Next Trip
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            isOngoing ? 'HAPPENING NOW' : 'NEXT DEPARTURE',
            style: GoogleFonts.outfit(
              color: isOngoing ? Colors.green : Colors.grey[500],
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Fetch property for the first booking
        Consumer(
          builder: (context, ref, _) {
            final propertyAsync = ref.watch(propertyProvider(firstBooking.propertyId));
            return propertyAsync.when(
              data: (property) => property != null 
                  ? Hero(
                      tag: 'boarding_pass_${firstBooking.id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: HeroBoardingPass(
                          key: ValueKey(firstBooking.id),
                          booking: firstBooking, 
                          property: property,
                          onPaymentTap: () => _resumeBooking(context, firstBooking, property),
                        ),
                      ),
                    )
                  : const SizedBox(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
            );
          },
        ),

        if (bookings.length > 1) ...[
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'FUTURE TRIPS',
              style: GoogleFonts.outfit(
                color: Colors.grey[500],
                fontSize: 12,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: bookings.length - 1,
            itemBuilder: (context, index) {
              final booking = bookings[index + 1];
              return Consumer(
                builder: (context, ref, _) {
                  final propertyAsync = ref.watch(propertyProvider(booking.propertyId));
                  return propertyAsync.when(
                    data: (property) => property != null 
                        ? MiniBoardingPass(
                            booking: booking, 
                            property: property,
                            onTap: () {
                              if (booking.status == Booking.statusPending) {
                                _resumeBooking(context, booking, property);
                              } else {
                                _openTripDetails(context, booking, property);
                              }
                            },
                          )
                        : const SizedBox(),
                    loading: () => const SizedBox(height: 100),
                    error: (_, __) => const SizedBox(),
                  );
                },
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildList(List<Booking> bookings) {
    if (bookings.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Consumer(
          builder: (context, ref, _) {
            final propertyAsync = ref.watch(propertyProvider(booking.propertyId));
            return propertyAsync.when(
              data: (property) => property != null 
                  ? MiniBoardingPass(
                      booking: booking, 
                      property: property,
                      onTap: () {
                        if (booking.status == Booking.statusPending) {
                          _resumeBooking(context, booking, property);
                        } else {
                          _openTripDetails(context, booking, property);
                        }
                      },
                    )
                  : const SizedBox(),
              loading: () => const SizedBox(height: 100),
              error: (_, __) => const SizedBox(),
            );
          },
        );
      },
    );
  }
}
