import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/auth_models/login_model.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';
import 'car_details_page.dart';

class DashboardPage extends StatelessWidget {
  final CarService carService = CarService();
  final loginModel = LoginModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        automaticallyImplyLeading: false,
        // add a logout button
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // logout from firebase auth
              loginModel.signOut();
              // navigate to login page without causing Navigator Locking
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Car>>(
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
                .where((car) => car.availabilityStatus == 'available')
                .toList()
                .length;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Records',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        // add a richtext widget that contains 3 colors with explaination
                      ],
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                            child: Icon(Icons.circle,
                                color: Colors.green, size: 15),
                          ),
                          TextSpan(
                            text: ' Green: Good Condition\n',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          WidgetSpan(
                            child: Icon(Icons.circle,
                                color: Colors.yellow, size: 15),
                          ),
                          TextSpan(
                            text: ' Yellow: Needs Washing\n',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          WidgetSpan(
                            child:
                                Icon(Icons.circle, color: Colors.red, size: 15),
                          ),
                          TextSpan(
                            text: ' Red: broken',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      // 20% of screen height
                      height: MediaQuery.of(context).size.height * 0.4,
                      // add a left and right border
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.grey, width: 1),
                          right: BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      // add 5 to the right margin
                      margin: EdgeInsets.only(right: 20),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var car = snapshot.data![index];
                            return ListTile(
                              title: Text('Car model: ${car.model}'),
                              subtitle: Text(
                                  'Availability Status: ${car.availabilityStatus}'),
                              trailing: Icon(Icons.circle),
                              iconColor: car.conditionStatus == 'green'
                                  ? Colors.green
                                  : car.conditionStatus == 'yellow'
                                      ? Colors.yellow
                                      : Colors.red,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CarDetailsPage(car: car),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Quick Actions',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        QuickActionCard(
                          icon: Icons.directions_car,
                          label: 'Manage Cars',
                          onTap: () {
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
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
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
    return Expanded(
      child: Card(
        color: color,
        child: Container(
          height: 100,
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
              Icon(icon, size: 40, color: Colors.blueGrey),
              SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
