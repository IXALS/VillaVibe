class MessageThread {
  final String id;
  final String name;
  final String lastMessage;
  final String avatarUrl;
  final DateTime timestamp;
  final bool unread;
  final String tripStatus; // “Currently hosting”, “Trip confirmed”, etc.
  final String subtitle;   // Date range info
  final String otherUserId;

  MessageThread({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.avatarUrl,
    required this.timestamp,
    this.unread = false,
    required this.tripStatus,
    required this.subtitle,
    required this.otherUserId,
  });
}
