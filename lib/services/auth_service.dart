/// AuthService handles authentication logic
/// Currently uses mocked authentication that can be easily replaced with API calls
/// To integrate with backend: replace the mock logic in loginWithEmail and signupWithEmail
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String? _currentUserId;
  String? _currentUserEmail;
  String? _currentUserPhone;
  String? _currentUsername;
  String? _safetyPin;

  bool isLoggedIn() {
    return _isLoggedIn;
  }

  String? getCurrentUserId() {
    return _currentUserId;
  }

  String? getCurrentUserEmail() {
    return _currentUserEmail;
  }

  String? getCurrentUserPhone() {
    return _currentUserPhone;
  }

  String? getCurrentUsername() {
    return _currentUsername;
  }

  /// Get the safety pin
  String? getSafetyPin() {
    return _safetyPin;
  }

  /// Verify the safety pin
  bool verifySafetyPin(String pin) {
    return _safetyPin != null && _safetyPin == pin;
  }

  /// Login with email and password (mocked implementation)
  /// TODO: Replace with actual API call when backend is ready
  /// Example API integration:
  ///   final response = await http.post(
  ///     Uri.parse('$baseUrl/auth/login'),
  ///     body: {'email': email, 'password': password},
  ///   );
  ///   if (response.statusCode == 200) {
  ///     final data = json.decode(response.body);
  ///     _isLoggedIn = true;
  ///     _currentUserId = data['userId'];
  ///     _currentUserEmail = email;
  ///     return true;
  ///   }
  Future<bool> loginWithEmail(String email, String password) async {
    try {
      // Mock authentication - simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock validation - accept any email/password combination
      // In real implementation, validate against backend
      // Note: In real implementation, safety pin should be retrieved from backend
      _isLoggedIn = true;
      _currentUserId = email; // Use email as ID for now
      _currentUserEmail = email;
      // TODO: Load safety pin from backend/secure storage after login
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Signup with email, password, username, phone, and safety pin (mocked implementation)
  /// TODO: Replace with actual API call when backend is ready
  /// Example API integration:
  ///   final response = await http.post(
  ///     Uri.parse('$baseUrl/auth/signup'),
  ///     body: {'email': email, 'password': password, 'username': username, 'phone': phone, 'safetyPin': safetyPin},
  ///   );
  ///   return response.statusCode == 201;
  Future<bool> signupWithEmail(String email, String password, {String? username, String? phone, String? safetyPin}) async {
    try {
      // Mock signup - simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Store user data for later use (when logging in after signup)
      _currentUserEmail = email;
      _currentUsername = username;
      _currentUserPhone = phone;
      _safetyPin = safetyPin;
      _isLoggedIn = true; // Auto-login after signup
      _currentUserId = email; // Use email as ID for now
      
      // Mock validation - accept any email/password combination
      // In real implementation, send to backend to create account
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Legacy login method for phone number (kept for backward compatibility)
  Future<bool> login(String phoneNumber) async {
    try {
      // TODO: Implement actual authentication logic
      // For now, simulate authentication
      await Future.delayed(const Duration(seconds: 1));
      _isLoggedIn = true;
      _currentUserId = phoneNumber;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUserId = null;
    _currentUserEmail = null;
    _currentUserPhone = null;
    _currentUsername = null;
    _safetyPin = null;
    // TODO: Clear any stored tokens or session data
    // Clear user service data
    // Clear guardian service data
  }
}
