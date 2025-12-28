import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'guardians_screen.dart';
import 'incident_history_screen.dart';
import 'news_screen.dart';
import 'emergency_hud_screen.dart';
import 'settings_screen.dart';
import 'map_screen.dart';
import '../widgets/sos_button.dart';
import '../widgets/feature_title.dart';
import '../core/constants.dart';
import '../services/shake_service.dart';
import '../services/settings_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ShakeService _shakeService = ShakeService();
  final SettingsService _settingsService = SettingsService();

  void _triggerEmergency() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmergencyHUD()),
    );
  }

  @override
  void initState() {
    super.initState();
    // Start listening for shake gestures only if panic gesture detection is enabled
    // Respects the toggle state from Settings screen
    if (_settingsService.isPanicGestureEnabled()) {
      _shakeService.startListening(_triggerEmergency);
    }
    
    // TODO: Start microphone listening for voice SOS if microphone is enabled
    // Example implementation:
    // if (_settingsService.isMicrophoneEnabled()) {
    //   _microphoneService.startListening(_triggerEmergency);
    // }
  }

  @override
  void dispose() {
    _shakeService.stopListening();
    // TODO: Stop microphone listening if it was started
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SOSButton(
                  onPressed: _triggerEmergency,
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    FeatureTile(
                      icon: Icons.person,
                      title: "Profile",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      ),
                    ),
                    FeatureTile(
                      icon: Icons.people,
                      title: "Guardians",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GuardiansScreen()),
                      ),
                    ),
                    FeatureTile(
                      icon: Icons.history,
                      title: "Incidents",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IncidentHistoryScreen()),
                      ),
                    ),
                    FeatureTile(
                      icon: Icons.article,
                      title: "Safety News",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NewsScreen()),
                      ),
                    ),
                    FeatureTile(
                      icon: Icons.map,
                      title: "Safety Map",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MapScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
