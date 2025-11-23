import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/bookings/presentation/controllers/booking_controller.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class QrisPaymentScreen extends ConsumerStatefulWidget {
  final Property property;
  final String? bookingId;

  const QrisPaymentScreen({
    super.key,
    required this.property,
    this.bookingId,
  });

  @override
  ConsumerState<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends ConsumerState<QrisPaymentScreen> {
  Timer? _timer;
  int _remainingSeconds = 900; // 15 minutes default
  bool _isExpired = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  Future<void> _initializeTimer() async {
    if (widget.bookingId != null) {
      final booking = await ref
          .read(bookingRepositoryProvider)
          .getBooking(widget.bookingId!);

      if (!mounted) return;

      if (booking != null) {
        final now = DateTime.now();
        final difference = now.difference(booking.createdAt);
        final remaining = 900 - difference.inSeconds;

        if (remaining <= 0) {
          _handleExpiration();
        } else {
          setState(() {
            _remainingSeconds = remaining;
            _isLoading = false;
          });
          _startTimer();
        }
      } else {
        // Booking not found? Should handle error
        setState(() => _isLoading = false);
      }
    } else {
      // Legacy/Fallback: Start full timer
      if (!mounted) return;
      setState(() => _isLoading = false);
      _startTimer();
    }
  }

  void _handleExpiration() {
    setState(() {
      _isExpired = true;
      _remainingSeconds = 0;
      _isLoading = false;
    });
    _timer?.cancel();
    if (widget.bookingId != null) {
      ref
          .read(bookingRepositoryProvider)
          .updateBookingStatus(widget.bookingId!, Booking.statusCancelled);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        _handleExpiration();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerText {
    if (_remainingSeconds <= 0) return '00:00';
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _completeBooking(String status) async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) return;

      // If we have a bookingId, update the existing booking
      if (widget.bookingId != null) {
        await ref
            .read(bookingRepositoryProvider)
            .updateBookingStatus(widget.bookingId!, status);
      } else {
        // Fallback for legacy flow (shouldn't happen with new flow)
        final bookingState =
            ref.read(bookingControllerProvider(widget.property));

        final booking = Booking(
          id: '', // Repo handles ID
          propertyId: widget.property.id,
          guestId: user.uid,
          hostId: widget.property.hostId,
          startDate: bookingState.checkInDate,
          endDate: bookingState.checkOutDate,
          totalPrice: bookingState.totalPrice,
          status: status,
          messageToHost: bookingState.messageToHost,
          createdAt: DateTime.now(),
        );

        await ref.read(bookingRepositoryProvider).createBooking(booking);
      }

      if (mounted) {
        if (status == Booking.statusPaid || status == Booking.statusCompleted) {
          context.go('/booking/success');
        } else {
          context.go('/home', extra: 2);
        }
      }
    } catch (e) {
      debugPrint('Error completing booking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to complete booking. Please try again.')),
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.black),
          onPressed: () => _completeBooking(Booking.statusPending),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    'Scan QR Code to Pay',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else if (_isExpired)
                    const Column(
                      children: [
                        Icon(LucideIcons.alertCircle,
                            size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Booking Expired',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please make a new booking request.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                  else ...[
                    Text(
                      'Complete your payment within $_timerText',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFE91E63),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.qrCode,
                            size: 120, color: Colors.black54),
                      ),
                    ),
                  ],
                  const SizedBox(height: 48),
                  const Text(
                    'Simulation Controls (Debug)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isExpired
                              ? null
                              : () => _completeBooking(Booking.statusPending),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Simulate Close/Fail'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isExpired
                              ? null
                              : () => _completeBooking(Booking.statusPaid),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Simulate Success'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return const SizedBox.shrink();
  }
}
