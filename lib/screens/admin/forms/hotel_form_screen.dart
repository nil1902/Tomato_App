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
  final List<XFile> _newImages = [];
  
  final ImagePicker _picker = ImagePicker();

  // Premium UI Colors
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _surfaceBg = Color(0xFFF8FAFC);
  static const Color _cardBg = Colors.white;
  static const Color _textMain = Color(0xFF1E293B);
  static const Color _textSub = Color(0xFF64748B);
  static const Color _inputFill = Color(0xFFF1F5F9);
  static const Color _borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    if (widget.hotelToEdit != null) {
      final h = widget.hotelToEdit!;
      _nameController.text = h['name'] ?? '';
      _locationController.text = h['location'] ?? '';
      _descriptionController.text = h['description'] ?? '';
      _priceController.text = (h['base_price'] ?? h['price_per_night'] ?? '').toString();
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
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _newImages.addAll(images);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick images: $e');
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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveHotel() async {
    if (!_formKey.currentState!.validate()) return;
    
    // VISUAL FEEDBACK DIALOG
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: _primaryBlue),
                const SizedBox(height: 24),
                const Text('Saving Property...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryBlue)),
                const SizedBox(height: 8),
                const Text('Securely transferring photos & details to Server.', textAlign: TextAlign.center, style: TextStyle(color: _textSub, fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );

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
          bucketName: 'hotel-images', 
          fileName: 'hotel_${DateTime.now().millisecondsSinceEpoch}_${image.name.split('.').last}',
        );
        if (url != null) {
          finalImageUrls.add(url);
        } else {
           if (mounted) Navigator.pop(context); // close loader
           _showErrorSnackBar('Upload Failed. Your token might have expired. Please re-login.');
           setState(() => _isLoading = false);
           return;
        }
      }
      
      final hotelData = {
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'base_price': int.tryParse(_priceController.text) ?? 5000,
        'rating': double.tryParse(_ratingController.text) ?? 4.0,
        'image_urls': finalImageUrls,
        'is_active': true,
        'couple_friendly': true,
        'local_id_allowed': true,
        'privacy_score': double.tryParse(_ratingController.text) ?? 9.0,
        'safety_verified': true,
        'amenities': widget.hotelToEdit?['amenities'] ?? [], 
      };
      
      bool success;
      if (widget.hotelToEdit != null) {
        success = await adminService.updateHotel(widget.hotelToEdit!['id'], hotelData);
      } else {
        success = await adminService.addHotel(hotelData);
      }
      
      // Close the loading dialog
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        if (success) {
          _showSuccessSnackBar(widget.hotelToEdit != null ? 'Hotel updated successfully!' : 'Hotel added successfully!');
          Navigator.pop(context, true); 
        } else {
          _showErrorSnackBar('Failed to save hotel. Please verify your data.');
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // close loader
      debugPrint("Error saving hotel: $e");
      _showErrorSnackBar('An error occurred: $e');
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
      backgroundColor: _surfaceBg,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Property' : 'Add New Property',
          style: const TextStyle(
            color: _textMain, 
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textMain),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _borderColor, height: 1),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: _primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primaryBlue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryBlue.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.info_outline, color: _primaryBlue, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Update Property Info' : 'Property Details',
                              style: const TextStyle(
                                color: _primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEditing 
                                ? 'Ensure all information is accurate before saving modifications. Fields marked with * are required.' 
                                : 'Fill in the information below to list a new property on the platform. Accurate details attract more bookings.',
                              style: TextStyle(
                                color: _textMain.withOpacity(0.8),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Form Card
                Container(
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: _borderColor),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Basic Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textMain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        _buildInputField(
                          controller: _nameController,
                          label: 'Property Name *',
                          hint: 'Enter the full name of the hotel',
                          icon: Icons.hotel_outlined,
                          validator: (v) => v!.trim().isEmpty ? 'Property name is required' : null,
                        ),
                        const SizedBox(height: 20),
                        
                        _buildInputField(
                          controller: _locationController,
                          label: 'Location *',
                          hint: 'e.g. South Goa, India',
                          icon: Icons.location_on_outlined,
                          validator: (v) => v!.trim().isEmpty ? 'Location is required' : null,
                        ),
                        const SizedBox(height: 20),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: _priceController,
                                label: 'Price per Night (₹) *',
                                hint: 'e.g. 2500',
                                icon: Icons.currency_rupee_outlined,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v!.trim().isEmpty) return 'Price required';
                                  if (int.tryParse(v) == null) return 'Enter a valid number';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildInputField(
                                controller: _ratingController,
                                label: 'Initial Rating *',
                                hint: '0.0 to 5.0',
                                icon: Icons.star_outline,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) {
                                  if (v!.trim().isEmpty) return 'Rating required';
                                  final r = double.tryParse(v);
                                  if (r == null || r < 0 || r > 5) return '0.0 - 5.0 only';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        _buildInputField(
                          controller: _descriptionController,
                          label: 'Description *',
                          hint: 'Write a compelling description of the property...',
                          icon: Icons.description_outlined,
                          maxLines: 4,
                          validator: (v) => v!.trim().isEmpty ? 'Description is required' : null,
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Divider(color: _borderColor),
                        ),
                        
                        const Text(
                          'Property Media',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Upload high-quality images of the property. First image will be used as the thumbnail.',
                          style: TextStyle(
                            fontSize: 14,
                            color: _textSub,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Images Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: kIsWeb ? 4 : 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                          ),
                          itemCount: _existingImages.length + _newImages.length + 1,
                          itemBuilder: (context, index) {
                            // Upload button
                            if (index == _existingImages.length + _newImages.length) {
                              return InkWell(
                                onTap: _pickImages,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _inputFill,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _borderColor, style: BorderStyle.solid, width: 2),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, color: _textSub.withOpacity(0.7), size: 36),
                                      const SizedBox(height: 8),
                                      const Text('Add Image', style: TextStyle(color: _textSub, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            // Existing Images
                            if (index < _existingImages.length) {
                              return _buildImageThumbnail(
                                imageProvider: NetworkImage(_existingImages[index]),
                                onRemove: () => _removeExistingImage(index),
                              );
                            }
                            
                            // New Images
                            final newIndex = index - _existingImages.length;
                            final newImg = _newImages[newIndex];
                            return _buildImageThumbnail(
                              imageProvider: kIsWeb 
                                  ? NetworkImage(newImg.path) 
                                  : FileImage(File(newImg.path)) as ImageProvider,
                              onRemove: () => _removeNewImage(newIndex),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16, color: _textSub, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveHotel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isEditing ? Icons.save_outlined : Icons.add_circle_outline, size: 20),
                                const SizedBox(width: 8),
                                Text(isEditing ? 'Save Changes' : 'Publish Property', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textMain,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 16, color: _textMain),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _textSub.withOpacity(0.6), fontSize: 15),
            prefixIcon: maxLines == 1 ? Icon(icon, color: _textSub) : null,
            alignLabelWithHint: maxLines > 1,
            filled: true,
            fillColor: _inputFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail({
    required ImageProvider imageProvider,
    required VoidCallback onRemove,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
