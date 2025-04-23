import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../home/screens/home_screen.dart';

class LoginViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorMessage;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;
  Future<void> login(BuildContext context) async {
    if (formKey.currentState!.validate()) {
        isLoading = true;
        errorMessage = null;
        notifyListeners();
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Check for specific password
      if (passwordController.text == "Pass@123") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
          errorMessage = "Incorrect password. Please try again.";
          isLoading = false;
      }
    }
  }

  setPasswordVisibility(){
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }
}