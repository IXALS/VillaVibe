import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/bookings/presentation/controllers/booking_controller.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class QrisPaymentScreen extends ConsumerStatefulWidget {
  final Property property;
  final String? bookingId;
  final String? qrString;

  const QrisPaymentScreen({
    super.key,
    required this.property,
    this.bookingId,
    this.qrString,
  });

  @override
  ConsumerState<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends ConsumerState<QrisPaymentScreen> {
  Timer? _timer;
  int _remainingSeconds = 900; // 15 minutes default
  bool _isExpired = false;
  bool _isLoading = true;
  Booking? _booking;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  Future<void> _initializeTimer() async {
    if (widget.bookingId != null) {
      // Ensure loading state is true initially
      setState(() => _isLoading = true);
      
      try {
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
              _booking = booking; // Critical: Set the booking object here
            });
            _startTimer();
          }
        } else {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        debugPrint('Error fetching booking: $e');
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
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

      if (widget.bookingId != null) {
        await ref
            .read(bookingRepositoryProvider)
            .updateBookingStatus(widget.bookingId!, status);
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
          const SnackBar(
              content: Text('Unable to complete booking. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bookingId != null) {
      ref.listen(bookingStreamProvider(widget.bookingId!), (previous, next) {
        final booking = next.value;
        if (booking != null &&
            (booking.status == Booking.statusPaid ||
                booking.status == Booking.statusCompleted)) {
          if (mounted) {
            context.go('/booking/success');
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Slightly off-white background
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
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_isExpired) ...[
                      const Icon(LucideIcons.alertCircle,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Booking Expired',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please make a new booking request.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ] else ...[
                      // Timer Section
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F5), // Light pink bg
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.timer,
                                size: 16, color: Color(0xFFE91E63)),
                            const SizedBox(width: 8),
                            Text(
                              'Pay within $_timerText',
                              style: const TextStyle(
                                color: Color(0xFFE91E63),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Payment Details Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Payment for',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.property.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 24),
                            const Text(
                              'Total Payment',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _booking != null
                                  ? 'Rp ${_booking!.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'
                                  : 'Rp -',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 24),

                            // QR Code
                            if (widget.qrString != null || _booking?.qrString != null)
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: QrImageView(
                                      data: widget.qrString ?? _booking?.qrString ?? '',
                                      version: QrVersions.auto,
                                      size: 220.0,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Scan with any e-wallet app',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildPaymentLogo('GoPay'),
                                      const SizedBox(width: 12),
                                      _buildPaymentLogo('OVO'),
                                      const SizedBox(width: 12),
                                      _buildPaymentLogo('Dana'),
                                      const SizedBox(width: 12),
                                      _buildPaymentLogo('ShopeePay'),
                                    ],
                                  ),
                                ],
                              )
                            else
                              const Text('Error: QR Code not available'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Order ID
                      if (widget.bookingId != null)
                        Text(
                          'Order ID: ${widget.bookingId}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPaymentLogo(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
