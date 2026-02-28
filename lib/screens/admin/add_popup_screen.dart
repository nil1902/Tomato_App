import 'package:flutter/material.dart';
import 'package:lovenest/services/admin_service.dart';

/// Add Popup Advertisement Screen
class AddPopupScreen extends StatefulWidget {
  const AddPopupScreen({super.key});

  @override
  State<AddPopupScreen> createState() => _AddPopupScreenState();
}

class _AddPopupScreenState extends State<AddPopupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();
  
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _buttonTextController = TextEditingController(text: 'Got it');
  final _linkController = TextEditingController();
  
  bool _isActive = true;
  bool _saving = false;
  String _popupType = 'discount'; // discount, announcement, welcome

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _imageUrlController.dispose();
    _buttonTextController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Popup'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popup Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Discount'),
                          selected: _popupType == 'discount',
                          onSelected: (selected) {
                            if (selected) setState(() => _popupType = 'discount');
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Announcement'),
                          selected: _popupType == 'announcement',
                          onSelected: (selected) {
                            if (selected) setState(() => _popupType = 'announcement');
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Welcome'),
                          selected: _popupType == 'welcome',
                          onSelected: (selected) {
                            if (selected) setState(() => _popupType = 'welcome');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Popup Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
                hintText: 'e.g., Special Discount!',
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
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
                hintText: 'e.g., Get 20% off on your first booking!',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter message';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
                hintText: 'https://example.com/popup-image.jpg',
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _buttonTextController,
              decoration: const InputDecoration(
                labelText: 'Button Text',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.touch_app),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: 'Action Link (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
                hintText: '/coupons',
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Show popup to users'),
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
              ),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _saving ? null : _savePopup,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Popup'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePopup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final popupData = {
        'type': _popupType,
        'title': _titleController.text,
        'message': _messageController.text,
        'image_url': _imageUrlController.text,
        'button_text': _buttonTextController.text,
        'link': _linkController.text,
        'is_active': _isActive,
      };

      await _adminService.addPopup(popupData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Popup added successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding popup: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
