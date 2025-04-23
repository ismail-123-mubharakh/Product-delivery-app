import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/home/view_models/product_view_model.dart';
import 'package:provider/provider.dart';
import 'package:untitled/home/view_models/profile_view_model.dart';
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.read<ProfileViewModel>().cachedViewModel = context.read<ProductViewModel>();
  }
  @override
  void initState() {
    super.initState();
    // Load initial user data
    context.read<ProfileViewModel>().loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed:(){context.read<ProfileViewModel>().updateProfile(context);
            Navigator.pop(context);
    },
          ),
        ],
      ),
      body: context.read<ProfileViewModel>().isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: context.read<ProfileViewModel>().formKey,
          child: Column(
            children: [
              _buildProfilePicture(),
              SizedBox(height: 24),
              _buildUsernameField(),
              SizedBox(height: 16),
              _buildPasswordFields(),
              SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: context.watch<ProductViewModel>().profileImage != null
              ? FileImage(context.watch<ProductViewModel>().profileImage!)
              : NetworkImage('https://i.imgur.com/BoN9kdC.png') as ImageProvider,
          child: context.watch<ProductViewModel>().profileImage == null
              ? Icon(Icons.person, size: 60)
              : null,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.white),
            onPressed: ()
            {_showImageSourceDialog();}
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: context.read<ProfileViewModel>().usernameController,
      decoration: InputDecoration(
        labelText: 'Username',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a username';
        }
        if (value.length < 4) {
          return 'Username must be at least 4 characters';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        TextFormField(
          controller: context.read<ProfileViewModel>().currentPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Current Password',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: context.read<ProfileViewModel>().newPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'New Password (optional)',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed:(){
        context.read<ProfileViewModel>().updateProfile(context);
        Navigator.pop(context);
      } ,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      ),
      child: Text('SAVE CHANGES'),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source'),
        actions: [
          TextButton(
            child: Text('Camera'),
            onPressed: () async {
              Navigator.pop(context);
              context.read<ProfileViewModel>().pickImage( context ,ImageSource.camera);

            },
          ),
          TextButton(
            child: Text('Gallery'),
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileViewModel>().pickImage( context ,ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }


}