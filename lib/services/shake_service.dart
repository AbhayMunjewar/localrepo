import 'dart:async';
import 'package:flutter/material.dart';

class ShakeService {
  static final ShakeService _instance = ShakeService._internal();
  factory ShakeService() => _instance;
  ShakeService._internal();

  bool _isListening = false;
  VoidCallback? _onShakeCallback;
  double _sensitivity = 5.0;
  StreamSubscription<dynamic>? _subscription;
  Timer? _debounceTimer;
  DateTime? _lastShakeTime;

  void setSensitivity(double sensitivity) {
    _sensitivity = sensitivity.clamp(1.0, 10.0);
  }

  double getSensitivity() {
    return _sensitivity;
  }

  void startListening(VoidCallback onShake) {
    if (_isListening) {
      stopListening();
    }
    
    _isListening = true;
    _onShakeCallback = onShake;
    
    // TODO: Implement actual accelerometer listening
    // To implement, add 'sensors' package to pubspec.yaml:
    // dependencies:
    //   sensors: ^1.0.0
    //
    // Then uncomment and use:
    // import 'package:sensors_plus/sensors_plus.dart';
    // import 'dart:math';
    //
    // _subscription = accelerometerEventStream().listen((event) {
    //   // Use processAccelerometerData which internally calls _handleShakeDetection
    //   processAccelerometerData(event.x, event.y, event.z);
    // });
  }

  /// Handles shake detection with debouncing to prevent multiple rapid triggers
  /// This method uses _lastShakeTime to ensure at least 2 seconds between triggers
  void _handleShakeDetection(double acceleration) {
    if (!_isListening || _onShakeCallback == null) {
      return;
    }

    final now = DateTime.now();
    const debounceSeconds = 2;

    // Check if enough time has passed since last shake
    if (_lastShakeTime == null ||
        now.difference(_lastShakeTime!).inSeconds >= debounceSeconds) {
      // Check if acceleration exceeds sensitivity threshold
      if (acceleration > _sensitivity) {
        _lastShakeTime = now;
        _onShakeCallback?.call();
      }
    }
  }

  /// Manually trigger shake detection (useful for testing or simulation)
  /// This method uses _handleShakeDetection with a simulated acceleration value
  /// that exceeds the sensitivity threshold
  void triggerShake() {
    if (!_isListening || _onShakeCallback == null) {
      return;
    }
    // Simulate a shake with acceleration above sensitivity threshold
    // Using sensitivity + 1 to ensure it triggers
    _handleShakeDetection(_sensitivity + 1.0);
  }

  /// Process accelerometer data - call this when you receive accelerometer events
  /// This method uses _handleShakeDetection to process the acceleration value
  void processAccelerometerData(double x, double y, double z) {
    if (!_isListening) {
      return;
    }
    // Calculate total acceleration magnitude
    final acceleration = (x * x + y * y + z * z) / 3.0; // Simplified calculation
    _handleShakeDetection(acceleration);
  }

  /// Get the time elapsed since last shake detection
  /// Returns null if no shake has been detected yet
  Duration? getTimeSinceLastShake() {
    if (_lastShakeTime == null) {
      return null;
    }
    return DateTime.now().difference(_lastShakeTime!);
  }

  /// Check if shake can be triggered (debounce period has passed)
  bool canTriggerShake() {
    if (_lastShakeTime == null) {
      return true;
    }
    const debounceSeconds = 2;
    return DateTime.now().difference(_lastShakeTime!).inSeconds >= debounceSeconds;
  }

  void stopListening() {
    _isListening = false;
    _onShakeCallback = null;
    _subscription?.cancel();
    _subscription = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  bool isListening() {
    return _isListening;
  }
}
