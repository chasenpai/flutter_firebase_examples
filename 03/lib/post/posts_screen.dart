import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test04/post/post.dart';
import 'package:test04/post/post_write_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final CollectionReference _postsCollection = FirebaseFirestore.instance.collection('post');
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _readPosts() {
    return _postsCollection.orderBy('createAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> _searchPosts(String query) {
    return _postsCollection
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots();
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
                          hintText: '제목 검색',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {

                        });
                      },
                      icon: const Icon(
                        Icons.search,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _searchController.text.isEmpty ? _readPosts() : _searchPosts(_searchController.text),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if(snapshot.hasError) {
                      return const Center(child: Text('error...',),);
                    }
                    if(snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(),);
                    }
                    final List<DocumentSnapshot> docs = snapshot.data!.docs;
                    if(docs.isEmpty) {
                      return const Center(child: Text('no data...',),);
                    }
                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 0,
                          thickness: 1.25,
                          color: Colors.grey[200],
                        );
                      },
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final post = Post.fromJson(doc.id, doc.data() as Map<String, dynamic>);
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
                              '${post.nickname} · ${post.createAt} · ${post.hits}'
                          ),
                        ),
                        );
                      },
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
