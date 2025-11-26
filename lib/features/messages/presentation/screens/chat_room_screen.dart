import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  final Map<String, String> chat;

  const ChatRoomScreen({super.key, required this.chat});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> messages = ["Hello!", "Hi, I have a question about booking."];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat["name"] ?? "Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? Colors.grey[200] : Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(messages[index]),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                setState(() {
                  messages.add(_controller.text.trim());
                });
                _controller.clear();
              }
            },
          )
        ],
      ),
    );
  }
}
