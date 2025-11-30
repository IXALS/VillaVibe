import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showTime;
  final bool isFirstInSequence;
  final bool isLastInSequence;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showTime = true,
    this.isFirstInSequence = true,
    this.isLastInSequence = true,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final theme = Theme.of(context);

    // Smart border radius logic
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(isMe ? 20 : (isFirstInSequence ? 20 : 5)),
      topRight: Radius.circular(isMe ? (isFirstInSequence ? 20 : 5) : 20),
      bottomLeft: Radius.circular(isMe ? 20 : (isLastInSequence ? 20 : 5)),
      bottomRight: Radius.circular(isMe ? (isLastInSequence ? 20 : 5) : 20),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: isFirstInSequence ? 4 : 2,
              bottom: isLastInSequence ? 4 : 2,
              left: 12,
              right: 12,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isMe ? theme.primaryColor : Colors.grey.shade200,
              borderRadius: borderRadius,
              boxShadow: [
                if (isLastInSequence)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isMe ? Colors.white : Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeFormat.format(message.timestamp),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isMe ? Colors.white70 : Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        _getStatusIcon(message.status),
                        size: 14,
                        color: Colors.white70,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.read:
        return Icons.done_all;
    }
  }
}

