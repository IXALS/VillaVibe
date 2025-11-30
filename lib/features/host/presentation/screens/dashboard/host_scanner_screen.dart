import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';

class HostScannerScreen extends ConsumerStatefulWidget {
  const HostScannerScreen({super.key});

  @override
  ConsumerState<HostScannerScreen> createState() => _HostScannerScreenState();
}

class _HostScannerScreenState extends ConsumerState<HostScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Haptic feedback
    // HapticFeedback.mediumImpact(); // Need services import

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Validate Check-in
      final result = await ref
          .read(bookingRepositoryProvider)
          .validateCheckIn(code, user.uid);

      if (!mounted) return;

      if (result['success'] == true) {
        final booking = result['booking'] as Booking;
        _showSuccessSheet(booking);
      } else {
        _showErrorDialog(result['message'] ?? 'Invalid QR Code');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error: $e');
      }
    }
  }

  void _showSuccessSheet(Booking booking) async {
    // Fetch guest details for the sheet
    final guest = await ref.read(authRepositoryProvider).getUserById(booking.guestId);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.check, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Check-in Complete!',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Guest has been successfully checked in.',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (guest != null) ...[
              CircleAvatar(
                radius: 40,
                backgroundImage: guest.photoUrl.isNotEmpty
                    ? NetworkImage(guest.photoUrl)
                    : null,
                child: guest.photoUrl.isEmpty
                    ? Text(guest.displayName[0], style: const TextStyle(fontSize: 24))
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                guest.displayName,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close sheet only
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ).then((_) {
      // Close scanner when sheet is dismissed (by Done button or drag)
      if (mounted) {
         Navigator.pop(context); 
      }
    });
  }

  void _showErrorDialog(String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.x, color: Colors.red, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Check-in Failed',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isProcessing = false; // Allow scanning again
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Overlay
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // UI Elements
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.x, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black26,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _controller.toggleTorch(),
                        icon: const Icon(LucideIcons.zap, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black26,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Scan Guest Boarding Pass',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Align QR code within the frame',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                // Debug Button for Simulator
                TextButton.icon(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;
                    
                    // Fetch bookings to find a valid one for testing
                    // This is just for debugging convenience
                    final bookings = await ref.read(bookingRepositoryProvider).getHostBookings(user.uid).first;
                    if (bookings.isNotEmpty) {
                       // Try to find one for today
                       final now = DateTime.now();
                       final today = DateTime(now.year, now.month, now.day);
                       
                       String? testId;
                       for (var b in bookings) {
                         final start = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
                         if (start.isAtSameMomentAs(today) && !b.isCheckedIn) {
                           testId = b.id;
                           break;
                         }
                       }
                       
                       // If no today booking, just pick the first one to test the flow (it might fail validation, which is fine)
                       testId ??= bookings.first.id;
                       
                       // Simulate detection
                       _onDetect(BarcodeCapture(barcodes: [Barcode(rawValue: testId)], image: null));
                    } else {
                      _showErrorDialog("No bookings found to test with.");
                    }
                  },
                  icon: const Icon(LucideIcons.bug, color: Colors.orange, size: 16),
                  label: Text(
                    'Debug: Simulate Scan',
                    style: GoogleFonts.outfit(color: Colors.orange),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black45,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
