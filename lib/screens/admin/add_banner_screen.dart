import 'package:flutter/material.dart';
import 'package:lovenest/services/admin_service.dart';

/// Add Banner Screen
class AddBannerScreen extends StatefulWidget {
  const AddBannerScreen({super.key});

  @override
  State<AddBannerScreen> createState() => _AddBannerScreenState();
}

class _AddBannerScreenState extends State<AddBannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _linkController = TextEditingController();
  
  bool _isActive = true;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Banner'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Banner Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
                hintText: 'https://example.com/banner.jpg',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter image URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: 'Click Action Link (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
                hintText: '/hotel/123',
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Show banner to users'),
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
              ),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _saving ? null : _saveBanner,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Banner'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBanner() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final bannerData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'image_url': _imageUrlController.text,
        'link': _linkController.text,
        'is_active': _isActive,
      };

      await _adminService.addBanner(bannerData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner added successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding banner: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
