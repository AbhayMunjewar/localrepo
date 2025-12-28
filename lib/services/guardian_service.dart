import '../models/guardian_model.dart';

class GuardianService {
  static final GuardianService _instance = GuardianService._internal();
  factory GuardianService() => _instance;
  GuardianService._internal();

  final List<Guardian> _guardians = [];

  List<Guardian> getGuardians() {
    return List.unmodifiable(_guardians);
  }

  List<String> getGuardianPhones() {
    return _guardians.map((g) => g.phone).toList();
  }

  void addGuardian(Guardian guardian) {
    _guardians.add(guardian);
  }

  void removeGuardian(Guardian guardian) {
    _guardians.remove(guardian);
  }

  void removeGuardianAt(int index) {
    if (index >= 0 && index < _guardians.length) {
      _guardians.removeAt(index);
    }
  }

  void clearGuardians() {
    _guardians.clear();
  }

  bool hasGuardians() {
    return _guardians.isNotEmpty;
  }
}

