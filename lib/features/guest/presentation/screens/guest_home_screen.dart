import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/core/presentation/widgets/property_card_shimmer.dart';

class GuestHomeScreen extends ConsumerStatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  ConsumerState<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends ConsumerState<GuestHomeScreen> {
  String _searchCity = '';
  DateTime? _startDate;
  DateTime? _endDate;
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final allPropertiesAsync = ref.watch(allPropertiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Villas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: allPropertiesAsync.when(
              data: (properties) {
                // 1. Filter by City
                var filtered = properties;
                if (_searchCity.isNotEmpty) {
                  filtered = properties
                      .where((p) => p.city
                          .toLowerCase()
                          .contains(_searchCity.toLowerCase()))
                      .toList();
                }

                // 2. Filter by Date Availability (Async check needed, so we use a FutureBuilder or separate provider)
                // For MVP, we will just show all and check availability on detail/booking,
                // OR we can try to filter here if the list is small.
                // Let's do a simple filter here using a FutureBuilder for the list.

                return FutureBuilder<List<Property>>(
                  future: _filterAvailableProperties(filtered),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final availableProperties = snapshot.data ?? [];

                    if (availableProperties.isEmpty) {
                      return const Center(
                          child:
                              Text('No villas found matching your criteria.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: availableProperties.length,
                      itemBuilder: (context, index) {
                        final property = availableProperties[index];
                        return _buildPropertyCard(property);
                      },
                    );
                  },
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                itemBuilder: (context, index) => const PropertyCardShimmer(),
              ),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Where to? (e.g. Bali)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchCity = '');
                },
              ),
            ),
            onSubmitted: (val) => setState(() => _searchCity = val),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _showDatePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _startDate == null
                        ? 'Select Dates'
                        : '${DateFormat('MMM dd').format(_startDate!)} - ${_endDate != null ? DateFormat('MMM dd').format(_endDate!) : '...'}',
                    style: TextStyle(
                      color: _startDate == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Property>> _filterAvailableProperties(
      List<Property> properties) async {
    if (_startDate == null || _endDate == null) return properties;

    final repo = ref.read(bookingRepositoryProvider);
    final available = <Property>[];

    for (var property in properties) {
      final isAvailable = await repo.isPropertyAvailable(
        property.id,
        _startDate!,
        _endDate!,
      );
      if (isAvailable) {
        available.add(property);
      }
    }
    return available;
  }

  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 300,
          height: 300,
          child: SfDateRangePicker(
            selectionMode: DateRangePickerSelectionMode.range,
            onSelectionChanged: (args) {
              if (args.value is PickerDateRange) {
                setState(() {
                  _startDate = args.value.startDate;
                  _endDate = args.value.endDate;
                });
              }
            },
            showActionButtons: true,
            onSubmit: (val) => Navigator.pop(context),
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // context.push('/property/${property.id}'); // TODO: Implement Detail Screen
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (property.images.isNotEmpty)
              Image.network(
                property.images.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image, size: 48)),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        property.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(property.rating.toString()),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.city,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${property.pricePerNight} / night',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
