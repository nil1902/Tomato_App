import 'package:flutter/material.dart';
import 'package:lovenest/services/admin_service.dart';

/// Edit Hotel Screen
class EditHotelScreen extends StatefulWidget {
  final Map<String, dynamic> hotel;
  
  const EditHotelScreen({super.key, required this.hotel});

  @override
  State<EditHotelScreen> createState() => _EditHotelScreenState();
}

class _EditHotelScreenState extends State<EditHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  
  late double _rating;
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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hotel['name']);
    _descriptionController = TextEditingController(text: widget.hotel['description']);
    _cityController = TextEditingController(text: widget.hotel['city']);
    _addressController = TextEditingController(text: widget.hotel['address']);
    _priceController = TextEditingController(text: widget.hotel['price_per_night']?.toString());
    _imageUrlController = TextEditingController(text: widget.hotel['image_url']);
    _rating = (widget.hotel['rating'] ?? 4.0).toDouble();
    
    if (widget.hotel['amenities'] != null) {
      _selectedAmenities.addAll(List<String>.from(widget.hotel['amenities']));
    }
  }

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
        title: const Text('Edit Hotel'),
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
              onPressed: _saving ? null : _updateHotel,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update Hotel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateHotel() async {
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

      await _adminService.updateHotel(widget.hotel['id'], hotelData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotel updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating hotel: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
