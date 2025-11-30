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
import 'package:villavibe/features/messages/domain/models/message_thread.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/messages/data/message_repository.dart';
import 'package:villavibe/features/bookings/data/services/payment_service.dart';

class BookingFlowWrapper extends ConsumerStatefulWidget {
  final Property property;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const BookingFlowWrapper({
    super.key,
    required this.property,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  ConsumerState<BookingFlowWrapper> createState() => _BookingFlowWrapperState();
}

class _BookingFlowWrapperState extends ConsumerState<BookingFlowWrapper> {
  @override
  void initState() {
    super.initState();
    if (widget.initialStartDate != null && widget.initialEndDate != null) {
      // Schedule the update after the first frame to ensure the provider is initialized
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(bookingControllerProvider(widget.property).notifier)
            .updateDates(widget.initialStartDate!, widget.initialEndDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingControllerProvider(widget.property));
    final controller = ref.read(bookingControllerProvider(widget.property).notifier);

    // Determine which content to show based on current step
    Widget content;
    switch (bookingState.currentStep) {
      case 0:
        content = BookingReviewContent(property: widget.property);
        break;
      case 1:
        content = BookingPaymentContent(property: widget.property);
        break;
      case 2:
        content = BookingMessageContent(property: widget.property);
        break;
      case 3:
        content = RequestToBookContent(property: widget.property);
        break;
      default:
        content = BookingReviewContent(property: widget.property);
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
      // Create booking
      final user = ref.read(currentUserProvider).value!;
      final booking = Booking(
        id: '', // Repo handles ID
        propertyId: widget.property.id,
        guestId: user.uid,
        hostId: widget.property.hostId,
        startDate: bookingState.checkInDate,
        endDate: bookingState.checkOutDate,
        totalPrice: bookingState.totalPrice,
        status: Booking.statusPending,
        messageToHost: bookingState.messageToHost,
        guestCount: bookingState.guestCount,
        createdAt: DateTime.now(),
      );

      final bookingId =
          await ref.read(bookingRepositoryProvider).createBooking(booking);

      final newThread = MessageThread(
        id: bookingId,
        name: widget.property.hostName ?? "Host",
        lastMessage: bookingState.messageToHost,
        avatarUrl: "https://i.pravatar.cc/150?u=$bookingId",
        timestamp: DateTime.now(),
        unread: false,
        tripStatus: "Pending approval",
        subtitle: "${bookingState.checkInDate} - ${bookingState.checkOutDate}",
        otherUserId: widget.property.hostId,
      );

      ref.read(messageThreadsProvider.notifier).addThread(newThread);

      // Create Midtrans Transaction
      final paymentData = await ref.read(paymentServiceProvider).createTransaction(
        bookingId: bookingId,
        amount: (bookingState.totalPrice as num).toDouble(),
      );

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close overlay
        controller.nextStep(); 

        // Navigate to Payment Screen with QR String
        context.push('/booking/qris', extra: {
          'property': widget.property,
          'bookingId': bookingId,
          'qrString': paymentData['qrString'],
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

