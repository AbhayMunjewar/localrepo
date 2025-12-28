import 'package:flutter/material.dart';
import '../models/guardian_model.dart';
import '../widgets/guardian_card.dart';
import '../services/guardian_service.dart';
import '../core/utils.dart';

class GuardiansScreen extends StatefulWidget {
  const GuardiansScreen({super.key});

  @override
  State<GuardiansScreen> createState() => _GuardiansScreenState();
}

class _GuardiansScreenState extends State<GuardiansScreen> {
  final GuardianService _guardianService = GuardianService();
  final nameC = TextEditingController();
  final ageC = TextEditingController();
  final relationC = TextEditingController();
  final phoneC = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {}); // Refresh to show existing guardians
  }

  void addGuardian() {
    if (nameC.text.trim().isEmpty || phoneC.text.trim().isEmpty) {
      Utils.showSnackBar(context, "Name and phone are required");
      return;
    }

    final cleanedPhone = Utils.formatPhone(phoneC.text);
    if (cleanedPhone.length < 10) {
      Utils.showSnackBar(context, "Please enter a valid phone number");
      return;
    }

    setState(() {
      _guardianService.addGuardian(
        Guardian(
          name: nameC.text.trim(),
          age: int.tryParse(ageC.text) ?? 0,
          relation: relationC.text.trim().isEmpty ? "Guardian" : relationC.text.trim(),
          phone: cleanedPhone,
        ),
      );
    });

    nameC.clear();
    ageC.clear();
    relationC.clear();
    phoneC.clear();
  }

  @override
  void dispose() {
    nameC.dispose();
    ageC.dispose();
    relationC.dispose();
    phoneC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Guardians")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                labelText: "Name *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ageC,
              decoration: const InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: relationC,
              decoration: const InputDecoration(
                labelText: "Relation",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.family_restroom),
                hintText: "e.g., Mother, Father, Friend",
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneC,
              decoration: const InputDecoration(
                labelText: "Phone Number *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                hintText: "10 digit phone number",
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addGuardian,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Add Guardian"),
              ),
            ),
            const Divider(),
            Expanded(
              child: _guardianService.getGuardians().isEmpty
                  ? const Center(
                      child: Text(
                        "No guardians added yet.\nAdd guardians to receive emergency alerts.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _guardianService.getGuardians().length,
                      itemBuilder: (c, i) => GuardianCard(
                        guardian: _guardianService.getGuardians()[i],
                        onDelete: () {
                          setState(() {
                            _guardianService.removeGuardianAt(i);
                          });
                        },
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
