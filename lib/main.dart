import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fleet_car/pages/auth_pages/login_page.dart';
import 'package:fleet_car/pages/auth_pages/signup_page.dart';
import 'package:fleet_car/pages/dashboard.dart';
import 'package:fleet_car/pages/home.dart';
import 'package:fleet_car/pages/manage_car/add_edit_car_page.dart';
import 'package:fleet_car/pages/manage_car/manage_cars_page.dart';
import 'package:fleet_car/pages/manage_customers/add_edit_customer_page.dart';
import 'package:fleet_car/pages/manage_customers/manage_customers_page.dart';
import 'package:fleet_car/pages/manage_worklogs/manage_work_logs_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'firebase_options.dart';
import 'models/auth_models/login_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // initialize the Firebase app

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FleetCare',
        routes: {
          Routes.register: (context) => SignUpPage(),
          Routes.login: (context) => LoginPage(),
          Routes.dashboard: (context) => DashboardPage(),
          Routes.manageCars: (context) => ManageCarPage(),
          Routes.addEditCar: (context) => AddEditCarPage(),
          Routes.manageCustomers: (context) => ManageCustomersPage(),
          Routes.addEditCustomer: (context) => AddEditCustomerPage(),
          Routes.manageWorkLogs: (context) => ManageWorkLogsPage(),
        },
        theme: ThemeData(
          useMaterial3: true,

          // Define the default brightness and colors.
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            surfaceTint: Colors.white,
            brightness: Brightness.light,
          ),

          // Define the default `TextTheme`. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: TextTheme(
            displayLarge: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
            // ···
            titleLarge: GoogleFonts.oswald(
              fontSize: 30,
              fontStyle: FontStyle.italic,
            ),
            bodyMedium: GoogleFonts.roboto(),
            displaySmall: GoogleFonts.robotoMono(),
          ),
        ),
        home: AuthCheck(),
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return Homepage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
