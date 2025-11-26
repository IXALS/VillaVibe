class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory Message.fromMap(Map<String, dynamic> map) => Message(
        id: map['id'],
        senderId: map['senderId'],
        receiverId: map['receiverId'],
        text: map['text'],
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      );
}
