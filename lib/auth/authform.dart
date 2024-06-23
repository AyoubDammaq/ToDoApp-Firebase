import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todoappfirebase/screens/HomeScreen.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _email = '';
  var _password = '';
  var _username = '';
  bool _isLoginPage = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    }
  }

  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      if (_isLoginPage) {
        _signInWithEmailAndPassword(_email, _password);
      } else {
        _signUpWithEmailAndPassword(_email, _password, _username);
      }
    }
  }

  Future<void> _signInWithEmailAndPassword(String email, String password) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error signing in: $error');
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      final authResult = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final uid = authResult.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username,
        'email': email,
      });
      // Redirect to home page after successful sign-up
    } catch (error) {
      print('Error signing up: $error');
      setState(() {
        _errorMessage = error.toString(); // Save error message
      });
      // Show error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                key: const ValueKey('email'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Incorrect Email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value ?? '';
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(),
                  ),
                  labelText: 'Enter Email',
                  labelStyle: GoogleFonts.roboto(),
                ),
              ),
              const SizedBox(height: 10),
              if (!_isLoginPage)
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  key: const ValueKey('username'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Incorrect Username';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _username = value ?? '';
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(),
                    ),
                    labelText: 'Enter Username',
                    labelStyle: GoogleFonts.roboto(),
                  ),
                ),
              const SizedBox(height: 10),
              TextFormField(
                obscureText: true,
                keyboardType: TextInputType.emailAddress,
                key: const ValueKey('password'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Incorrect Password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value ?? '';
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(),
                  ),
                  labelText: 'Enter Password',
                  labelStyle: GoogleFonts.roboto(),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(5),
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                    _isLoginPage ? 'Login' : 'Sign Up',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginPage = !_isLoginPage;
                  });
                },
                child: _isLoginPage
                    ? const Text('Not a Member?')
                    : const Text('Already a Member?'),
              ),
              if (_errorMessage != null) // Display error message if it exists
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
