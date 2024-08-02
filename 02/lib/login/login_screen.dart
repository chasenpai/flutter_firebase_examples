import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _joinEmailController = TextEditingController();
  final _joinPasswordController = TextEditingController();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordUpdateEmailController = TextEditingController();
  final _passwordUpdatePasswordController = TextEditingController();
  final _passwordUpdateNewPasswordController = TextEditingController();
  final _passwordResetEmailController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _firebaseAuth.authStateChanges().listen((User? user) {
      if(user != null) {
        print('user: $user');
      }else {
        print('user x');
      }
    });
  }

  @override
  void dispose() {
    _joinEmailController.dispose();
    _joinPasswordController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _displayNameController.dispose();
    _passwordUpdateEmailController.dispose();
    _passwordUpdatePasswordController.dispose();
    _passwordUpdateNewPasswordController.dispose();
    _passwordResetEmailController.dispose();
    super.dispose();
  }

  Future<void> emailJoin() async {
    final UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: _joinEmailController.text,
      password: _joinPasswordController.text,
    );
    print('join credential: $credential');
  }

  Future<void> emailLogin() async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: _loginEmailController.text,
      password: _loginPasswordController.text,
    );
    print('login credential: $credential');
  }

  Future<void> updateDisplayName() async {
    if(_firebaseAuth.currentUser != null) {
      await _firebaseAuth.currentUser!.updateDisplayName(_displayNameController.text);
    }
  }

  Future<void> updatePassword() async {
    if(_firebaseAuth.currentUser != null) {
      try {
        await _firebaseAuth.currentUser!.updatePassword(_passwordUpdateNewPasswordController.text);
      }catch (e) {
        final AuthCredential credential = EmailAuthProvider.credential(
          email: _passwordUpdateEmailController.text,
          password: _passwordUpdatePasswordController.text,
        );
        await _firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
        await _firebaseAuth.currentUser!.updatePassword(_passwordUpdateNewPasswordController.text);
      }

    }
  }

  Future<void> sendPasswordResetEmail() async {
    await _firebaseAuth.sendPasswordResetEmail(email: _passwordResetEmailController.text,);
  }

  Future<void> googleLogin() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final OAuthCredential googleCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    print('google credential: $googleCredential');
    final credential = await _firebaseAuth.signInWithCredential(googleCredential);
    print('login credential: $credential');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _joinEmailController,
                  decoration: InputDecoration(
                    hintText: '회원가입 이메일',
                    border: InputBorder.none,
                  ),
                ),
                TextField(
                  controller: _joinPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '회원가입 비밀번호',
                    border: InputBorder.none,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    emailJoin();
                  },
                  child: Text('이메일로 가입',),
                ),
                TextField(
                  controller: _loginEmailController,
                  decoration: InputDecoration(
                    hintText: '로그인 이메일',
                    border: InputBorder.none,
                  ),
                ),
                TextField(
                  controller: _loginPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '로그인 비밀번호',
                    border: InputBorder.none,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    emailLogin();
                  },
                  child: Text('이메일로 로그인',),
                ),
                TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    hintText: '이름',
                    border: InputBorder.none,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    updateDisplayName();
                  },
                  child: Text('이름 변경',),
                ),
                TextField(
                  controller: _passwordUpdateEmailController,
                  decoration: InputDecoration(
                    hintText: '이메일',
                    border: InputBorder.none,
                  ),
                ),
                TextField(
                  controller: _passwordUpdatePasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '현재 비밀번호',
                    border: InputBorder.none,
                  ),
                ),
                TextField(
                  controller: _passwordUpdateNewPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '변경할 비밀번호',
                    border: InputBorder.none,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    updatePassword();
                  },
                  child: Text('비밀번호 변경',),
                ),
                TextField(
                  controller: _passwordResetEmailController,
                  decoration: InputDecoration(
                    hintText: '전송 이메일',
                    border: InputBorder.none,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    sendPasswordResetEmail();
                  },
                  child: Text('비밀번호 재설정 이메일 전송',),
                ),
                ElevatedButton(
                  onPressed: () {
                    googleLogin();
                  },
                  child: Text('구글 로그인', ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
