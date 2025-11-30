import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';

class CalendarMonthView extends StatelessWidget {
  final DateTime month;
  final List<Booking> bookings;
  final int pricePerNight;
  final Map<String, int> customPrices;
  final DateTime? selectedStart;
  final DateTime? selectedEnd;
  final Function(DateTime) onDayTap;

  const CalendarMonthView({
    super.key,
    required this.month,
    required this.bookings,
    required this.pricePerNight,
    this.customPrices = const {},
    this.selectedStart,
    this.selectedEnd,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun
    
    final offset = firstWeekday - 1; // 0 for Mon, 6 for Sun

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Text(
            DateFormat('MMMM yyyy').format(month),
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.7, // Taller cells for price
          ),
          itemCount: daysInMonth + offset,
          itemBuilder: (context, index) {
            if (index < offset) return const SizedBox();
            
            final day = index - offset + 1;
            final date = DateTime(month.year, month.month, day);
            
            return _buildDayCell(context, date);
          },
        ),
      ],
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isPast = date.isBefore(today);
    final isToday = date.isAtSameMomentAs(today);

    // Check booking status
    final booking = bookings.firstWhere(
      (b) {
        final start = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
        final end = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
        return (date.isAtSameMomentAs(start) || date.isAfter(start)) && date.isBefore(end);
      },
      orElse: () => Booking(
        id: '',
        propertyId: '',
        guestId: '',
        hostId: '',
        startDate: DateTime(1900),
        endDate: DateTime(1900),
        totalPrice: 0,
        status: 'none',
        messageToHost: '',
        guestCount: 0,
        createdAt: DateTime.now(),
      ),
    );

    final isBlocked = booking.status == 'blocked';
    final isPending = booking.status == 'pending';
    final isBooked = booking.status == 'paid' || booking.status == 'confirmed'; // explicit check
    
    // Selection Logic
    bool isSelectedStart = false;
    bool isSelectedEnd = false;
    bool isInRange = false;

    if (selectedStart != null) {
      isSelectedStart = date.year == selectedStart!.year && 
                        date.month == selectedStart!.month && 
                        date.day == selectedStart!.day;
    }
    if (selectedEnd != null) {
      isSelectedEnd = date.year == selectedEnd!.year && 
                      date.month == selectedEnd!.month && 
                      date.day == selectedEnd!.day;
    }
    if (selectedStart != null && selectedEnd != null) {
      isInRange = date.isAfter(selectedStart!) && date.isBefore(selectedEnd!);
    }

    // Colors
    Color backgroundColor = Colors.white;
    Color textColor = Colors.black;
    Color borderColor = Colors.grey[200]!;
    
    if (isBlocked) {
      backgroundColor = Colors.grey[200]!;
      textColor = Colors.grey[500]!;
      borderColor = Colors.transparent;
    } else if (isPending) {
      backgroundColor = const Color(0xFFFF9800); // Orange
      textColor = Colors.white;
      borderColor = Colors.transparent;
    } else if (isBooked) {
      backgroundColor = const Color(0xFFE91E63); // Pink
      textColor = Colors.white;
      borderColor = Colors.transparent;
    } else if (isSelectedStart || isSelectedEnd) {
      backgroundColor = Colors.black;
      textColor = Colors.white;
      borderColor = Colors.transparent;
    } else if (isInRange) {
      backgroundColor = Colors.grey[100]!;
      borderColor = Colors.transparent;
    } else if (isPast) {
      textColor = Colors.grey[300]!;
    }

    if (isToday && !isSelectedStart && !isSelectedEnd && !isBooked && !isBlocked) {
      borderColor = Colors.black;
    }

    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final priceForDate = customPrices[dateStr] ?? pricePerNight;

    return GestureDetector(
      onTap: () => onDayTap(date),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: isToday && !isSelectedStart && !isSelectedEnd ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (!isPast && !isBooked && !isBlocked) ...[
              const SizedBox(height: 4),
              Text(
                NumberFormat.compactCurrency(locale: 'id_ID', symbol: '')
                    .format(priceForDate),
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: (isSelectedStart || isSelectedEnd) ? Colors.white70 : Colors.grey[600],
                  fontWeight: customPrices.containsKey(dateStr) ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
            if (isBlocked) ...[
               const SizedBox(height: 2),
               Icon(Icons.block, size: 10, color: Colors.grey[500]),
            ],
          ],
        ),
      ),
    );
  }
}
