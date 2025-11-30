import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:villavibe/features/host/presentation/providers/host_onboarding_provider.dart';

class StepVibe extends ConsumerWidget {
  const StepVibe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hostOnboardingNotifierProvider);
    final notifier = ref.read(hostOnboardingNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Let\'s give your place a name')
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          const Text(
            'Short titles work best. Have fun with it—you can always change it later.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),
          TextField(
            onChanged: notifier.setTitle,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Cozy Cottage near the Lake',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 32),
          _buildHeader('Describe your place')
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          TextField(
            onChanged: notifier.setDescription,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText:
                  'Share what makes your place special, like the view or the neighborhood.',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 32),
          _buildHeader('Curate the Vibe')
              .animate()
              .fadeIn(delay: 450.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          const Text(
            'What kind of experience does your villa offer?',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ).animate().fadeIn(delay: 450.ms),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              'Zen / Retreat',
              'Entertainer / Party',
              'Family Fun',
              'Digital Nomad',
              'Romantic Getaway',
              'Eco / Sustainable',
            ].map((vibe) {
              final isSelected = state.vibe == vibe;
              return ChoiceChip(
                label: Text(vibe),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    HapticFeedback.selectionClick();
                    notifier.setVibe(vibe);
                  }
                },
                selectedColor: Colors.black.withOpacity(0.05),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).scale();
            }).toList(),
          ),
          const SizedBox(height: 32),
          _buildHeader('Staff & Services')
              .animate()
              .fadeIn(delay: 500.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          const Text(
            'Villas are about service. What team comes with the booking?',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ).animate().fadeIn(delay: 550.ms),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              'Private Chef',
              'Daily Housekeeping',
              '24/7 Security',
              'Butler / Villa Manager',
              'Driver / Airport Transfer',
              'Concierge',
              'Spa Therapist',
            ].map((service) {
              final isSelected = state.staffServices.contains(service);
              return FilterChip(
                label: Text(service),
                selected: isSelected,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  notifier.toggleStaffService(service);
                },
                selectedColor: Colors.black.withOpacity(0.05),
                checkmarkColor: Colors.black,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).scale();
            }).toList(),
          ),
          const SizedBox(height: 32),
          _buildHeader('The Grounds')
              .animate()
              .fadeIn(delay: 650.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          const Text(
            'Highlight your outdoor luxury features.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ).animate().fadeIn(delay: 700.ms),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              'Infinity Pool',
              'Private Beach Access',
              'Yoga Shala / Gazebo',
              'Tennis Court',
              'Fire Pit / BBQ Area',
              'Jacuzzi / Hot Tub',
              'Outdoor Cinema',
              'Helipad',
              'Tropical Garden',
            ].map((amenity) {
              final isSelected = state.outdoorAmenities.contains(amenity);
              return FilterChip(
                label: Text(amenity),
                selected: isSelected,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  notifier.toggleOutdoorAmenity(amenity);
                },
                selectedColor: Colors.black.withOpacity(0.05),
                checkmarkColor: Colors.black,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                  ),
                ),
              ).animate().fadeIn(delay: 750.ms).scale();
            }).toList(),
          ),
          const SizedBox(height: 32),
          _buildHeader('Indoor Amenities')
              .animate()
              .fadeIn(delay: 800.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              'Wifi',
              'Kitchen',
              'Washer',
              'Dryer',
              'Air conditioning',
              'Heating',
              'Dedicated workspace',
              'TV',
              'Hair dryer',
              'Iron',
              'Crib',
              'Gym',
              'Indoor fireplace',
              'Smoking allowed',
            ].map((amenity) {
              final isSelected = state.amenities.contains(amenity);
              return FilterChip(
                label: Text(amenity),
                selected: isSelected,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  notifier.toggleAmenity(amenity);
                },
                selectedColor: Colors.black.withOpacity(0.05),
                checkmarkColor: Colors.black,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                  ),
                ),
              ).animate().fadeIn(delay: 850.ms).scale();
            }).toList(),
          ),
          const SizedBox(height: 32),
          _buildHeader('Add some photos')
              .animate()
              .fadeIn(delay: 700.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          _buildPhotoGrid(context, ref, state)
              .animate()
              .fadeIn(delay: 800.ms)
              .scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }



  Future<void> _pickImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      for (var image in images) {
        ref.read(hostOnboardingNotifierProvider.notifier).addPhoto(image);
      }
    }
  }

  Widget _buildPhotoGrid(BuildContext context, WidgetRef ref, HostOnboardingState state) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: state.selectedPhotos.length + 1,
        itemBuilder: (context, index) {
          if (index == state.selectedPhotos.length) {
            return _buildAddPhotoButton(ref);
          }
          return _buildPhotoItem(ref, state.selectedPhotos[index], index);
        },
      ),
    );
  }

  Widget _buildPhotoItem(WidgetRef ref, XFile photo, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(photo.path),
            fit: BoxFit.cover,
          ),
        ),
        if (index == 0)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Cover',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(hostOnboardingNotifierProvider.notifier).removePhoto(index);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton(WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _pickImage(ref);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 32, color: Colors.grey),
              SizedBox(height: 4),
              Text('Add photos', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
