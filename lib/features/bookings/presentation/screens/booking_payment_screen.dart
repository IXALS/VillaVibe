import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';

class BookingPaymentScreen extends ConsumerStatefulWidget {
  final Property property;

  const BookingPaymentScreen({super.key, required this.property});

  @override
  ConsumerState<BookingPaymentScreen> createState() =>
      _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends ConsumerState<BookingPaymentScreen> {
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-select next 2 days as default for demo
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: now.add(const Duration(days: 1)),
      end: now.add(const Duration(days: 3)),
    );
  }

  int get _nights => _selectedDateRange!.duration.inDays;
  int get _totalPrice => widget.property.pricePerNight * _nights;

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);

    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) return;

      final booking = Booking(
        id: '', // Repo handles ID
        propertyId: widget.property.id,
        guestId: user.uid,
        hostId: widget.property.hostId,
        startDate: _selectedDateRange!.start,
        endDate: _selectedDateRange!.end,
        totalPrice: _totalPrice,
        status: 'paid', // Assume paid immediately for demo
      );

      await ref.read(bookingRepositoryProvider).createBooking(booking);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Booking Confirmed!'),
            content: const Text('Your villa is booked. Enjoy your stay!'),
            actions: [
              TextButton(
                onPressed: () {
                  context.go('/home');
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.property.name,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
                '${widget.property.city} • \$${widget.property.pricePerNight}/night'),
            const Divider(height: 32),

            // Date Selection (Simplified for demo, usually passed from detail or selected here)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dates'),
                TextButton(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: _selectedDateRange,
                    );
                    if (picked != null) {
                      setState(() => _selectedDateRange = picked);
                    }
                  },
                  child: Text(
                    '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total ($_nights nights)',
                    style: Theme.of(context).textTheme.titleMedium),
                Text('\$$_totalPrice',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            const Spacer(),

            // QRIS Placeholder
            Center(
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    color: Colors.grey[200],
                    child: const Center(
                        child: Text('QRIS Code Here',
                            textAlign: TextAlign.center)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Scan to Pay',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Pay & Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
