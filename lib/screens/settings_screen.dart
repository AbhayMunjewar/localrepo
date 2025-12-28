import 'package:flutter/material.dart';
import '../services/shake_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/settings_service.dart';
import '../core/constants.dart';
import 'auth_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  final ShakeService _shakeService = ShakeService();
  final AuthService _authService = AuthService();
  final ThemeService _themeService = ThemeService();
  final SettingsService _settingsService = SettingsService();
  late double sensitivity;
  late ThemeMode _currentThemeMode;
  late bool _microphoneEnabled;
  late bool _panicGestureEnabled;

  @override
  void initState() {
    super.initState();
    sensitivity = _shakeService.getSensitivity();
    _currentThemeMode = _themeService.themeMode;
    _microphoneEnabled = _settingsService.isMicrophoneEnabled();
    _panicGestureEnabled = _settingsService.isPanicGestureEnabled();
    _themeService.themeNotifier.addListener(_onThemeChanged);
    WidgetsBinding.instance.addObserver(this);
    _checkMicrophonePermission();
  }

  @override
  void dispose() {
    _themeService.themeNotifier.removeListener(_onThemeChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check permission when app resumes (user returns from settings)
      _checkMicrophonePermission();
    }
  }

  Future<void> _checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      // Permission is granted, enable toggle if it was enabled in settings
      if (_settingsService.isMicrophoneEnabled()) {
        setState(() {
          _microphoneEnabled = true;
        });
      }
    } else {
      // Permission is not granted, disable toggle
      setState(() {
        _microphoneEnabled = false;
      });
      _settingsService.setMicrophoneEnabled(false);
    }
  }

  void _onThemeChanged() {
    setState(() {
      _currentThemeMode = _themeService.themeMode;
    });
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose Theme"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text("Light"),
              value: ThemeMode.light,
              groupValue: _currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  _themeService.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text("Dark"),
              value: ThemeMode.dark,
              groupValue: _currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  _themeService.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text("System Default"),
              value: ThemeMode.system,
              groupValue: _currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  _themeService.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Request microphone permission and update toggle state
  /// Uses permission_handler to request system permission
  Future<void> _handleMicrophoneToggle(bool value) async {
    if (value) {
      // Check current permission status
      var status = await Permission.microphone.status;
      
      if (status.isGranted) {
        // Permission already granted
        setState(() => _microphoneEnabled = true);
        _settingsService.setMicrophoneEnabled(true);
      } else if (status.isDenied) {
        // Permission not requested yet, request it
        status = await Permission.microphone.request();
        if (status.isGranted) {
          setState(() => _microphoneEnabled = true);
          _settingsService.setMicrophoneEnabled(true);
        } else {
          // Permission denied, keep toggle off
          setState(() => _microphoneEnabled = false);
          if (mounted) {
            _showPermissionDeniedDialog();
          }
        }
      } else if (status.isPermanentlyDenied) {
        // Permission permanently denied, need to open settings
        setState(() => _microphoneEnabled = false);
        if (mounted) {
          _showOpenSettingsDialog();
        }
      } else {
        // Other status (restricted, etc.), keep toggle off
        setState(() => _microphoneEnabled = false);
        if (mounted) {
          _showPermissionDeniedDialog();
        }
      }
    } else {
      // Disable microphone
      setState(() => _microphoneEnabled = false);
      _settingsService.setMicrophoneEnabled(false);
    }
  }

  Future<void> _openSettings() async {
    try {
      // Try using permission_handler's openAppSettings
      final opened = await openAppSettings();
      
      // If openAppSettings returns false, show manual instructions
      if (!opened && mounted) {
        _showManualSettingsInstructions();
      }
      // If it returns true, the settings should have opened
      // User can enable permission and return to app
    } catch (e) {
      // If there's an error, show manual instructions
      if (mounted) {
        _showManualSettingsInstructions();
      }
    }
  }

  void _showManualSettingsInstructions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Enable Microphone Permission"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Follow these steps to enable microphone permission:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "For Vivo phones:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text("1. Open Settings"),
              const Text("2. Go to More Settings"),
              const Text("3. Tap on Permission Management"),
              const Text("4. Tap on Apps"),
              const Text("5. Find and tap on 'RAKSHA'"),
              const Text("6. Tap on Microphone"),
              const Text("7. Enable the permission"),
              const SizedBox(height: 16),
              const Text(
                "Alternative method:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text("1. Open Settings"),
              const Text("2. Go to Apps/Applications"),
              const Text("3. Find 'RAKSHA'"),
              const Text("4. Tap on Permissions"),
              const Text("5. Enable Microphone"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("I'll do it manually"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Try opening settings again
              await _openSettings();
            },
            child: const Text("Try Opening Settings"),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Microphone Permission Required"),
        content: const Text(
          "Microphone permission is required for voice-activated SOS. "
          "Please enable it from app settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _openSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Microphone Permission Required"),
        content: const Text(
          "Microphone permission has been permanently denied. "
          "Please enable it from app settings to use this feature.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _openSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  /// Update panic gesture detection toggle state
  /// When disabled, panic gesture detection should not start
  void _handlePanicGestureToggle(bool value) {
    setState(() => _panicGestureEnabled = value);
    _settingsService.setPanicGestureEnabled(value);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Log Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Safety Hub")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Shake Sensitivity"),
          Slider(
            min: 1,
            max: 10,
            value: sensitivity,
            onChanged: (v) {
              setState(() => sensitivity = v);
              _shakeService.setSensitivity(v);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text("Police Helpline"),
            subtitle: const Text(AppConstants.policeHelpline),
            trailing: const Icon(Icons.phone),
            onTap: () => _makePhoneCall(AppConstants.policeHelpline),
          ),
          ListTile(
            title: const Text("Women Helpline"),
            subtitle: const Text("181"),
            trailing: const Icon(Icons.phone),
            onTap: () => _makePhoneCall("181"),
          ),
          ListTile(
            title: const Text("Ambulance"),
            subtitle: const Text(AppConstants.ambulanceHelpline),
            trailing: const Icon(Icons.phone),
            onTap: () => _makePhoneCall(AppConstants.ambulanceHelpline),
          ),
          const Divider(),
          // Permissions and Controls Section
          const Text(
            "Permissions & Controls",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text("Microphone Access"),
            subtitle: const Text("Enable voice-activated SOS"),
            secondary: const Icon(Icons.mic),
            value: _microphoneEnabled,
            onChanged: _handleMicrophoneToggle,
          ),
          SwitchListTile(
            title: const Text("Panic Gesture Detection"),
            subtitle: const Text("Enable shake gesture SOS trigger"),
            secondary: const Icon(Icons.vibration),
            value: _panicGestureEnabled,
            onChanged: _handlePanicGestureToggle,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Note: Keeping these features always ON may increase battery usage.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text("Theme"),
            subtitle: Text(_themeService.getThemeModeName()),
            leading: Icon(
              _currentThemeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : _currentThemeMode == ThemeMode.light
                      ? Icons.light_mode
                      : Icons.brightness_auto,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showThemeDialog,
          ),
          ListTile(
            title: const Text("Privacy Policy"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to privacy policy screen
            },
          ),
          ListTile(
            title: const Text("Log Out", style: TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.logout, color: Colors.red),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }
}
