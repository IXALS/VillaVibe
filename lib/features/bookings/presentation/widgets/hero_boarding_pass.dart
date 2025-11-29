import 'dart:async';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/bookings/data/services/weather_service.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/bookings/presentation/providers/booking_providers.dart';
import 'package:villavibe/features/bookings/presentation/screens/check_in_success_screen.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class HeroBoardingPass extends ConsumerStatefulWidget {
  final Booking booking;
  final Property property;
  final bool isExpandedDefault;
  final VoidCallback? onPaymentTap;

  const HeroBoardingPass({
    super.key,
    required this.booking,
    required this.property,
    this.isExpandedDefault = false,
    this.onPaymentTap,
  });

  @override
  ConsumerState<HeroBoardingPass> createState() => _HeroBoardingPassState();
}

class _HeroBoardingPassState extends ConsumerState<HeroBoardingPass> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  late bool _isExpanded;
  late bool _isCheckedIn;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpandedDefault;
    _isCheckedIn = widget.booking.isCheckedIn;
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateTimeLeft());
  }

  @override
  void didUpdateWidget(HeroBoardingPass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.booking.id != oldWidget.booking.id || widget.booking.isCheckedIn != oldWidget.booking.isCheckedIn) {
      setState(() {
        _isCheckedIn = widget.booking.isCheckedIn;
        // Reset expansion state if it's a completely different booking
        if (widget.booking.id != oldWidget.booking.id) {
           _isExpanded = widget.isExpandedDefault;
        }
      });
      _calculateTimeLeft();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    if (widget.booking.startDate.isAfter(now)) {
      setState(() {
        _timeLeft = widget.booking.startDate.difference(now);
      });
    } else {
      setState(() {
        _timeLeft = Duration.zero;
      });
    }
  }

  Future<void> _simulateScan() async {
    setState(() => _isScanning = true);
    try {
      // 1. Simulate Scan Delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // 2. Optimistic Local Update
        setState(() {
          _isScanning = false;
          _isCheckedIn = true;
        });

        // 3. Show Success Modal
        // We show this BEFORE updating the backend to ensure the widget is still mounted.
        // If we update backend first, the StreamProvider might fire, removing this widget from the tree,
        // causing showModalBottomSheet to never be called or fail.
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => CheckInSuccessScreen(property: widget.property),
        );
        
        // 4. Update Backend & Refresh
        // Now that the modal is closed, we can safely update the backend.
        // This will likely trigger the StreamProvider to update, removing this card.
        final repository = ref.read(bookingRepositoryProvider);
        await repository.updateCheckInStatus(widget.booking.id, true);
        
        // Explicit invalidation just in case
        ref.invalidate(userBookingsProvider);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-in failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherService = ref.read(weatherServiceProvider);
    final weatherAsync = ref.watch(weatherProvider('${widget.property.location.latitude},${widget.property.location.longitude}'));
    
    final isPending = widget.booking.status == Booking.statusPending;
    final now = DateTime.now();
    final isOngoing = widget.booking.startDate.isBefore(now) && widget.booking.endDate.isAfter(now);
    
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Main Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Image Header with Glass Overlay
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: CachedNetworkImage(
                        imageUrl: widget.property.images.first,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          height: 220,
                          color: Colors.grey[300],
                          child: const Icon(LucideIcons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content Overlay
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.property.name,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              weatherAsync.when(
                                data: (data) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        weatherService.getWeatherIcon(data['code']),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${data['temp']}°',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                loading: () => const SizedBox(),
                                error: (_, __) => const SizedBox(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(LucideIcons.mapPin, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                widget.property.city,
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Countdown Timer or Payment/Status (Top Right)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isPending 
                                  ? Colors.orange.withOpacity(0.9) 
                                  : (_isCheckedIn 
                                      ? Colors.blue.withOpacity(0.9)
                                      : (isOngoing ? Colors.green.withOpacity(0.9) : Colors.black.withOpacity(0.6))),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  isPending 
                                      ? 'PAYMENT REQUIRED' 
                                      : (_isCheckedIn 
                                          ? 'CHECKED IN' 
                                          : (isOngoing ? 'HAPPENING NOW' : 'CHECK-IN IN')),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 10,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (!isPending && !_isCheckedIn && !isOngoing && _timeLeft.inSeconds > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_timeLeft.inDays}d ${_timeLeft.inHours % 24}h',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                                if (_isCheckedIn || isOngoing) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Enjoy your stay!',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Ticket Details
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTicketInfo('CHECK-IN', DateFormat('MMM d').format(widget.booking.startDate)),
                      _buildTicketInfo('CHECK-OUT', DateFormat('MMM d').format(widget.booking.endDate)),
                      _buildTicketInfo('GUESTS', '${widget.booking.guestCount}'),
                      _buildTicketInfo('GATE', 'V-${widget.booking.id.substring(0, 3).toUpperCase()}'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Perforated Line
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 1,
            child: Row(
              children: List.generate(
                20,
                (index) => Expanded(
                  child: Container(
                    color: index % 2 == 0 ? Colors.grey[300] : Colors.transparent,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Tear-off Section
          GestureDetector(
            onTap: isPending ? widget.onPaymentTap : () => setState(() => _isExpanded = !_isExpanded),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isPending ? Colors.orange[50] : (_isCheckedIn ? Colors.blue[50] : Colors.white),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isPending ? Colors.orange : (_isCheckedIn ? Colors.blue : Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isPending ? LucideIcons.creditCard : (_isCheckedIn ? LucideIcons.check : LucideIcons.qrCode), 
                              color: Colors.white, 
                              size: 20
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPending ? 'Complete Payment' : (_isCheckedIn ? 'You are all set' : 'Boarding Pass'),
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isPending ? Colors.orange[900] : (_isCheckedIn ? Colors.blue[900] : Colors.black),
                                ),
                              ),
                              Text(
                                isPending ? 'Tap to pay now' : (_isCheckedIn ? 'Enjoy your trip' : 'Tap to scan'),
                                style: GoogleFonts.outfit(
                                  color: isPending ? Colors.orange[700] : (_isCheckedIn ? Colors.blue[700] : Colors.grey),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Icon(
                        isPending ? LucideIcons.chevronRight : (_isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown),
                        color: isPending ? Colors.orange[300] : (_isCheckedIn ? Colors.blue[300] : Colors.grey),
                      ),
                    ],
                  ),
                  if (!isPending && _isExpanded) ...[
                    const SizedBox(height: 20),
                    if (_isCheckedIn)
                      Column(
                        children: [
                          Icon(LucideIcons.checkCircle, size: 64, color: Colors.blue[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Check-in Verified',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          Text(
                            'Have a wonderful stay!',
                            style: GoogleFonts.outfit(
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Center(
                            child: QrImageView(
                              data: widget.booking.id,
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.booking.id.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: Colors.grey,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isScanning ? null : _simulateScan,
                              icon: _isScanning 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(LucideIcons.scanLine, size: 18),
                              label: Text(_isScanning ? 'Verifying...' : 'Simulate Host Scan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.grey[400],
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
