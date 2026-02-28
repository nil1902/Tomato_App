import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lovenest/theme/app_colors.dart';
import 'package:lovenest/services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _otpController = TextEditingController();
  bool isVerifying = false;
  bool isResending = false;

  @override
  void initState() {
    super.initState();
    // Auto-send verification email when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendVerificationCode();
    });
  }

  Future<void> _sendVerificationCode() async {
    try {
      final auth = context.read<AuthService>();
      final success = await auth.resendVerificationEmail(email: widget.email);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification code sent to your email!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send code. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error sending verification code: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error. Please check your connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Icon
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                'Verify Your Email',
                style: theme.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                'We sent a 6-digit verification code to:',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                widget.email,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // OTP Input
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  letterSpacing: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
                onChanged: (value) {
                  if (value.length == 6) {
                    _verifyCode();
                  }
                },
              ),
              
              const SizedBox(height: 32),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isVerifying ? null : _verifyCode,
                  child: isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verify Email'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Resend Code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code?",
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: isResending ? null : () async {
                      setState(() => isResending = true);
                      try {
                        await _sendVerificationCode();
                      } finally {
                        if (mounted) {
                          setState(() => isResending = false);
                        }
                      }
                    },
                    child: isResending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Resend',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Back to Login
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Back to Login',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyCode() async {
    if (isVerifying) return; // Prevent double firing
    
    if (_otpController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit code'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isVerifying = true);
    
    final auth = context.read<AuthService>();
    final success = await auth.verifyEmail(
      email: widget.email,
      otp: _otpController.text,
    );
    
    if (mounted) {
      setState(() => isVerifying = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to home after successful verification
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid code. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        _otpController.clear();
      }
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
