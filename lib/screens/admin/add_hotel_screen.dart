import 'package:flutter/material.dart';
import 'package:lovenest/services/admin_service.dart';

/// Add New Hotel Screen
class AddHotelScreen extends StatefulWidget {
  const AddHotelScreen({super.key});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  double _rating = 4.0;
  bool _saving = false;
  
  final List<String> _selectedAmenities = [];
  final List<String> _availableAmenities = [
    'WiFi',
    'AC',
    'TV',
    'Room Service',
    'Parking',
    'Pool',
    'Gym',
    'Restaurant',
    'Bar',
    'Spa',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Hotel'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Hotel Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.hotel),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter hotel name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter city';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price per Night (₹) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
                hintText: 'https://example.com/image.jpg',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter image URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rating: ${_rating.toStringAsFixed(1)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _rating,
                      min: 1.0,
                      max: 5.0,
                      divisions: 40,
                      label: _rating.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() => _rating = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amenities',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _saving ? null : _saveHotel,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Hotel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveHotel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final hotelData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'city': _cityController.text,
        'address': _addressController.text,
        'price_per_night': double.parse(_priceController.text),
        'image_url': _imageUrlController.text,
        'rating': _rating,
        'amenities': _selectedAmenities,
      };

      await _adminService.addHotel(hotelData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotel added successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding hotel: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
