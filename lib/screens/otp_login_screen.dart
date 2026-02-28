import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lovenest/theme/app_colors.dart';
import 'package:lovenest/services/auth_service.dart';

class OTPLoginScreen extends StatefulWidget {
  const OTPLoginScreen({super.key});

  @override
  State<OTPLoginScreen> createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  bool _isLoading = false;
  bool _otpSent = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() => _countdown--);
        _startCountdown();
      }
    });
  }

  Future<void> _requestOTP() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final auth = context.read<AuthService>();
    final success = await auth.requestOTP(phone: _phoneController.text);
    
    setState(() {
      _isLoading = false;
      if (success) {
        _otpSent = true;
        _countdown = 60;
        _startCountdown();
      }
    });
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP. Please try again.')),
      );
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    final auth = context.read<AuthService>();
    final success = await auth.loginWithOTP(
      phone: _phoneController.text,
      otp: _otpController.text,
    );
    
    setState(() => _isLoading = false);
    
    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark; // Unused

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              
              const SizedBox(height: 40),
              
              // Title
              Text(
                _otpSent ? 'Enter OTP' : 'Login with OTP',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _otpSent 
                  ? 'We sent a 6-digit code to ${_phoneController.text}'
                  : 'Enter your phone number to receive OTP',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 48),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Phone number field
                    if (!_otpSent)
                      _buildTextField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Phone number is required';
                          if (val.length < 10) return 'Enter a valid phone number';
                          return null;
                        },
                      ),
                    
                    // OTP field (only shown after OTP is sent)
                    if (_otpSent) ...[
                      _buildOTPField(),
                      const SizedBox(height: 24),
                      
                      // Resend OTP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive code? ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (_countdown > 0)
                            Text(
                              'Resend in $_countdown s',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else
                            TextButton(
                              onPressed: _requestOTP,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Resend OTP',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Change Phone Number Button
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _otpSent = false;
                              _otpController.clear();
                            });
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Change Phone Number'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 48),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : (_otpSent ? _verifyOTP : _requestOTP),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                            : Text(
                                _otpSent ? 'Verify & Login' : 'Send OTP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Back to email login
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Back to Email Login',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
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
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface.withOpacity(0.5) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildOTPField() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('6-digit OTP', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
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
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: theme.textTheme.headlineMedium?.copyWith(
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              hintText: '000000',
              hintStyle: theme.textTheme.headlineMedium?.copyWith(
                letterSpacing: 8,
                color: AppColors.textSecondary.withOpacity(0.3),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}