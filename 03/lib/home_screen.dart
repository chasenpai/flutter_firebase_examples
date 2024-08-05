import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
