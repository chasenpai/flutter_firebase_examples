import 'package:flutter/material.dart';
import 'package:test01/post/post.dart';
import 'package:test01/post/posts_write_screen.dart';

class PostSearchScreen extends StatelessWidget {
  final String name;
  final List<PostSummery> posts;

  const PostSearchScreen({
    required this.name,
    required this.posts,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: name.isNotEmpty && posts.isNotEmpty ? Text(
          '$name님의 게시글',
        ) : null,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: name.isNotEmpty && posts.isNotEmpty ? Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: posts!.length,
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
                          '${post.nickname} · ${post.createAt}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
              : const Center(child: Text('검색 결과 없음',),),
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
