import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/case_service.dart';
import '../models/case_model.dart';

/// View detailed information about a specific case
class ViewCaseDetailsPage extends StatelessWidget {
  final String caseId;

  const ViewCaseDetailsPage({super.key, required this.caseId});

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Case'),
        content: const Text('Are you sure you want to delete this case?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<CaseService>().deleteCase(caseId);
        if (context.mounted) {
          Fluttertoast.showToast(
            msg: 'Case deleted successfully',
            backgroundColor: Colors.green,
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          Fluttertoast.showToast(
            msg: 'Error: $e',
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/edit-case',
                arguments: caseId,
              );
            },
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _handleDelete(context),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: FutureBuilder<CaseModel?>(
        future: context.read<CaseService>().getCaseById(caseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final caseData = snapshot.data;
          if (caseData == null) {
            return const Center(
              child: Text('Case not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.medical_services,
                              color: Theme.of(context).primaryColor,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                caseData.description,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          icon: Icons.local_hospital,
                          label: 'Operation',
                          value: caseData.operation,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.access_time,
                          label: 'Start Time',
                          value: caseData.startTime,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.access_time_filled,
                          label: 'End Time',
                          value: caseData.endTime,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.people,
                          label: 'Required Nurses',
                          value: caseData.requiredNurses.toString(),
                        ),
                        if (caseData.scheduledShiftId != null) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.schedule,
                            label: 'Shift ID',
                            value: caseData.scheduledShiftId!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assigned Nurses',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<List<String>>(
                          future: context
                              .read<CaseService>()
                              .getNursesForCase(caseId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            final nurses = snapshot.data ?? [];
                            if (nurses.isEmpty) {
                              return const Text(
                                'No nurses assigned yet',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              );
                            }

                            return Column(
                              children: nurses.map((nurse) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(nurse[0].toUpperCase()),
                                  ),
                                  title: Text(nurse),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
