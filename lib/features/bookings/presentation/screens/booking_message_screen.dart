import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/bookings/presentation/controllers/booking_controller.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class BookingMessageScreen extends ConsumerStatefulWidget {
  final Property property;

  const BookingMessageScreen({super.key, required this.property});

  @override
  ConsumerState<BookingMessageScreen> createState() =>
      _BookingMessageScreenState();
}

class _BookingMessageScreenState extends ConsumerState<BookingMessageScreen> {
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking(BookingController controller) async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a message to the host')),
      );
      return;
    }

    setState(() => _isLoading = true);
    controller.setMessage(_messageController.text);

    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('User not logged in');

      final bookingState = ref.read(bookingControllerProvider(widget.property));

      final booking = Booking(
        id: '', // Repo handles ID
        propertyId: widget.property.id,
        guestId: user.uid,
        hostId: widget.property.hostId,
        startDate: bookingState.checkInDate,
        endDate: bookingState.checkOutDate,
        totalPrice: bookingState.totalPrice,
        status: 'paid', // Assume paid for demo
        messageToHost: bookingState.messageToHost,
      );

      await ref.read(bookingRepositoryProvider).createBooking(booking);

      if (mounted) {
        context.go('/booking/success');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        ref.read(bookingControllerProvider(widget.property).notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () {
            controller.previousStep();
            context.pop();
          },
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
                    'Write a message to the host',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Before you can continue, let ${widget.property.hostName} know a little about your trip and why their place is a good fit.',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _messageController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText:
                          'Example: "Hi ${widget.property.hostName}, my partner and I are going to a friend\'s wedding and your place is right down the street."',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, controller),
        ],
      ),
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _submitBooking(controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63), // Airbnb Pink
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Request to book',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
