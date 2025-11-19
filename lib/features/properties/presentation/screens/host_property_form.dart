import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';

class HostPropertyForm extends ConsumerStatefulWidget {
  const HostPropertyForm({super.key});

  @override
  ConsumerState<HostPropertyForm> createState() => _HostPropertyFormState();
}

class _HostPropertyFormState extends ConsumerState<HostPropertyForm> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form Data
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  int _bedrooms = 1;
  int _bathrooms = 1;
  int _maxGuests = 2;

  final List<String> _selectedAmenities = [];
  final List<String> _images = []; // Placeholder for image URLs

  final List<String> _availableAmenities = [
    "Wifi",
    "Pool",
    "Kitchen",
    "AC",
    "BBQ",
    "Parking",
    "TV",
    "Gym"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Property')),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            _submitForm();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            context.pop();
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 2 ? 'Submit' : 'Next'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Basic Info'),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Property Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration:
                        const InputDecoration(labelText: 'Price per Night'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Details'),
            content: Column(
              children: [
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                const SizedBox(height: 16),
                _buildCounter('Bedrooms', _bedrooms,
                    (val) => setState(() => _bedrooms = val)),
                _buildCounter('Bathrooms', _bathrooms,
                    (val) => setState(() => _bathrooms = val)),
                _buildCounter('Max Guests', _maxGuests,
                    (val) => setState(() => _maxGuests = val)),
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Amenities'),
            content: Wrap(
              spacing: 8,
              children: _availableAmenities.map((amenity) {
                final isSelected = _selectedAmenities.contains(amenity);
                return FilterChip(
                  label: Text(amenity),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAmenities.add(amenity);
                      } else {
                        _selectedAmenities.remove(amenity);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$value', style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;

    final property = Property(
      id: '', // Repository will handle ID
      hostId: user.uid,
      name: _nameController.text,
      description: _descriptionController.text,
      pricePerNight: int.tryParse(_priceController.text) ?? 0,
      address: _addressController.text,
      city: _cityController.text,
      specs: PropertySpecs(
        bedrooms: _bedrooms,
        bathrooms: _bathrooms,
        maxGuests: _maxGuests,
      ),
      amenities: _selectedAmenities,
      images: _images, // TODO: Implement Image Upload
    );

    await ref.read(propertyRepositoryProvider).addProperty(property);
    if (mounted) {
      context.pop();
    }
  }
}
