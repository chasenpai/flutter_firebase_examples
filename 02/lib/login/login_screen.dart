import 'package:flutter/material.dart';
import 'package:test03/login/email_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EmailLoginScreen(),
                    ),
                  );
                },
                child: Text('이메일 로그인', ),
              ),
              ElevatedButton(
                onPressed: () {

                },
                child: Text('구글 로그인', ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
