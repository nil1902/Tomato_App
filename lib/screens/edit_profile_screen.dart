import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lovenest/theme/app_colors.dart';
import 'package:lovenest/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _partnerController;
  DateTime? _anniversaryDate;
  
  bool _isLoading = false;
  XFile? _selectedImage;
  String? _currentAvatarUrl;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    _nameController = TextEditingController(text: user?['name'] ?? '');
    _phoneController = TextEditingController(text: user?['phone'] ?? '');
    _partnerController = TextEditingController(text: user?['partner_name'] ?? '');
    _currentAvatarUrl = user?['avatar_url'];
    
    // Parse anniversary date if available
    if (user?['anniversary_date'] != null) {
      try {
        _anniversaryDate = DateTime.parse(user!['anniversary_date']);
      } catch (e) {
        debugPrint('Error parsing anniversary date: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _partnerController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = context.read<AuthService>();
    
    // Check if user is authenticated
    if (!auth.isAuthenticated || auth.currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login first to update your profile'),
            backgroundColor: Colors.red,
          ),
        );
        context.go('/login');
      }
      return;
    }
    
    setState(() => _isLoading = true);
    
    final success = await auth.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      partnerName: _partnerController.text,
      anniversaryDate: _anniversaryDate ?? DateTime.now(),
      avatarFile: _selectedImage,
    );
    
    setState(() => _isLoading = false);
    
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        context.pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark; // Unused

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _isLoading 
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : TextButton(
                onPressed: _saveProfile,
                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Section
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                      ),
                      child: ClipOval(
                        child: _selectedImage != null
                            ? (kIsWeb 
                                ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                                : Image.file(File(_selectedImage!.path), fit: BoxFit.cover))
                            : _currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: _currentAvatarUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Icon(Icons.person, size: 50, color: AppColors.textSecondary),
                                    errorWidget: (context, url, error) => const Icon(Icons.person, size: 50, color: AppColors.textSecondary),
                                  )
                                : const Icon(Icons.person, size: 60, color: AppColors.primary),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.background, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Change Profile Photo', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
              
              const SizedBox(height: 48),

              // Form Fields
              _buildTextField(
                label: 'Full Name',
                controller: _nameController,
                icon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 24),
              
              _buildTextField(
                label: 'Phone Number',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // Partner feature specific to the PRD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent1.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: AppColors.accent1, size: 20),
                        const SizedBox(width: 8),
                        Text('Couple Profile', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent1)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: "Partner's Name (Optional)",
                      controller: _partnerController,
                      icon: Icons.people_outline,
                      backgroundColor: theme.colorScheme.surface,
                    ),
                    const SizedBox(height: 16),
                    _buildAnniversaryDatePicker(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Color? backgroundColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? (isDark ? AppColors.darkSurface.withOpacity(0.5) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            boxShadow: backgroundColor == null ? [
              BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ] : null,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textSecondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnniversaryDatePicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Anniversary Date', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _anniversaryDate ?? today,
              firstDate: DateTime(1900),
              lastDate: today,
            );
            if (pickedDate != null) {
              setState(() {
                _anniversaryDate = pickedDate;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _anniversaryDate != null
                        ? '${_anniversaryDate!.day}/${_anniversaryDate!.month}/${_anniversaryDate!.year}'
                        : 'Select anniversary date',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _anniversaryDate != null ? null : AppColors.textSecondary.withOpacity(0.6),
                    ),
                  ),
                ),
                if (_anniversaryDate != null)
                  IconButton(
                    icon: Icon(Icons.clear, color: AppColors.textSecondary, size: 20),
                    onPressed: () {
                      setState(() {
                        _anniversaryDate = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
