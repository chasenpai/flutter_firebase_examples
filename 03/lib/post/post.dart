class Post {
  final String? id;
  final String nickname;
  final String password;
  final String title;
  final String content;
  final DateTime? createAt;
  final int? hits;

  const Post({
    this.id,
    required this.nickname,
    required this.password,
    required this.title,
    required this.content,
    this.createAt,
    this.hits,
  });

  factory Post.fromJson(String id, Map<dynamic, dynamic> json) {
    return Post(
      id: id,
      nickname: json['nickname'],
      password: json['password'],
      title: json['title'],
      content: json['content'],
      createAt: DateTime.fromMillisecondsSinceEpoch(json['createAt']),
      hits: json['hits'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'password': password,
      'title': title,
      'content': content,
      if(createAt != null) 'createAt': createAt!.millisecondsSinceEpoch,
      if(hits != null) 'hits': hits,
    };
  }
}