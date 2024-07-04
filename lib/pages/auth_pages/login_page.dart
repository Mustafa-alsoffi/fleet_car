import 'package:fleet_car/pages/auth_pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/auth_models/login_model.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fleet Car'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String email = _emailController.text;
                String password = _passwordController.text;
                context.read<LoginModel>().login(email, password);
              },
              child: Text('Login'),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text('Don\'t have an account? Sign Up'),
            ),
            Consumer<LoginModel>(
              builder: (context, loginModel, child) {
                if (loginModel.isLoading) {
                  return CircularProgressIndicator();
                }
                if (loginModel.errorMessage.isNotEmpty) {
                  return Text(
                    loginModel.errorMessage,
                    style: TextStyle(color: Colors.red),
                  );
                } else if (loginModel.successMessage.isNotEmpty) {
                  Navigator.pushNamed(context, '/dashboard');
                  return Text(
                    loginModel.successMessage,
                    style: TextStyle(color: Colors.green),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
