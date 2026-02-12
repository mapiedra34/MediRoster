import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/case_service.dart';
import '../models/case_model.dart';

/// View all medical cases
class ViewCasesPage extends StatelessWidget {
  const ViewCasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final caseService = context.read<CaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Cases'),
      ),
      body: StreamBuilder<List<CaseModel>>(
        stream: caseService.getCasesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final cases = snapshot.data ?? [];

          if (cases.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No cases found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final caseItem = cases[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.medical_services,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    caseItem.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Operation: ${caseItem.operation}'),
                      Text('Time: ${caseItem.startTime} - ${caseItem.endTime}'),
                      Text('Required Nurses: ${caseItem.requiredNurses}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    if (caseItem.caseId != null) {
                      Navigator.pushNamed(
                        context,
                        '/view-case-details',
                        arguments: caseItem.caseId,
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
