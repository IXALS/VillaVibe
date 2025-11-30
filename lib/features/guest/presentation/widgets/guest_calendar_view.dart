import 'package:flutter/material.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/host/presentation/widgets/calendar_month_view.dart';

class GuestCalendarView extends StatefulWidget {
  final List<Booking> bookings;
  final int pricePerNight;
  final Map<String, int> customPrices;
  final Function(DateTime start, DateTime end) onDateRangeSelected;

  const GuestCalendarView({
    super.key,
    required this.bookings,
    required this.pricePerNight,
    required this.customPrices,
    required this.onDateRangeSelected,
  });

  @override
  State<GuestCalendarView> createState() => _GuestCalendarViewState();
}

class _GuestCalendarViewState extends State<GuestCalendarView> {
  DateTime? _selectedStart;
  DateTime? _selectedEnd;

  void _handleDayTap(DateTime date) {
    setState(() {
      if (_selectedStart == null || (_selectedStart != null && _selectedEnd != null)) {
        // Start new selection
        _selectedStart = date;
        _selectedEnd = null;
      } else {
        // Complete selection
        if (date.isBefore(_selectedStart!)) {
          _selectedStart = date;
        } else {
          _selectedEnd = date;
          widget.onDateRangeSelected(_selectedStart!, _selectedEnd!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: 13, // 12 months + current
      itemBuilder: (context, index) {
        final month = DateTime(now.year, now.month + index, 1);
        return CalendarMonthView(
          month: month,
          bookings: widget.bookings,
          pricePerNight: widget.pricePerNight,
          customPrices: widget.customPrices,
          selectedStart: _selectedStart,
          selectedEnd: _selectedEnd,
          onDayTap: _handleDayTap,
        );
      },
    );
  }
}
