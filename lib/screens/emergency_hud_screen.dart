import 'package:flutter/material.dart';
import 'dart:async';
import '../services/emergency_service.dart';
import '../services/auth_service.dart';
import '../core/utils.dart';
import 'home_screen.dart';

/// EmergencyHUD displays the 20-second emergency mode activation
/// Shows "Emergency SOS Activated" banner and countdown
/// Automatically deactivates and navigates back after 20 seconds
/// Emergency actions (SMS, location) are triggered immediately upon activation
class EmergencyHUD extends StatefulWidget {
  const EmergencyHUD({super.key});

  @override
  State<EmergencyHUD> createState() => _EmergencyHUDState();
}

class _EmergencyHUDState extends State<EmergencyHUD> {
  final EmergencyService _emergencyService = EmergencyService();
  final TextEditingController _pinController = TextEditingController();
  int _remainingSeconds = 20;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // Activate emergency mode immediately (triggers emergency actions)
    _emergencyService.activateEmergency();
    
    // Set callback to update UI when emergency state changes
    _emergencyService.setOnEmergencyStateChanged(() {
      if (mounted) {
        setState(() {
          _remainingSeconds = _emergencyService.remainingSeconds;
        });
      }
    });
    
    // Set callback to navigate back when emergency completes
    _emergencyService.setOnEmergencyComplete(() {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    });
    
    // Update UI every second to show countdown
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds = _emergencyService.remainingSeconds;
        });
        
        // Auto-navigate back when emergency completes
        if (!_emergencyService.isEmergencyActive) {
          timer.cancel();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          }
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _cancel() {
    final authService = AuthService();
    final safetyPin = authService.getSafetyPin();
    
    if (safetyPin == null || safetyPin.isEmpty) {
      // If no safety pin is set, allow cancel without verification
      _emergencyService.cancelEmergency();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
      return;
    }
    
    // Verify the entered pin
    final enteredPin = _pinController.text;
    if (enteredPin.isEmpty) {
      Utils.showSnackBar(context, "Please enter your safety pin");
      return;
    }
    
    if (authService.verifySafetyPin(enteredPin)) {
      _emergencyService.cancelEmergency();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } else {
      Utils.showSnackBar(context, "Incorrect safety pin. Please try again.");
      _pinController.clear();
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _pinController.dispose();
    // Note: Don't dispose emergency service as it's a singleton
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final safetyPin = authService.getSafetyPin();
    final showPinField = safetyPin != null && safetyPin.isNotEmpty;
    
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Theme.of(context).scaffoldBackgroundColor 
          : Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Emergency SOS Activated",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "$_remainingSeconds",
                style: const TextStyle(color: Colors.red, fontSize: 64, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "seconds remaining",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              if (showPinField) ...[
                const SizedBox(height: 40),
                Text(
                  "Enter Safety Pin to Cancel",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      hintText: "PIN",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.purple, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    maxLength: 4,
                    onSubmitted: (_) => _cancel(),
                  ),
                ),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _cancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text("Cancel"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
