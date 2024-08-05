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
  final DatabaseReference _postsRef = FirebaseDatabase.instance.ref('posts');
  final DatabaseReference _postSummariesRef = FirebaseDatabase.instance.ref('postSummaries');
  final DatabaseReference _userPostsRef = FirebaseDatabase.instance.ref('userPosts');
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
    final postChildRef = _postsRef.child('${widget.postId}');
    await postChildRef.update(
      {
        'hits': ServerValue.increment(1),
      },
    );
    final postSummariesChildRef = _postSummariesRef.child('${widget.postId}');
    await postSummariesChildRef.runTransaction((postSummary) {
      if(postSummary == null) {
        return Transaction.abort();
      }
      final Map<dynamic, dynamic> postSummariesData = postSummary as Map<dynamic, dynamic>;
      postSummariesData['hits'] = postSummariesData['hits'] + 1;
      return Transaction.success(postSummariesData);
    });

    final data = await _postsRef.child('${widget.postId}').once();
    if(data.snapshot.exists) {
      final post = data.snapshot.value as Map<dynamic, dynamic>;
      _nicknameController.text = post['nickname'];
      _passwordController.text = post['password'];
      _titleController.text = post['title'];
      _contentController.text = post['content'];
    }
  }

  Future<void> _savePost() async {
    final DatabaseReference postRef = _postsRef.push();
    final String postId = postRef.key!;
    Post post = Post(
      nickname: _nicknameController.text,
      password: _passwordController.text,
      title: _titleController.text,
      content: _contentController.text,
      createAt: DateTime.now(),
      hits: 0,
    );
    PostSummery postSummery = PostSummery(
      nickname: post.nickname,
      title: post.title,
      createAt: post.createAt!,
      hits: 0,
    );
    await postRef.set(post.toJson());
    await _postSummariesRef.child(postId).set(postSummery.toJson());
    await _userPostsRef.child('${_nicknameController.text}/$postId').set(true);
    Navigator.of(context).pop();
  }

  Future<void> _updatePost() async {
    Post post = Post(
      nickname: _nicknameController.text,
      password: _passwordController.text,
      title: _titleController.text,
      content: _contentController.text,
    );
    PostSummery postSummery = PostSummery(
      nickname: post.nickname,
      title: post.title,
    );
    await _postsRef.child('${widget.postId}').update(post.toJson());
    await _postSummariesRef.child('${widget.postId}').update(postSummery.toJson());
    Navigator.of(context).pop();
  }

  Future<void> _deletePost() async {
    await _postsRef.child('${widget.postId}').remove();
    await _postSummariesRef.child('${widget.postId}').remove();
    await _userPostsRef.child('${_nicknameController.text}/${widget.postId}').remove();
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
