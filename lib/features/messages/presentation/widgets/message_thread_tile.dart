import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/message_thread.dart';

class MessageThreadTile extends StatelessWidget {
  final MessageThread thread;
  const MessageThreadTile({super.key, required this.thread});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/message-room', extra: {
          "id": thread.id,
          "name": thread.name,
          "avatarUrl": thread.avatarUrl,
          "tripStatus": thread.tripStatus,
          "subtitle": thread.subtitle,
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(thread.avatarUrl),
            ),
            const SizedBox(width: 14),

            // Name + Last message + Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    thread.tripStatus,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    thread.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            // Time
            Text(
              _formatTime(thread.timestamp),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    }
    if (now.difference(time).inDays == 1) return "Yesterday";
    return "${time.day}/${time.month}";
  }
}
