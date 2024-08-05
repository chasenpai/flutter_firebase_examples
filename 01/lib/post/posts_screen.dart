import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:test01/post/post.dart';
import 'package:test01/post/post_search_screen.dart';
import 'package:test01/post/posts_write_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final TextEditingController _searchController = TextEditingController();
  List<PostSummery> posts = [];

  @override
  void initState() {
    super.initState();
    _databaseReference.child('postSummaries').onValue.listen((event) {
      final snapshot = event.snapshot;
      if(snapshot.exists) {
        posts.clear();
        final Map<dynamic, dynamic> postsData = snapshot.value as Map<dynamic, dynamic>;
        postsData.forEach((key, value) {
          PostSummery post = PostSummery.fromJson(key, value);
          posts.add(post);
        });
        posts.sort((a, b) => b.createAt!.compareTo(a.createAt!));
      }
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchByName(String name) async {
    if(name.isNotEmpty) {
      List<PostSummery> searchedPost = [];
      final userSnapshot = await _databaseReference.child('userPosts/$name').once();
      if(userSnapshot.snapshot.exists) {
        final Map<dynamic, dynamic> userData = userSnapshot.snapshot.value as Map<dynamic, dynamic>;
        List<Future<void>> tasks = userData.entries.map((entry) async {
          final postSnapshot = await _databaseReference.child('postSummaries/${entry.key}').once();
          if (postSnapshot.snapshot.exists) {
            final Map<dynamic, dynamic> postData = postSnapshot.snapshot.value as Map<dynamic, dynamic>;
            searchedPost.add(PostSummery.fromJson(entry.key, postData));
          }
        }).toList();
        await Future.wait(tasks);
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) {
          return PostSearchScreen(
            name: name,
            posts: searchedPost,
          );
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '익명 게시판',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: 12.0,
                  left: 12.0,
                  bottom: 6.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '작성자 검색',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await _searchByName(_searchController.text);
                        _searchController.clear();
                      },
                      icon: const Icon(
                        Icons.search,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: posts.length,
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 0,
                      thickness: 1.25,
                      color: Colors.grey[200],
                    );
                  },
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) {
                            return PostWriteScreen(postId: post.id,);
                          }),
                        );
                      },
                      child: ListTile(
                        title: Text(
                          post.title,
                        ),
                        subtitle: Text(
                          '${post.nickname} · ${post.createAt} · ${post.hits}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) {
              return const PostWriteScreen();
            }),
          );
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}

