import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lovenest/theme/app_colors.dart';
import 'package:lovenest/services/auth_service.dart';
import 'dart:ui';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

enum AuthViewState { credentials, verifying }

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  AuthViewState _viewState = AuthViewState.credentials;
  bool isPasswordVisible = false;
  bool isLoading = false;
  String? errorMessage;
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      errorMessage = message;
      isLoading = false;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => errorMessage = null);
    });
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your full name.');
      return;
    }
    if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
      _showError('Please enter a valid email.');
      return;
    }
    if (_passwordController.text.trim().length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }
    
    setState(() => isLoading = true);
    final auth = context.read<AuthService>();
    final errorMsg = await auth.register(
      email: _emailController.text.trim(), 
      password: _passwordController.text.trim(),
      name: _nameController.text.trim()
    );
    
    if (errorMsg == null) {
      // Registration successful, email already sent by the backend.
      setState(() {
        isLoading = false;
        _viewState = AuthViewState.verifying;
        errorMessage = null; // Clear errors
      });
    } else {
      _showError(errorMsg);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    
    try {
      final auth = context.read<AuthService>();
      final success = await auth.signInWithGoogle();
      
      if (mounted) {
        setState(() => isLoading = false);
        
        if (success) {
          context.go('/home');
        } else {
          _showError('Google Sign-In was cancelled or failed. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showError('An error occurred during Google Sign-In. Please try again.');
      }
    }
  }

  Future<void> _handleVerification() async {
    if (_otpController.text.length < 6) {
      _showError('Please enter the fully 6-digit code.');
      return;
    }
    
    setState(() => isLoading = true);
    final auth = context.read<AuthService>();
    final success = await auth.verifyEmail(
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
    );
    
    if (mounted) {
      if (success) {
        context.go('/home');
      } else {
        _showError('Invalid code. Please try again.');
        _otpController.clear();
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() => isLoading = true);
    final auth = context.read<AuthService>();
    final success = await auth.resendVerificationEmail(email: _emailController.text.trim());
    if (mounted) {
      setState(() => isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code resent!'), backgroundColor: Colors.green));
      } else {
        _showError('Failed to resend code');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
                ? [const Color(0xFF0F172A), const Color(0xFF1E1E2C)]
                : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   // Back Button explicitly positioned
                  if (_viewState == AuthViewState.credentials)
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: isLoading ? null : () => context.pop(),
                      ),
                    ),
                    
                  // App Branding
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFFFF4B72)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.favorite_rounded, size: 50, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // The Glassmorphic Auth Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _viewState == AuthViewState.credentials 
                              ? _buildCredentialsView(theme) 
                              : _buildVerificationView(theme),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialsView(ThemeData theme) {
    return Column(
      key: const ValueKey('credentials'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create Account',
          style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Join LoveNest to book romantic stays',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Error Box
        if (errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
              ],
            ),
          ),

        _buildPremiumTextField(
          label: 'Full Name',
          icon: Icons.person_outline_rounded,
          controller: _nameController,
        ),
        const SizedBox(height: 20),
        _buildPremiumTextField(
          label: 'Email',
          icon: Icons.alternate_email,
          controller: _emailController,
        ),
        const SizedBox(height: 20),
        _buildPremiumTextField(
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 32),
        
        ElevatedButton(
          onPressed: isLoading ? null : _handleRegister,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: AppColors.primary,
            elevation: 8,
            shadowColor: AppColors.primary.withOpacity(0.5),
          ),
          child: isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        const SizedBox(height: 20),
        
        // Divider with OR
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.textSecondary.withOpacity(0.3), thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            Expanded(child: Divider(color: AppColors.textSecondary.withOpacity(0.3), thickness: 1)),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Google Sign-In Button
        OutlinedButton.icon(
          onPressed: isLoading ? null : _handleGoogleSignIn,
          icon: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg.png',
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 32, color: Color(0xFF4285F4)),
          ),
          label: const Text('Continue with Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: BorderSide(color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1), width: 1.5),
            foregroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already have an account? ", style: TextStyle(color: AppColors.textSecondary)),
            GestureDetector(
              onTap: () => context.pop(),
              child: const Text('Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerificationView(ThemeData theme) {
    return Column(
      key: const ValueKey('verifying'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read_rounded, size: 60, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          'Check Your Email',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve sent a 6-digit code to\n${_emailController.text}',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
          ),

        // OTP Input
        Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? Colors.black26 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
          ),
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, letterSpacing: 24, fontWeight: FontWeight.w700),
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: '••••••',
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.symmetric(vertical: 20),
            ),
            onChanged: (val) {
              if (val.length == 6) _handleVerification();
            },
          ),
        ),
        
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: isLoading ? null : _handleVerification,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: AppColors.primary,
          ),
          child: isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('VERIFY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        const SizedBox(height: 20),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _viewState = AuthViewState.credentials;
                  _otpController.clear();
                  errorMessage = null;
                });
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Change Email'),
            ),
            TextButton(
              onPressed: isLoading ? null : _resendCode,
              child: const Text('Resend Code', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildPremiumTextField({required String label, required IconData icon, bool isPassword = false, required TextEditingController controller}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.8), size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: AppColors.textSecondary, size: 20),
                  onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }
}
