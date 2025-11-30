import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FlexibleTabView extends StatefulWidget {
  final Function(String duration, List<DateTime> months) onSelectionChanged;

  const FlexibleTabView({super.key, required this.onSelectionChanged});

  @override
  State<FlexibleTabView> createState() => _FlexibleTabViewState();
}

class _FlexibleTabViewState extends State<FlexibleTabView> {
  String _selectedDuration = 'Weekend'; // Weekend, Week, Month
  final List<DateTime> _selectedMonths = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How long would you like to stay?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildDurationChip('Weekend'),
            const SizedBox(width: 12),
            _buildDurationChip('Week'),
            const SizedBox(width: 12),
            _buildDurationChip('Month'),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Go anytime',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              // Start from current month
              final now = DateTime.now();
              final date = DateTime(now.year, now.month + index, 1);
              return _buildMonthCard(date);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDurationChip(String label) {
    final isSelected = _selectedDuration == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDuration = label;
        });
        widget.onSelectionChanged(_selectedDuration, _selectedMonths);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
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

  Widget _buildMonthCard(DateTime date) {
    final isSelected = _selectedMonths.any((d) => d.year == date.year && d.month == date.month);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedMonths.removeWhere((d) => d.year == date.year && d.month == date.month);
          } else {
            _selectedMonths.add(date);
          }
        });
        widget.onSelectionChanged(_selectedDuration, _selectedMonths);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.calendar,
              size: 28,
              color: isSelected ? Colors.black : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMMM').format(date),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
            Text(
              DateFormat('yyyy').format(date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
