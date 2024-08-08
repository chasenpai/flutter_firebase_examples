import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:test05/chat/chats_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseAuth = FirebaseAuth.instance;
  final _usersRef = FirebaseDatabase.instance.ref('users');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
    final uid = credential.user!.uid;
    final data = await _usersRef.child(uid).once();
    if(data.snapshot.exists) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatsScreen(userId: data.snapshot.key!,),),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: Center(
                  child: Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '이메일',
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '비밀번호',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  login();
                },
                child: const Text(
                  '로그인',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
