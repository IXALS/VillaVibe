import 'package:flutter/material.dart';
import 'controller/message_controller.dart';
import '../data/message_model.dart';
import 'widgets/message_bubble.dart';
import 'widgets/input_field.dart';

class ChatRoomPage extends StatefulWidget {
  final String currentUser;
  final String otherUser;

  const ChatRoomPage({
    super.key,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ChatController controller = ChatController();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  void _send() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    controller.sendText(
      senderId: widget.currentUser,
      receiverId: widget.otherUser,
      text: text,
    );

    messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: controller.getMessages(widget.currentUser, widget.otherUser),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return MessageBubble(
                      message: msg,
                      isMe: msg.senderId == widget.currentUser,
                    );
                  },
                );
              },
            ),
          ),
          InputField(
            controller: messageController,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}