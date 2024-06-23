import 'package:flutter/material.dart';
import 'authform.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To Do List App'),
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.lightBlue[200],
      ),
      backgroundColor: Colors.lightBlue[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Image.asset(
                    'lib/assets/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Expanded(
                flex: 3,
                child: AuthForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
