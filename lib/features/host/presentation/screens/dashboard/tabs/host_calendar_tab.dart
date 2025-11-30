import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'dart:ui';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/auth/domain/models/app_user.dart';
import 'package:villavibe/features/host/presentation/widgets/occupancy_pulse.dart';
import 'package:villavibe/core/presentation/widgets/custom_snackbar.dart';


import 'package:villavibe/features/host/presentation/widgets/calendar_month_view.dart';

class HostCalendarTab extends ConsumerStatefulWidget {
  const HostCalendarTab({super.key});

  @override
  ConsumerState<HostCalendarTab> createState() => _HostCalendarTabState();
}

class _HostCalendarTabState extends ConsumerState<HostCalendarTab>
    with AutomaticKeepAliveClientMixin {
  String? _selectedPropertyId;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in'));
    }

    final propertiesAsync = ref.watch(hostPropertiesProvider(user.uid));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: propertiesAsync.when(
          data: (properties) {
            if (properties.isEmpty) return const Text('Calendar');
            
            final selectedProperty = _selectedPropertyId == null
                ? properties.first
                : properties.firstWhere(
                    (p) => p.id == _selectedPropertyId,
                    orElse: () => properties.first,
                  );

            return _buildPropertySelector(properties, selectedProperty);
          },
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Calendar'),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: propertiesAsync.when(
        data: (properties) {
          if (properties.isEmpty) return const Center(child: Text('No properties found'));

          final selectedProperty = _selectedPropertyId == null
              ? properties.first
              : properties.firstWhere(
                  (p) => p.id == _selectedPropertyId,
                  orElse: () => properties.first,
                );

          return StreamBuilder<List<Booking>>(
            stream: ref
                .read(bookingRepositoryProvider)
                .getPropertyBookingsStream(selectedProperty.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final bookings = snapshot.data ?? [];
              final now = DateTime.now();

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: 13, // Pulse + 12 months
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return OccupancyPulse(bookings: bookings);
                  }
                  final monthIndex = index - 1;
                  final month = DateTime(now.year, now.month + monthIndex, 1);
                  return CalendarMonthView(
                    month: month,
                    bookings: bookings,
                    pricePerNight: selectedProperty.pricePerNight,
                    customPrices: selectedProperty.customPrices,
                    onDayTap: (date) => _showDayDetails(context, date, bookings, selectedProperty),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildPropertySelector(List<Property> properties, Property selectedProperty) {
    if (properties.length == 1) {
      return Text(
        properties.first.name,
        style: GoogleFonts.outfit(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showPropertyPicker(properties),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              selectedProperty.name,
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(LucideIcons.chevronDown, color: Colors.black, size: 20),
        ],
      ),
    );
  }

  void _showPropertyPicker(List<Property> properties) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          ...properties.map((p) => ListTile(
                title: Text(
                  p.name,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
                trailing: _selectedPropertyId == p.id
                    ? const Icon(Icons.check, color: Colors.black)
                    : null,
                onTap: () {
                  setState(() => _selectedPropertyId = p.id);
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showDayDetails(BuildContext context, DateTime date, List<Booking> bookings, Property property) {
    // Find booking for this date
    final booking = bookings.firstWhere(
      (b) {
        final start = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
        final end = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
        return (date.isAtSameMomentAs(start) || date.isAfter(start)) && date.isBefore(end);
      },
      orElse: () => Booking(
        id: '',
        propertyId: '',
        guestId: '',
        hostId: '',
        startDate: DateTime(1900),
        endDate: DateTime(1900),
        totalPrice: 0,
        status: 'none',
        messageToHost: '',
        guestCount: 0,
        createdAt: DateTime.now(),
      ),
    );


    final isBooked = booking.status == 'paid' || booking.status == 'confirmed';
    final isBlocked = booking.status == 'blocked';
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(date),
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (isBlocked) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.ban, color: Colors.grey),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Blocked by you',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            await ref.read(bookingRepositoryProvider).unblockDates(booking.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Date unblocked')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Unblock'),
                      ),
                    ],
                  ),
                ),

              ] else if (isBooked) ...[
                FutureBuilder<AppUser?>(
                  future: ref.read(authRepositoryProvider).getUserById(booking.guestId),
                  builder: (context, snapshot) {
                    final guest = snapshot.data;
                    final guestName = guest?.displayName ?? 'Guest';
                    final guestAvatar = guest?.photoUrl ?? '';

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: guestAvatar.isNotEmpty ? NetworkImage(guestAvatar) : null,
                            backgroundColor: Colors.white,
                            child: guestAvatar.isEmpty ? const Icon(LucideIcons.user, color: Colors.black) : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  guestName,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${booking.guestCount} guests · ${currencyFormat.format(booking.totalPrice)}',
                                  style: GoogleFonts.outfit(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                ),
              ] else ...[
                Builder(
                  builder: (context) {
                    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                    final priceForDate = property.customPrices[dateStr] ?? property.pricePerNight;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price for this night',
                          style: GoogleFonts.outfit(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              currencyFormat.format(priceForDate),
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: property.customPrices.containsKey(dateStr) ? const Color(0xFFE91E63) : Colors.black,
                              ),
                            ),
                            if (property.customPrices.containsKey(dateStr)) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE91E63).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Custom',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFE91E63),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditPriceModal(context, property, date);
                              },
                              child: const Text('Edit'),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        // Block for 1 day
                        await ref.read(bookingRepositoryProvider).blockDates(
                          property.id,
                          date,
                          date.add(const Duration(days: 1)),
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Date blocked')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(LucideIcons.ban, size: 18),
                    label: const Text('Block this date'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditPriceModal(BuildContext context, Property property, DateTime date) {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final currentPrice = property.customPrices[dateStr] ?? property.pricePerNight;
    final controller = TextEditingController(text: currentPrice.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Edit Price for ${DateFormat('MMM d').format(date)}',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This will update the price for this specific date only.',
                style: GoogleFonts.outfit(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price per night',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final newPrice = int.tryParse(controller.text);
                    if (newPrice != null && newPrice > 0) {
                      try {
                        await ref.read(propertyRepositoryProvider).setCustomPrice(property.id, date, newPrice);
                        if (context.mounted) {
                          Navigator.pop(context);
                          showCustomSnackBar(
                            context,
                            message: 'Price updated successfully',
                            icon: LucideIcons.checkCircle,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showCustomSnackBar(
                            context,
                            message: 'Error: $e',
                            isError: true,
                            icon: LucideIcons.alertCircle,
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Update Price',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
