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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: TabBar(
            tabs: [
              Tab(text: 'Cars Overview'),
              Tab(text: 'Quick Actions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildCarsOverview(context),
            buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget buildCarsOverview(BuildContext context) {
    return StreamBuilder<List<Car>>(
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
            return car.model.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          hintText: 'Search Cars',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
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
                Text(
                  'Total Cars: ${snapshot.data!.length}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // add text
                    OverviewBar(
                      title: 'Unavailable Cars',
                      value: snapshot.data!.length - availableCars,
                      total: snapshot.data!.length,
                      color: Colors.orange,
                    ),
                    OverviewBar(
                      title: 'Available Cars',
                      value: availableCars,
                      total: snapshot.data!.length,
                      color: Colors.green,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredCars.length,
                    itemBuilder: (context, index) {
                      var car = filteredCars[index];
                      return Card(
                        // add border color based on condition status
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: car.conditionStatus == 'green'
                                    ? Colors.green
                                    : car.conditionStatus == 'yellow'
                                        ? Colors.yellow
                                        : Colors.red,
                                width: 5.0,
                              ),
                            ),
                          ),
                          child: ListTile(
                            leading: Image.network(car.picture,
                                width: 80, height: 100, fit: BoxFit.cover),
                            title: Text('${car.model} (${car.year})'),
                            subtitle: Text(
                                'Availability: ${car.availabilityStatus}\nCondition: ${car.conditionStatus == 'green' ? 'Good to go' : car.conditionStatus == 'yellow' ? 'Needs Washing' : 'Broken'}'),
                            trailing: null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CarDetailsPage(car: car),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
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
              Navigator.pushNamed(context, Routes.manageCustomers);
            },
          ),
          QuickActionCard(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () {
              // Add your settings route or logic here
            },
          ),
          QuickActionCard(
            icon: Icons.help,
            label: 'Help',
            onTap: () {
              // Add your help route or logic here
            },
          ),
        ],
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

class OverviewBar extends StatelessWidget {
  final String title;
  final int value;
  final int total;
  final Color color;

  OverviewBar({
    required this.title,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    double progress = value / total;

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        padding: EdgeInsets.all(10.0),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.black, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            SizedBox(height: 5),
            Text(
              '$value / $total',
              style: TextStyle(
                  color: Colors.black,
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
              Icon(icon, size: 40, color: Colors.blueGrey),
              SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
