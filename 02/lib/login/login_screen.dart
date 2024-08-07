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
  final _phoneNumberController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? _verificationId;

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
    _phoneNumberController.dispose();
    _smsCodeController.dispose();
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
      }on FirebaseAuthException catch (e) {
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

  Future<void> anonymousLogin() async {
    final credential = await _firebaseAuth.signInAnonymously();
    print('anonymous credential: $credential');
  }

  Future<void> anonymousUserJoin() async {
    final emailCredential = EmailAuthProvider.credential(
      email: _joinEmailController.text,
      password: _joinPasswordController.text,
    );
    try{
      final credential = await _firebaseAuth.currentUser?.linkWithCredential(emailCredential);
      print('anonymous join credential: $credential');
    } on FirebaseAuthException catch(e) {
      print('anonymous user join failed: ${e.code}');
    }
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
  
  Future<void> phoneLogin() async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: _phoneNumberController.text,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential phoneCredential) async { //Android only
        print('android phone credential: $phoneCredential');
        await _firebaseAuth.signInWithCredential(phoneCredential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('phone verification failed: ${e.code}');
      },
      codeSent: (String verificationId, int? resendToken) {
        print('phone verificationId: $verificationId');
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('timeout :$verificationId');
      },
    );
  }

  Future<void> smsCodeVerify() async {
    if(_verificationId != null) {
      final PhoneAuthCredential phoneCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _smsCodeController.text,
      );
      final credential = await _firebaseAuth.signInWithCredential(phoneCredential);
      print('login credential: $credential');
    }
  }

  Future<void> logout() async {
    if(_firebaseAuth.currentUser != null) {
      if(!_firebaseAuth.currentUser!.isAnonymous) {
        final UserInfo userInfo = _firebaseAuth.currentUser!.providerData[0];
        if(userInfo.providerId == 'google.com') {
          await GoogleSignIn().signOut();
        }
      }
      await _firebaseAuth.signOut();
    }
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
                    anonymousLogin();
                  },
                  child: Text('익명 로그인',),
                ),
                ElevatedButton(
                  onPressed: () {
                    anonymousUserJoin();
                  },
                  child: Text('익명 사용자 회원가입',),
                ),
                ElevatedButton(
                  onPressed: () {
                    googleLogin();
                  },
                  child: Text('구글 로그인',),
                ),
                TextField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    hintText: '전화번호',
                    border: InputBorder.none,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    phoneLogin();
                  },
                  child: Text('전화번호 인증',),
                ),
                TextField(
                  controller: _smsCodeController,
                  decoration: InputDecoration(
                    hintText: '인증 코드',
                    border: InputBorder.none,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    smsCodeVerify();
                  },
                  child: Text('인증 코드 확인',),
                ),
                ElevatedButton(
                  onPressed: () {
                    logout();
                  },
                  child: Text('로그아웃',),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
