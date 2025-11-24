import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/bookings/presentation/controllers/booking_controller.dart';
import 'package:villavibe/features/bookings/presentation/widgets/booking_message_content.dart';
import 'package:villavibe/features/bookings/presentation/widgets/booking_payment_content.dart';
import 'package:villavibe/features/bookings/presentation/widgets/booking_progress_bar.dart';
import 'package:villavibe/features/bookings/presentation/widgets/booking_review_content.dart';
import 'package:villavibe/features/bookings/presentation/widgets/request_to_book_content.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class BookingFlowWrapper extends ConsumerWidget {
  final Property property;

  const BookingFlowWrapper({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingControllerProvider(property));
    final controller = ref.read(bookingControllerProvider(property).notifier);

    // Determine which content to show based on current step
    Widget content;
    switch (bookingState.currentStep) {
      case 0:
        content = BookingReviewContent(property: property);
        break;
      case 1:
        content = BookingPaymentContent(property: property);
        break;
      case 2:
        content = BookingMessageContent(property: property);
        break;
      case 3:
        content = RequestToBookContent(property: property);
        break;
      default:
        content = BookingReviewContent(property: property);
    }

    return PopScope(
      canPop: bookingState.currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (bookingState.currentStep > 0) {
          controller.previousStep();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
            onPressed: () {
              if (bookingState.currentStep > 0) {
                controller.previousStep();
              } else {
                context.pop();
              }
            },
          ),
          title: bookingState.currentStep == 3
              ? const Text(
                  'Request to book',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )
              : null,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (Widget child, Animation<double> animation) {
            final inAnimation = Tween<Offset>(
              begin: const Offset(0.05, 0.0),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut));

            final fadeAnimation =
                CurvedAnimation(parent: animation, curve: Curves.easeInOut);

            return SlideTransition(
              position: inAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(bookingState.currentStep),
            child: content,
          ),
        ),
        bottomNavigationBar:
            _buildBottomBar(context, ref, controller, bookingState),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref,
      BookingController controller, dynamic bookingState) {
    // Step 1: Review -> Next
    // Step 2: Payment -> Next
    // Step 3: Message -> Next
    // Step 4: Request -> Request to book

    // Note: bookingState.currentStep is 0-indexed.
    // 0: Review (Progress 1/5)
    // 1: Payment (Progress 2/5)
    // 2: Message (Progress 3/5)
    // 3: Request (Progress 4/5)

    // Progress bar expects 1-based index for display?
    // Let's check BookingProgressBar implementation.
    // It uses `currentStep` and `totalSteps`.
    // In previous screens:
    // Review: currentStep 1
    // Payment: currentStep 2
    // Message: currentStep 3
    // Request: currentStep 4

    final progressStep = bookingState.currentStep + 1;
    final isLastStep = bookingState.currentStep == 3;

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
            BookingProgressBar(currentStep: progressStep),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isLastStep) {
                    _handleRequestToBook(
                        context, ref, controller, bookingState);
                  } else {
                    controller.nextStep();
                  }
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
                child: Text(
                  isLastStep ? 'Request to book' : 'Next',
                  style: const TextStyle(
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

  void _handleRequestToBook(BuildContext context, WidgetRef ref,
      BookingController controller, dynamic bookingState) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Creating booking...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      // Create pending booking
      final user = ref.read(currentUserProvider).value!;
      final booking = Booking(
        id: '', // Repo handles ID
        propertyId: property.id,
        guestId: user.uid,
        hostId: property.hostId,
        startDate: bookingState.checkInDate,
        endDate: bookingState.checkOutDate,
        totalPrice: bookingState.totalPrice,
        status: Booking.statusPending,
        messageToHost: bookingState.messageToHost,
        createdAt: DateTime.now(),
      );

      final bookingId =
          await ref.read(bookingRepositoryProvider).createBooking(booking);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close overlay
        controller
            .nextStep(); // Move to step 4 (QRIS) internally if needed, but we are navigating away

        // Navigate to QRIS screen
        // Note: QRIS screen is NOT part of this wrapper flow in the original design?
        // The original design had QRIS as a separate screen.
        // The user request says "Booking Flow (Review -> Payment -> Message)".
        // It doesn't explicitly say QRIS should be in the wrapper, but "Persistent Bottom Bar... Booking Steps".
        // Usually QRIS is a result screen.
        // Let's keep QRIS as a separate route for now as it might have different bottom bar requirements (e.g. "I have paid").

        context.push('/booking/qris', extra: {
          'property': property,
          'bookingId': bookingId,
        });
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close overlay
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating booking: $e')),
        );
      }
    }
  }
}
