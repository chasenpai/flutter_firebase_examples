import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:test01/post/post.dart';

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
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    _passwordController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if(widget.postId != null) {
      _readPost();
    }
  }

  Future<void> _readPost() async {
    final data = await _databaseRef.child('posts/${widget.postId}').once();
    if(data.snapshot.exists) {
      final post = data.snapshot.value as Map<dynamic, dynamic>;
      _nicknameController.text = post['nickname'];
      _passwordController.text = post['password'];
      _titleController.text = post['title'];
      _contentController.text = post['content'];
    }
  }

  Future<void> _savePost() async {
    final DatabaseReference postRef = _databaseRef.child('posts').push();
    final String postId = postRef.key!;
    Post post = Post(
      nickname: _nicknameController.text,
      password: _passwordController.text,
      title: _titleController.text,
      content: _contentController.text,
      createAt: DateTime.now(),
    );
    PostSummery postSummery = PostSummery(
      nickname: post.nickname,
      title: post.title,
      createAt: post.createAt,
    );
    await postRef.set(post.toJson());
    await _databaseRef.child('postSummaries/$postId').set(postSummery.toJson());
    await _databaseRef.child('userPosts/${_nicknameController.text}/$postId').set(true);
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
    PostSummery postSummery = PostSummery(
      nickname: post.nickname,
      title: post.title,
      createAt: post.createAt,
    );
    await _databaseRef.child('posts/${widget.postId}').update(post.toJson());
    await _databaseRef.child('postSummaries/${widget.postId}').update(postSummery.toJson());
    Navigator.of(context).pop();
  }

  Future<void> _deletePost() async {
    await _databaseRef.child('posts/${widget.postId}').remove();
    await _databaseRef.child('postSummaries/${widget.postId}').remove();
    await _databaseRef.child('userPosts/${_nicknameController.text}/${widget.postId}').remove();
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
