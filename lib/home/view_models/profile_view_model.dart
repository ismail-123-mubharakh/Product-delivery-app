import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:untitled/home/view_models/product_view_model.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  ProductViewModel? cachedViewModel;
  File? profileImage;
  bool isLoading = false;

  void loadUserData() {
      usernameController.text = 'CurrentUsername';

  }
  Future<void> pickImage(BuildContext context,ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
        profileImage = File(pickedFile.path); // Your image picking logic
        cachedViewModel?.setProfileImage(profileImage!);
        notifyListeners();
    }
    notifyListeners();
  }

  Future<void> updateProfile(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;

    try {
      // Replace with your actual profile update logic
      await Future.delayed(Duration(seconds: 2)); // Simulate network request

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      isLoading = false;
    }
  }

}