import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/car_service.dart';

class DashboardPage extends StatelessWidget {
  final CarService carService = CarService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        // remove back button
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: carService.getCarsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No cars found'));
            } else {
              var availableCars = snapshot.data!
                  .where((car) => car['availabilityStatus'] == 'available')
                  .toList()
                  .length;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Cards
                      // add loading status until data is fetched

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          OverviewCard(
                            title: 'Total Cars',
                            value: '${snapshot.data!.length}',
                            color: Colors.blue,
                          ),
                          OverviewCard(
                            title: 'Unavailable Cars',
                            value: '${snapshot.data!.length - availableCars}',
                            color: Colors.orange,
                          ),
                          OverviewCard(
                            title: 'Available Cars',
                            value: '$availableCars',
                            color: Colors.green,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Recent Activities Section
                      Text(
                        'Recent Activities',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!
                            .length, // Replace with your dynamic list count
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                                'Car model: ${snapshot.data![index]['model']}'),
                            subtitle: Text(
                                'Availability Status: ${snapshot.data![index]['availabilityStatus']}'),
                            trailing: Icon(Icons.circle),
                            // add icon color based on condition status for 3 colors green yellow and red
                            iconColor: snapshot.data![index]
                                        ['conditionStatus'] ==
                                    'green'
                                ? Colors.green
                                : snapshot.data![index]['conditionStatus'] ==
                                        'yellow'
                                    ? Colors.yellow
                                    : Colors.red,

                            onTap: () {
                              // Navigate to the detailed view
                            },
                          );
                        },
                      ),
                      SizedBox(height: 20),

                      // Quick Actions Section
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: [
                          QuickActionCard(
                            icon: Icons.list_alt,
                            label: 'View Work Logs',
                            onTap: () {
                              // Navigate to Work Logs Page
                            },
                          ),
                          QuickActionCard(
                            icon: Icons.directions_car,
                            label: 'Manage Cars',
                            onTap: () {
                              // Navigate to Manage Cars Page
                              Navigator.pushNamed(context, Routes.manageCars);
                            },
                          ),
                          QuickActionCard(
                            icon: Icons.people,
                            label: 'Manage Customers',
                            onTap: () {
                              Navigator.pushNamed(
                                  context, Routes.manageCustomers);
                            },
                          ),
                          QuickActionCard(
                            icon: Icons.picture_as_pdf,
                            label: 'Generate Reports',
                            onTap: () {
                              // Navigate to Generate Reports Page
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
          }),
    );
  }
}

class OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  OverviewCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Container(
        width: 110,
        height: 150,
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  QuickActionCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
