import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/auth_service.dart';
import '../../../services/admin_service.dart';
import '../../../services/storage_service.dart';

class HotelFormScreen extends StatefulWidget {
  final Map<String, dynamic>? hotelToEdit;

  const HotelFormScreen({super.key, this.hotelToEdit});

  @override
  State<HotelFormScreen> createState() => _HotelFormScreenState();
}

class _HotelFormScreenState extends State<HotelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _ratingController = TextEditingController();
  
  bool _isLoading = false;
  List<String> _existingImages = [];
  List<XFile> _newImages = [];
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.hotelToEdit != null) {
      final h = widget.hotelToEdit!;
      _nameController.text = h['name'] ?? '';
      _locationController.text = h['location'] ?? '';
      _descriptionController.text = h['description'] ?? '';
      _priceController.text = (h['price_per_night'] ?? '').toString();
      _ratingController.text = (h['rating'] ?? '').toString();
      if (h['image_urls'] != null) {
        _existingImages = List<String>.from(h['image_urls']);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _newImages.addAll(images);
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _saveHotel() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authService = context.read<AuthService>();
      final adminService = AdminService(authService.accessToken!);
      final storageService = StorageService(authService.accessToken!);
      
      List<String> finalImageUrls = List.from(_existingImages);
      
      // Upload new images
      for (var image in _newImages) {
        final url = await storageService.uploadFile(
          file: image,
          bucketName: 'hotel-images', // Make sure this bucket exists in InsForge!
          fileName: 'hotel_${DateTime.now().millisecondsSinceEpoch}_${image.name.split('.').last}',
        );
        if (url != null) {
          finalImageUrls.add(url);
        }
      }
      
      final hotelData = {
        'name': _nameController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'price_per_night': int.tryParse(_priceController.text) ?? 0,
        'rating': double.tryParse(_ratingController.text) ?? 0.0,
        'image_urls': finalImageUrls,
        // Add default values for required DB columns that might be missing in the form initially
        'amenities': widget.hotelToEdit?['amenities'] ?? [], 
      };
      
      bool success;
      if (widget.hotelToEdit != null) {
        success = await adminService.updateHotel(widget.hotelToEdit!['id'], hotelData);
      } else {
        success = await adminService.addHotel(hotelData);
      }
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hotel saved successfully!')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save hotel. Check logs.')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error saving hotel: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.hotelToEdit != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Hotel' : 'Add New Hotel'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            TextButton(
              onPressed: _saveHotel,
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Hotel Name',
                icon: Icons.hotel,
                validator: (v) => v!.isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _locationController,
                label: 'Location (e.g. Goa, India)',
                icon: Icons.location_on,
                validator: (v) => v!.isEmpty ? 'Location required' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Price per Night (₹)',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _ratingController,
                      label: 'Rating (0-5)',
                      icon: Icons.star,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        final r = double.tryParse(v);
                        if (r == null || r < 0 || r > 5) return 'Invalid rating';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Description required' : null,
              ),
              const SizedBox(height: 24),
              
              const Text('Hotel Images', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Images Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _existingImages.length + _newImages.length + 1,
                itemBuilder: (context, index) {
                  // Upload button
                  if (index == _existingImages.length + _newImages.length) {
                    return InkWell(
                      onTap: _pickImages,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
                        ),
                        child: const Icon(Icons.add_a_photo, color: Colors.grey),
                      ),
                    );
                  }
                  
                  // Existing Images
                  if (index < _existingImages.length) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(_existingImages[index], fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4, right: 4,
                          child: InkWell(
                            onTap: () => _removeExistingImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.delete, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  
                  // New Images
                  final newIndex = index - _existingImages.length;
                  final newImg = _newImages[newIndex];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb 
                          ? Image.network(newImg.path, fit: BoxFit.cover)
                          : Image.file(File(newImg.path), fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4, right: 4,
                        child: InkWell(
                          onTap: () => _removeNewImage(newIndex),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.delete, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon) : null,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
