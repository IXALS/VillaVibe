import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyChats = [
      {"name": "Host Andi", "last": "Hello, how can I help?", "id": "1"},
      {"name": "Villa Batu Host", "last": "Your check-in is confirmed!", "id": "2"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Messages"),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: dummyChats.length,
        itemBuilder: (context, index) {
          final chat = dummyChats[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(child: Text(chat["name"]![0])),
            title: Text(chat["name"]!),
            subtitle: Text(chat["last"]!),
            onTap: () {
              context.push("/message-room", extra: chat);
            },
          );
        },
      ),
    );
  }
}
