import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class DatesTabView extends StatefulWidget {
  final Function(DateTime? start, DateTime? end) onDatesChanged;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const DatesTabView({
    super.key,
    required this.onDatesChanged,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<DatesTabView> createState() => _DatesTabViewState();
}

class _DatesTabViewState extends State<DatesTabView> {
  final DateRangePickerController _controller = DateRangePickerController();
  int _selectedChipIndex = 0; // 0: Exact dates, 1: ± 1 day, 2: ± 2 days

  @override
  void initState() {
    super.initState();
    if (widget.initialStartDate != null) {
      _controller.selectedRange = PickerDateRange(
        widget.initialStartDate,
        widget.initialEndDate,
      );
    }
  }
  
  @override
  void didUpdateWidget(DatesTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStartDate != oldWidget.initialStartDate || 
        widget.initialEndDate != oldWidget.initialEndDate) {
      if (widget.initialStartDate != null) {
        _controller.selectedRange = PickerDateRange(
          widget.initialStartDate,
          widget.initialEndDate,
        );
      } else {
        _controller.selectedRange = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Weekday Header (Fixed at top)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((day) => Text(
                      day,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ))
                .toList(),
          ),
        ),
        
        // Vertical Scrollable Calendar
        Expanded(
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.black, // Selection circle color
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: SfDateRangePicker(
              backgroundColor: Colors.white,
              controller: _controller,
              view: DateRangePickerView.month,
              selectionMode: DateRangePickerSelectionMode.range,
              navigationDirection: DateRangePickerNavigationDirection.vertical,
              enablePastDates: true, // Enable rendering of past dates to fix layout
              minDate: DateTime.now(), // Prevent selection of past dates
              headerHeight: 50,
              headerStyle: const DateRangePickerHeaderStyle(
                backgroundColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.left,
              ),
              monthViewSettings: const DateRangePickerMonthViewSettings(
                firstDayOfWeek: 1,
                viewHeaderHeight: 0,
                enableSwipeSelection: false,
              ),
              monthCellStyle: DateRangePickerMonthCellStyle(
                textStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Inter',
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
                disabledDatesTextStyle: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.grey[300],
                  fontFamily: 'Inter',
                ),
              ),
              startRangeSelectionColor: Colors.black,
              endRangeSelectionColor: Colors.black,
              rangeSelectionColor: Colors.grey.withOpacity(0.1),
              selectionShape: DateRangePickerSelectionShape.circle,
              onSelectionChanged: (args) {
                if (args.value is PickerDateRange) {
                  // Wrap in microtask to avoid "modify provider during build" error
                  Future.microtask(() {
                    widget.onDatesChanged(
                      args.value.startDate,
                      args.value.endDate,
                    );
                  });
                }
              },
            ),
          ),
        ),

        // Bottom Chips
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 16),
                _buildChip(0, 'Exact dates'),
                const SizedBox(width: 12),
                _buildChip(1, '± 1 day'),
                const SizedBox(width: 12),
                _buildChip(2, '± 2 days'),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildChip(int index, String label) {
    final isSelected = _selectedChipIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChipIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
