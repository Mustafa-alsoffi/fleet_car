import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class LoginModel extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;

  void login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        _isLoading = false;
        _successMessage = 'Logged in successfully';
      }
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _isLoading = false;
        _errorMessage = 'No user found for that email';
        notifyListeners();
      } else if (e.code == 'wrong-password') {
        _isLoading = false;
        _errorMessage = 'Wrong password provided for that user';
        notifyListeners();
      } else if (e.code == 'invalid-email') {
        _isLoading = false;
        _errorMessage = 'Invalid email provided';
        notifyListeners();
      } else {
        _isLoading = false;
        _errorMessage = 'An error occurred';
        notifyListeners();
      }
    }
  }
}
