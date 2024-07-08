import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/auth_models/login_model.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';
import 'auth_pages/login_page.dart';
import 'car_details_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final CarService carService = CarService();
  final loginModel = LoginModel();
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              loginModel.signOut();
              await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => LoginPage()));
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
            var filteredCars = snapshot.data!.where((car) {
              return car.model
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
            }).toList();

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
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(Icons.circle,
                                    color: Colors.green, size: 15),
                              ),
                              TextSpan(
                                text: ' Green: Good Condition\n',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              WidgetSpan(
                                child: Icon(Icons.circle,
                                    color: Colors.yellow, size: 15),
                              ),
                              TextSpan(
                                text: ' Yellow: Needs Washing\n',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              WidgetSpan(
                                child: Icon(Icons.circle,
                                    color: Colors.red, size: 15),
                              ),
                              TextSpan(
                                text: ' Red: broken',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              // decrease the width of the search bar
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                              hintText: 'Search Cars',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            // onsubmit or enter change state
                            onEditingComplete: () {
                              setState(() {
                                searchQuery = searchController.text;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.grey, width: 1),
                          right: BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      margin: EdgeInsets.only(right: 20),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: filteredCars.length,
                          itemBuilder: (context, index) {
                            var car = filteredCars[index];
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
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 5,
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
          padding: EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blueGrey),
              SizedBox(height: 5),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
