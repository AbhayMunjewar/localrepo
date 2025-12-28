import 'package:flutter/material.dart';
import '../services/incident_service.dart';
import '../core/utils.dart';

class IncidentHistoryScreen extends StatefulWidget {
  const IncidentHistoryScreen({super.key});

  @override
  State<IncidentHistoryScreen> createState() => _IncidentHistoryScreenState();
}

class _IncidentHistoryScreenState extends State<IncidentHistoryScreen> {
  final _descriptionController = TextEditingController();

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minute(s) ago';
      }
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day(s) ago';
    } else {
      // Format: MMM dd, yyyy - hh:mm a
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months[date.month - 1];
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final amPm = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      return '$month ${date.day}, ${date.year} - $hour:$minute $amPm';
    }
  }

  void _addIncident() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Incident"),
        content: TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: "Description",
            hintText: "Describe what happened...",
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _descriptionController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_descriptionController.text.trim().isNotEmpty) {
                IncidentService.logIncident(
                  _descriptionController.text.trim(),
                  false,
                );
                _descriptionController.clear();
                Navigator.pop(context);
                setState(() {}); // Refresh the list
                Utils.showSnackBar(context, "Incident added successfully");
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incidents = IncidentService.incidents;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Incident History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addIncident,
            tooltip: "Add Incident",
          ),
        ],
      ),
      body: incidents.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No incidents recorded yet",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: incidents.length,
              itemBuilder: (c, i) {
                final item = incidents[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.emergencyTriggered
                          ? Colors.red.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                      child: Icon(
                        item.emergencyTriggered ? Icons.warning : Icons.note,
                        color: item.emergencyTriggered ? Colors.red : Colors.blue,
                      ),
                    ),
                    title: Text(
                      item.description,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(_formatDate(item.date)),
                    trailing: item.emergencyTriggered
                        ? const Chip(
                            label: Text("SOS", style: TextStyle(fontSize: 10)),
                            backgroundColor: Colors.red,
                            labelStyle: TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
