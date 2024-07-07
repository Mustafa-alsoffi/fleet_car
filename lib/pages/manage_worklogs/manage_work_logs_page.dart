import 'package:flutter/material.dart';

import '../../models/work_log_model.dart';
import '../../services/car_service.dart';
import '../../services/work_log_service.dart';
import 'add_edit_worklog_page.dart';

class ManageWorkLogsPage extends StatelessWidget {
  final WorkLogService _workLogService = WorkLogService();
  final _carService = CarService();
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
                      onPressed: () async {
                        // Implement edit functionality
                        final car = await _carService.getCarById(workLog.carId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditWorkLogPage(
                              workLog: workLog,
                              car: car,
                            ),
                          ),
                        );
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
    );
  }
}
