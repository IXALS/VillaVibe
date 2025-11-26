import '../../data/message_service.dart';
import '../../data/message_model.dart';

class ChatController {
  final MessageService _service = MessageService();

  Stream<List<Message>> getMessages(String userA, String userB) {
    return _service.streamMessages(userA, userB);
  }

  Future<void> sendText({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      timestamp: DateTime.now(),
    );

    await _service.sendMessage(message);
  }
}
