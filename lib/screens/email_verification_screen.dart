import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lovenest/theme/app_colors.dart';
import 'package:lovenest/services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  
  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _otpController = TextEditingController();
  bool isVerifying = false;
  bool isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              
              // Title
              Text(
                'Verify Your Email',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
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
              
              // OTP Input Field - BIG AND CLEAR
              Text(
                'Enter Verification Code',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 12),
              
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 16,
                ),
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.3),
                    letterSpacing: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  counterText: '',
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Resend Code Button
              Center(
                child: TextButton.icon(
                  onPressed: isResending ? null : () async {
                    setState(() => isResending = true);
                    final auth = context.read<AuthService>();
                    final success = await auth.resendVerificationEmail(email: widget.email);
                    setState(() => isResending = false);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'New code sent to your email!' : 'Failed to send code. Try again.'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  icon: isResending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    isResending ? 'Sending...' : 'Resend Code',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Verify Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isVerifying ? null : () async {
                    if (_otpController.text.length != 6) {
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
                    
                    setState(() => isVerifying = false);
                    
                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Email verified successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        context.go('/home');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ Invalid code. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Verify Email',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Skip for now button
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Verify Later'),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
