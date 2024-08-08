import 'package:async/async.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:test05/chat/chat_room_screen.dart';

class ChatsScreen extends StatefulWidget {
  final String userId;

  const ChatsScreen({
    required this.userId,
    super.key,
  });

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final _usersRef = FirebaseDatabase.instance.ref('users');
  final _chatRoomsRef = FirebaseDatabase.instance.ref('chatRooms');

  Stream<List<DataSnapshot>> chatRoomsStream() async* {
    Map<String, DataSnapshot> chatRoomSnapshots = {};
    final Stream<DatabaseEvent> userChatRoomIdsStream =
        _usersRef.child('${widget.userId}/chatRoomIds').onValue;
    await for(var event in userChatRoomIdsStream) {
      final Map<dynamic, dynamic> chatRoomIds = event.snapshot.value as Map<dynamic, dynamic>;
      List<String> userChatRoomIds = chatRoomIds.keys.map((key) => key.toString()).toList();
      List<Stream<DataSnapshot>> chatRoomStreams = userChatRoomIds.map((id) {
        return _chatRoomsRef.child(id).onValue.map((event) => event.snapshot);
      }).toList();
      yield* StreamGroup.merge(chatRoomStreams).map((snapshot) {
        chatRoomSnapshots[snapshot.key!] = snapshot;
        return chatRoomSnapshots.values.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '채팅 목록',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<DataSnapshot>>(
          stream: chatRoomsStream(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(),);
            }
            if(!snapshot.hasData) {
              print(snapshot);
              return const Center(child: CircularProgressIndicator(),);
            }
            final List<DataSnapshot> chatRooms = snapshot.data!;
            chatRooms.sort((a, b) {
              final aTimestamp = a.child('lastMessage/timestamp').value as int;
              final bTimestamp = b.child('lastMessage/timestamp').value as int;
              return bTimestamp.compareTo(aTimestamp);
            });
            return ListView.separated(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoomId = chatRooms[index].key as String;
                final Map<dynamic, dynamic> chatRoom = chatRooms[index].value as Map<dynamic, dynamic>;
                final name = chatRoom['names'][widget.userId];
                final text = chatRoom['lastMessage']['text'];
                final timestamp = DateTime.fromMillisecondsSinceEpoch(chatRoom['lastMessage']['timestamp'] as int);
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ChatRoomScreen(
                          userId: widget.userId,
                          chatRoomId: chatRoomId,
                          chatName: name,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: const CircleAvatar(),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18.0,
                          ),
                        ),
                        Text(
                          '${timestamp.month}월 ${timestamp.day}일',
                        ),
                      ],
                    ),
                    subtitle: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16.0,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  height: 1,
                  thickness: 1.25,
                  color: Colors.grey[200],
                );
              },
            );
            //return Container();
          },
        ),
      ),
    );
  }
}
