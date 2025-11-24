import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villavibe/features/bookings/presentation/controllers/booking_controller.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class BookingMessageContent extends ConsumerStatefulWidget {
  final Property property;

  const BookingMessageContent({super.key, required this.property});

  @override
  ConsumerState<BookingMessageContent> createState() =>
      _BookingMessageContentState();
}

class _BookingMessageContentState extends ConsumerState<BookingMessageContent> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with existing message if any
    final bookingState = ref.read(bookingControllerProvider(widget.property));
    if (bookingState.messageToHost.isNotEmpty) {
      _messageController.text = bookingState.messageToHost;
    }

    _messageController.addListener(_onMessageChanged);
  }

  void _onMessageChanged() {
    ref
        .read(bookingControllerProvider(widget.property).notifier)
        .setMessage(_messageController.text);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
    );
  }
}
