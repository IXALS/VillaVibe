enum MessageStatus { sending, sent, read }
enum MessageType { text, image }

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;
  final MessageType type;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sending,
    this.type = MessageType.text,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'status': status.name,
        'type': type.name,
        'isRead': isRead,
      };

  factory Message.fromMap(Map<String, dynamic> map) => Message(
        id: map['id'],
        senderId: map['senderId'],
        receiverId: map['receiverId'],
        text: map['text'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
        status: MessageStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => MessageStatus.sent,
        ),
        type: MessageType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => MessageType.text,
        ),
        isRead: map['isRead'] ?? false,
      );
}
