import 'package:fleet_car/pages/reports_page.dart';
import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'manage_worklogs/manage_work_logs_page.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;
  bool _isFirstTime = true; // Add this flag
  final List<Widget> _children = [
    DashboardPage(),
    ManageWorkLogsPage(),
    ReportsPage(),
    Page4(),
  ];

  @override
  void initState() {
    super.initState();
    // Initial setup if needed
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstTime) {
      final int? argument = ModalRoute.of(context)?.settings.arguments as int?;
      if (argument != null) {
        _currentIndex = argument;
      }
      _isFirstTime = false;
    }

    return Scaffold(
      body: _children[_currentIndex], // Display the correct page
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.dashboard, color: Colors.blue),
            icon: Icon(Icons.dashboard, color: Colors.blueGrey),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.directions_car, color: Colors.blue),
            icon: Icon(Icons.list_alt, color: Colors.blueGrey),
            label: 'Work Logs',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.picture_as_pdf, color: Colors.blue),
            icon: Icon(Icons.picture_as_pdf, color: Colors.blueGrey),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.settings, color: Colors.blue),
            icon: Icon(Icons.settings, color: Colors.blueGrey),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Reports'));
  }
}

class Page4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Settings'));
  }
}
