import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  final String userId;
  final String chatRoomId;
  final String chatName;

  const ChatRoomScreen({
    required this.userId,
    required this.chatRoomId,
    required this.chatName,
    super.key,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _chatRoomsRef = FirebaseDatabase.instance.ref('chatRooms');
  final _messagesRef = FirebaseDatabase.instance.ref('messages');
  final _chattingController = TextEditingController();
  final _scrollController = ScrollController();

  void sendMessage() async {
    if(_chattingController.text.isNotEmpty) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final message = {
        'senderId': widget.userId,
        'text': _chattingController.text,
        'timestamp': timestamp,
      };
      await _messagesRef.child(widget.chatRoomId).child(timestamp.toString()).set(message);
      await _chatRoomsRef.child(widget.chatRoomId).update(
        {
          'lastMessage': {
            'senderId': widget.userId,
            'text': _chattingController.text,
            'timestamp': timestamp,
          },
        },
      );
      _chattingController.clear();
    }
  }

  @override
  void dispose() {
    _chattingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.chatName}님과 대화',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _messagesRef.child(widget.chatRoomId).onValue,
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(),);
                  }
                  final Map<dynamic, dynamic> messagesData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  final List<dynamic> messages = messagesData.entries.map((entry) => entry.value).toList();
                  messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if(_scrollController.hasClients) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSender = message['senderId'] == widget.userId;
                      return Align(
                        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: isSender ? Colors.lightBlue[100] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Text(
                              message['text'],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chattingController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '채팅 입력',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: const Icon(
                      Icons.send,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
