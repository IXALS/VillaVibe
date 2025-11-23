import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/bookings/presentation/controllers/booking_controller.dart';
import 'package:villavibe/features/bookings/presentation/widgets/booking_progress_bar.dart';
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

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BookingProgressBar(currentStep: 3),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_messageController.text.trim().isNotEmpty) {
                    controller.setMessage(_messageController.text);
                  }
                  controller.nextStep();
                  context.push('/booking/request', extra: widget.property);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
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
}
