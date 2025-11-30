import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';

class OccupancyPulse extends StatelessWidget {
  final List<Booking> bookings;

  const OccupancyPulse({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    
    // Calculate booked days in current month
    int bookedDays = 0;
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(now.year, now.month, i);
      final isBooked = bookings.any((b) {
        final start = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
        final end = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
        // Only count paid/completed bookings, not blocked ones for "Occupancy"
        // Or should blocked count? Usually occupancy = revenue generating.
        // Let's count only 'paid' and 'completed'.
        if (b.status == 'blocked') return false;
        
        return (date.isAtSameMomentAs(start) || date.isAfter(start)) && date.isBefore(end);
      });
      if (isBooked) bookedDays++;
    }

    final percentage = bookedDays / daysInMonth;
    final percentageInt = (percentage * 100).toInt();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('MMMM').format(now)} Occupancy',
                  style: GoogleFonts.outfit(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$percentageInt%',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        percentageInt > 50 ? 'Great job! 🔥' : 'Keep it up! 🚀',
                        style: GoogleFonts.outfit(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
