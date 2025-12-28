import 'dart:async';
import 'package:flutter/foundation.dart';
import 'sms_service.dart';
import 'location_service.dart';
import 'incident_service.dart';
import 'guardian_service.dart';
import '../core/constants.dart';

/// EmergencyService manages the 20-second emergency mode state
/// Handles emergency activation, countdown, and automatic deactivation
/// Triggers emergency actions (SMS, location sharing) during the active period
class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  bool _isEmergencyActive = false;
  int _remainingSeconds = 20;
  Timer? _countdownTimer;
  VoidCallback? _onEmergencyStateChanged;
  VoidCallback? _onEmergencyComplete;

  bool get isEmergencyActive => _isEmergencyActive;
  int get remainingSeconds => _remainingSeconds;

  /// Set callback for when emergency state changes (for UI updates)
  void setOnEmergencyStateChanged(VoidCallback? callback) {
    _onEmergencyStateChanged = callback;
  }

  /// Set callback for when emergency completes
  void setOnEmergencyComplete(VoidCallback? callback) {
    _onEmergencyComplete = callback;
  }

  /// Activate emergency mode for 20 seconds
  /// Triggers emergency actions and starts countdown timer
  /// Shows "Emergency SOS Activated" banner during the active period
  Future<void> activateEmergency() async {
    if (_isEmergencyActive) {
      // Already active, don't restart
      return;
    }

    _isEmergencyActive = true;
    _remainingSeconds = 20;
    _onEmergencyStateChanged?.call();

    // Trigger emergency actions immediately
    _triggerEmergencyActions();

    // Start countdown timer - automatically deactivates after 20 seconds
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      _onEmergencyStateChanged?.call();

      if (_remainingSeconds <= 0) {
        _deactivateEmergency();
      }
    });
  }

  /// Deactivate emergency mode
  /// Called automatically after 20 seconds or manually if needed
  void _deactivateEmergency() {
    if (!_isEmergencyActive) {
      return;
    }

    _isEmergencyActive = false;
    _remainingSeconds = 0;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _onEmergencyStateChanged?.call();
    _onEmergencyComplete?.call();
  }

  /// Manually cancel emergency (if needed)
  void cancelEmergency() {
    _deactivateEmergency();
  }

  /// Trigger emergency actions (send SMS, log incident)
  /// This is called immediately when emergency is activated
  Future<void> _triggerEmergencyActions() async {
    final guardianService = GuardianService();
    final locationService = LocationService();
    final smsService = SmsService();

    try {
      final locationLink = await locationService.getLocationLink();
      final location = await locationService.getCurrentLocation();
      final message = "EMERGENCY! I need help. Location: $locationLink";

      final guardianPhones = guardianService.getGuardianPhones();
      final policeNumber = AppConstants.policeHelpline;

      // Send to guardians
      if (guardianPhones.isNotEmpty) {
        await smsService.sendEmergencySMS(guardianPhones, message);
      }

      // Send to police
      await smsService.sendSMS(
        policeNumber,
        "EMERGENCY ALERT: User needs immediate assistance. Location: $locationLink. Coordinates: ${location['latitude']}, ${location['longitude']}",
      );

      // Log the incident
      IncidentService.logIncident("Emergency SOS triggered - Location sent to guardians and police", true);
    } catch (e) {
      // Log error but don't prevent emergency mode from completing
      IncidentService.logIncident("Emergency SOS triggered but failed to send messages: $e", false);
    }
  }

  void dispose() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }
}
