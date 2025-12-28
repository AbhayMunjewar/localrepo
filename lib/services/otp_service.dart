/// OTPService handles OTP generation and verification
/// Temporarily uses hardcoded OTP "000000" for testing
/// TODO: Replace with actual backend API calls when backend is ready
/// Example backend integration:
///   - sendOTP: POST to backend API to send OTP via email/SMS
///   - verifyOTP: POST to backend API to verify OTP
class OTPService {
  static final OTPService _instance = OTPService._internal();
  factory OTPService() => _instance;
  OTPService._internal();

  // Temporarily hardcoded OTP for testing
  // TODO: Replace with actual OTP from backend
  static const String _tempOTP = "000000";

  /// Send OTP to email and phone number
  /// TODO: Replace with actual API call when backend is ready
  /// Example API integration:
  ///   final response = await http.post(
  ///     Uri.parse('$baseUrl/auth/send-otp'),
  ///     body: {'email': email, 'phone': phone},
  ///   );
  ///   return response.statusCode == 200;
  Future<bool> sendOTP(String email, String phone) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: In real implementation, this will:
      // 1. Call backend API to send OTP to email
      // 2. Call backend API to send OTP via SMS to phone
      // 3. Return success/failure based on API response
      
      // For now, just return success (OTP is hardcoded as "000000")
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verify the entered OTP
  /// TODO: Replace with actual API call when backend is ready
  /// Example API integration:
  ///   final response = await http.post(
  ///     Uri.parse('$baseUrl/auth/verify-otp'),
  ///     body: {'email': email, 'phone': phone, 'otp': otp},
  ///   );
  ///   return response.statusCode == 200;
  Future<bool> verifyOTP(String enteredOTP, {String? email, String? phone}) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // TODO: In real implementation, this will:
      // 1. Call backend API to verify OTP
      // 2. Return true if OTP is valid, false otherwise
      
      // For now, verify against hardcoded OTP "000000"
      return enteredOTP == _tempOTP;
    } catch (e) {
      return false;
    }
  }

  /// Get the temporary OTP (for testing purposes only)
  /// TODO: Remove this method when backend is integrated
  String getTempOTP() {
    return _tempOTP;
  }
}

