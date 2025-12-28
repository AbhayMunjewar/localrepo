import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/otp_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// SignupScreen provides email/password registration
/// Navigates to LoginScreen after successful signup
/// Uses mocked authentication that can be easily replaced with API calls
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _safetyPinController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isVerifyingOTP = false;
  bool _showOTPVerification = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscureSafetyPin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _safetyPinController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // Basic email validation
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a username';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 10) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validateSafetyPin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a safety pin';
    }
    if (value.length != 4) {
      return 'Safety pin must be exactly 4 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Safety pin must contain only digits';
    }
    return null;
  }

  void _requestOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final otpService = OTPService();
      final cleanedPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      
      // Send OTP to email and phone
      final success = await otpService.sendOTP(
        _emailController.text.trim(),
        cleanedPhone,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          setState(() => _showOTPVerification = true);
          Utils.showSnackBar(
            context,
            "OTP sent to your email and phone number",
          );
        } else {
          Utils.showSnackBar(context, "Failed to send OTP. Please try again.");
        }
      }
    }
  }

  void _verifyOTPAndSignup() async {
    if (_otpController.text.isEmpty) {
      Utils.showSnackBar(context, "Please enter the OTP");
      return;
    }

    setState(() => _isVerifyingOTP = true);

    final otpService = OTPService();
    final cleanedPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Verify OTP
    final otpValid = await otpService.verifyOTP(
      _otpController.text.trim(),
      email: _emailController.text.trim(),
      phone: cleanedPhone,
    );

    if (!mounted) return;

    if (!otpValid) {
      setState(() => _isVerifyingOTP = false);
      Utils.showSnackBar(context, "Invalid OTP. Please try again.");
      _otpController.clear();
      return;
    }

    // OTP verified, proceed with signup
    final authService = AuthService();
    final userService = UserService();
    
    final success = await authService.signupWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
      username: _usernameController.text.trim(),
      phone: cleanedPhone,
      safetyPin: _safetyPinController.text,
    );

    if (mounted) {
      setState(() => _isVerifyingOTP = false);

      if (success) {
        // Initialize user data
        userService.updateUser(
          name: _usernameController.text.trim().isNotEmpty ? _usernameController.text.trim() : "User",
          age: 0,
          phone: cleanedPhone,
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          bloodGroup: "",
          address: "",
        );
        
        // After successful signup, navigate directly to home screen
        Utils.showSnackBar(context, "Account created successfully!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Utils.showSnackBar(context, "Signup failed. Please try again.");
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showOTPVerification) {
      return _buildOTPVerificationScreen();
    }
    return _buildSignupForm();
  }

  Widget _buildOTPVerificationScreen() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user,
                  size: 80,
                  color: AppConstants.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  "Verify OTP",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "OTP sent to your email and phone",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    letterSpacing: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "000000",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 32,
                      letterSpacing: 12,
                    ),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.purple, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  maxLength: 6,
                  autofocus: true,
                  onSubmitted: (_) => _verifyOTPAndSignup(),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isVerifyingOTP ? null : _verifyOTPAndSignup,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isVerifyingOTP
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Verify OTP & Sign Up"),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showOTPVerification = false;
                      _otpController.clear();
                    });
                  },
                  child: Text(
                    "Back",
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield,
                    size: 80,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Create Account",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.tagline,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateEmail,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: "Username",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateUsername,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: "Phone Number",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validatePhone,
                    textInputAction: TextInputAction.next,
                    maxLength: 10,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _safetyPinController,
                    obscureText: _obscureSafetyPin,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Safety Pin (4 digits)",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.pin),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureSafetyPin ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _obscureSafetyPin = !_obscureSafetyPin);
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: _validateSafetyPin,
                    textInputAction: TextInputAction.next,
                    maxLength: 4,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: _validatePassword,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: _validateConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _requestOTP(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _requestOTP,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Send OTP"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _navigateToLogin,
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
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
}
