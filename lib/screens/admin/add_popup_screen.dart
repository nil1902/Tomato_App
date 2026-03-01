import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

/// Add Popup Advertisement Screen
class AddPopupScreen extends StatefulWidget {
  const AddPopupScreen({super.key});

  @override
  State<AddPopupScreen> createState() => _AddPopupScreenState();
}

class _AddPopupScreenState extends State<AddPopupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _buttonTextController = TextEditingController(text: 'Got it');
  final _linkController = TextEditingController();
  
  bool _isActive = true;
  bool _saving = false;
  String _popupType = 'discount'; // discount, announcement, welcome
  XFile? _selectedImage;
  
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
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _buttonTextController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
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

  Future<void> _savePopup() async {
    if (!_formKey.currentState!.validate()) return;

    // SHOW VISUAL OVERLAY FOR UPLOAD
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
                const Text('Publishing Popup...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryBlue)),
                const SizedBox(height: 8),
                const Text('Uploading promotional assets and rules to server.', textAlign: TextAlign.center, style: TextStyle(color: _textSub, fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );

    setState(() => _saving = true);

    try {
      final authService = context.read<AuthService>();
      final adminService = AdminService(authService.accessToken!);
      final storageService = StorageService(authService.accessToken!);

      String? imageUrl;
      
      // Upload image if selected
      if (_selectedImage != null) {
        imageUrl = await storageService.uploadFile(
          file: _selectedImage!,
          bucketName: 'popup-images',
          fileName: 'popup_${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.name.split('.').last}',
        );
      }

      final popupData = {
        'type': _popupType,
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'image_url': imageUrl ?? '',
        'button_text': _buttonTextController.text.trim(),
        'link': _linkController.text.trim(),
        'is_active': _isActive,
      };

      await adminService.addPopup(popupData);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        _showSuccessSnackBar('Popup added successfully');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);
        _showErrorSnackBar('Error adding popup: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceBg,
      appBar: AppBar(
        title: const Text(
          'Add New Popup',
          style: TextStyle(
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
                    color: Colors.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.campaign_outlined, color: Colors.orange, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Popup Management',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create promotional popups that users will see upon opening the app. Use them sparingly to avoid annoying users.',
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
                          'Popup Configuration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textMain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Popup Type
                        const Text(
                          'Popup Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _textMain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildTypeButton('Discount', 'discount', Icons.percent),
                            const SizedBox(width: 12),
                            _buildTypeButton('Announcement', 'announcement', Icons.campaign_outlined),
                            const SizedBox(width: 12),
                            _buildTypeButton('Welcome', 'welcome', Icons.waving_hand_outlined),
                          ],
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: _borderColor),
                        ),
                        
                        _buildInputField(
                          controller: _titleController,
                          label: 'Popup Title *',
                          hint: 'e.g. Special Weekend Offer!',
                          icon: Icons.title_outlined,
                          validator: (v) => v!.trim().isEmpty ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 20),
                        
                        _buildInputField(
                          controller: _messageController,
                          label: 'Message *',
                          hint: 'e.g. Get 20% off on your first booking!',
                          icon: Icons.message_outlined,
                          maxLines: 3,
                          validator: (v) => v!.trim().isEmpty ? 'Message is required' : null,
                        ),
                        const SizedBox(height: 20),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: _buttonTextController,
                                label: 'Button Text',
                                hint: 'e.g. Claim Now',
                                icon: Icons.touch_app_outlined,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildInputField(
                                controller: _linkController,
                                label: 'Action Link (Optional)',
                                hint: 'e.g. /coupons',
                                icon: Icons.link_outlined,
                              ),
                            ),
                          ],
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: _borderColor),
                        ),
                        
                        const Text(
                          'Popup Image (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Upload an image to make the popup more attractive.',
                          style: TextStyle(fontSize: 14, color: _textSub),
                        ),
                        const SizedBox(height: 16),
                        
                        // Image Picker Box
                        InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _inputFill,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedImage == null ? _borderColor : _primaryBlue, 
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: _selectedImage == null 
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, color: _textSub.withOpacity(0.7), size: 40),
                                      const SizedBox(height: 12),
                                      const Text('Tap to Upload Image', style: TextStyle(color: _textSub, fontWeight: FontWeight.w600, fontSize: 15)),
                                    ],
                                  )
                                : Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: kIsWeb
                                            ? Image.network(_selectedImage!.path, fit: BoxFit.cover, width: double.infinity)
                                            : Image.file(File(_selectedImage!.path), fit: BoxFit.cover, width: double.infinity),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: InkWell(
                                          onTap: () => setState(() => _selectedImage = null),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: _borderColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SwitchListTile(
                            title: const Text('Active Status', style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text('Show this popup to users instantly'),
                            value: _isActive,
                            activeThumbColor: _primaryBlue,
                            onChanged: (value) => setState(() => _isActive = value),
                          ),
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
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16, color: _textSub, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _saving ? null : _savePopup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_circle_outline, size: 20),
                                SizedBox(width: 8),
                                Text('Publish Popup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildTypeButton(String label, String value, IconData icon) {
    final isSelected = _popupType == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _popupType = value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _primaryBlue.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _primaryBlue : _borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? _primaryBlue : _textSub),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? _primaryBlue : _textSub,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
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
}
