import 'package:flutter/material.dart';
import 'package:library_management_frontend/services/auth_service.dart';
import 'book_list_screen.dart';
import 'registration_screen.dart'; 
import 'package:library_management_frontend/models/user.dart'; 

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

// Check if a user is already logged in
  void _checkLoginStatus() async {
    bool isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      // Retrieve stored user data and navigate to the BookListScreen
      User user = await _authService.getUserData(); // Get user data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BookListScreen(user: user)),
      );
    }
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      if (username.isEmpty || password.isEmpty) {
        _showErrorMessage('Please enter both username and password');
        return;
      }

      try {
        final user = await _authService.login(
          _usernameController.text,
          _passwordController.text,
        );
        _showSuccessMessage('Login successful');

         // Save the logged-in user data
        await _authService.saveUserData(user);
        
        // Pass the user object to BookListScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookListScreen(user: user), // Passing the user object
          ),
        );
      } catch (e) {
        _showErrorMessage('Login failed: ${e.toString()}');
      }
    } else {
      _showErrorMessage('Please correct the errors in the form');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              TextButton(
                onPressed: () {
                    Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationScreen()),
                    );
                },
                child: Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
    ));
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }
}
