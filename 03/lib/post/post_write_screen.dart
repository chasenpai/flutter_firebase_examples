import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test04/post/post.dart';

class PostWriteScreen extends StatefulWidget {
  final String? postId;

  const PostWriteScreen({
    this.postId,
    super.key,
  });

  @override
  State<PostWriteScreen> createState() => _PostWriteScreenState();
}

class _PostWriteScreenState extends State<PostWriteScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final CollectionReference _postsCollection = FirebaseFirestore.instance.collection('post');

  @override
  void initState() {
    super.initState();
    if(widget.postId != null) {
      _readPost();
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _passwordController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _readPost() async {
    final postRef = _postsCollection.doc(widget.postId!);
    await postRef.get()
      .then(
          (DocumentSnapshot doc) {
        final post = doc.data() as Map<String, dynamic>;
        _nicknameController.text = post['nickname'];
        _passwordController.text = post['password'];
        _titleController.text = post['title'];
        _contentController.text = post['content'];
      },
      onError: (e) {
        print('read post failed: $e');
      },
    );
  }

  Future<void> _savePost() async {
    Post post = Post(
      nickname: _nicknameController.text,
      password: _passwordController.text,
      title: _titleController.text,
      content: _contentController.text,
      createAt: DateTime.now(),
    );
    await _postsCollection.add(post.toJson()).then(
      (value) {
        print('save success: ${value.id}');
      },
      onError: (e) {
        print('save failed: $e');
      },
    );
    Navigator.of(context).pop();
  }

  Future<void> _updatePost() async {
    Post post = Post(
      nickname: _nicknameController.text,
      password: _passwordController.text,
      title: _titleController.text,
      content: _contentController.text,
      createAt: DateTime.now(),
    );
    final postRef = _postsCollection.doc(widget.postId!);
    await postRef.update(post.toJson()).then(
      (value) {
        print('update success');
      },
      onError: (e) {
        print('update failed: $e');
      },
    );
    Navigator.of(context).pop();
  }

  Future<void> _deletePost() async {
    await _postsCollection.doc(widget.postId!).delete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.postId != null ? '글수정' : '글쓰기',
        ),
        centerTitle: true,
        actions: [
          if(widget.postId != null )
            IconButton(
              onPressed: () {
                _deletePost();
              },
              icon: const Icon(
                Icons.clear,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nicknameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '닉네임',
                        ),
                      ),
                    ),
                    const SizedBox(width: 6.0,),
                    Expanded(
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '비밀번호',
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1.25,
                  color: Colors.grey[200],
                ),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '제목',
                  ),
                ),
                Divider(
                  thickness: 1.25,
                  color: Colors.grey[200],
                ),
                TextField(
                  controller: _contentController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '내용',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(widget.postId != null) {
            _updatePost();
          }else {
            _savePost();
          }
        },
        child: const Icon(
          Icons.check,
        ),
      ),
    );
  }
}
