import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final _firestore = FirebaseFirestore.instance;

  Future<void> save() async {
    final user = {
      'name': {
        'first': 'gildong',
        'last': 'hong',
      },
      'age': 25,
      'address': {
        'country': 'korea',
        'city': 'seoul',
      },
      'hobbies' : ['game', 'coding', 'workout'],
      'followers': 10,
    };
    await _firestore.collection('users')
      .doc('honggildong')
      .set(user);
  }

  Future<void> update() async {
    final honggildongRef = _firestore.collection('users').doc('honggildong');
    await honggildongRef.update(
      {
        'age': 27,
        'address.city': 'busan',
        'hobbies': FieldValue.arrayUnion(['art']),
        //'hobbies': FieldValue.arrayRemove(['art']),
        'followers': FieldValue.increment(1),
      },
    );
  }

  Future<void> docDelete() async {
    await _firestore.collection('users').doc('honggildong').delete();
  }

  Future<void> fieldDelete() async {
    final honggildongRef = _firestore.collection('users').doc('honggildong');
    await honggildongRef.update(
      {
        'age': FieldValue.delete(),
      },
    );
  }

  Future<void> read() async {
    final honggildongRef = _firestore.collection('users').doc('honggildong');
    honggildongRef.get()
    .then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        print(data);
      },
      onError: (e) {
        print(e);
      }
    );
  }

  //충돌 감지 시 트랜잭션 자동 재시도
  //읽기는 무조건 쓰기 전에
  //트랜잭션 내에서 앱 상태를 직접 수정하면 안됨
  Future<void> increaseFollowers() async {
    final honggildongRef = _firestore.collection('users').doc('honggildong');
    await _firestore.runTransaction((transaction) async {
      final DocumentSnapshot snapshot  = await transaction.get(honggildongRef);
      final newFollowers = snapshot.get('followers') + 1;
      transaction.update(honggildongRef, {'followers': newFollowers},);
      await Future.delayed(const Duration(seconds: 2),);
    }).then(
      (value) {
        print('success');
      },
      onError: (e) {
        print('failed $e');
      },
    );
  }

  Future<void> batch() async {
    final WriteBatch batch = _firestore.batch();
    var parkRef = _firestore.collection('users').doc('park');
    batch.set(
      parkRef,
      {
        'name': {
          'first': 'gildong',
          'last': 'hong',
        },
      },
    );
    var honggildongRef = _firestore.collection('users').doc('honggildong');
    batch.update(honggildongRef, {'age': 30,},);
    var kimRef = _firestore.collection('users').doc('kim');
    batch.delete(kimRef);
    batch.commit().then(
      (value) {
        print('batch success');
      },
      onError: (e) {
        print('batch failed $e');
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    save();
                  },
                  child: Text(
                    'save',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    read();
                  },
                  child: Text(
                    'read',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    update();
                  },
                  child: Text(
                    'update',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    docDelete();
                  },
                  child: Text(
                    'doc delete',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    fieldDelete();
                  },
                  child: Text(
                    'field delete',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    increaseFollowers();
                  },
                  child: Text(
                    'transaction',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    batch();
                  },
                  child: Text(
                    'batch',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
