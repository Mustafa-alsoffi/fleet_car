import 'package:flutter/material.dart';

import '../models/work_log_model.dart';
import '../services/work_log_service.dart';

class ManageWorkLogsPage extends StatelessWidget {
  final WorkLogService _workLogService = WorkLogService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Work Logs'),
      ),
      body: StreamBuilder<List<WorkLog>>(
        stream: _workLogService.getWorkLogs(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final workLogs = snapshot.data!;

          return ListView.builder(
            itemCount: workLogs.length,
            itemBuilder: (context, index) {
              final workLog = workLogs[index];
              return ListTile(
                title: Text(workLog.workPerformed),
                subtitle: Text('${workLog.personInCharge}, ${workLog.date}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Implement edit functionality
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () =>
                          _workLogService.deleteWorkLog(workLog.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add functionality
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
