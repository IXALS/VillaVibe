import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:villavibe/features/favorites/data/repositories/favorite_repository.dart';
import 'package:villavibe/features/favorites/presentation/widgets/change_wishlist_modal.dart';
import 'package:villavibe/features/favorites/presentation/widgets/wishlist_snackbar.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';

class CreateWishlistModal extends ConsumerStatefulWidget {
  final String? firstVillaId;

  const CreateWishlistModal({
    super.key,
    this.firstVillaId,
  });

  @override
  ConsumerState<CreateWishlistModal> createState() => _CreateWishlistModalState();
}

class _CreateWishlistModalState extends ConsumerState<CreateWishlistModal> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createWishlist() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(favoriteRepositoryProvider).createWishlist(
            _nameController.text.trim(),
            firstVillaId: widget.firstVillaId,
          );
      if (mounted) {
        // Prepare result
        Map<String, dynamic>? result;
        
        if (widget.firstVillaId != null) {
          final allProperties = await ref.read(allPropertiesProvider.future);
          final villa = allProperties.firstWhere((p) => p.id == widget.firstVillaId, orElse: () => allProperties.first);
          final imageUrl = villa.images.isNotEmpty ? villa.images.first : null;
          
          result = {
            'wishlistName': _nameController.text.trim(),
            'imageUrl': imageUrl,
          };
        }
        
        if (mounted) {
          context.pop(result ?? true); 
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating wishlist: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Create wishlist',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                autofocus: true,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _createWishlist(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createWishlist,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
