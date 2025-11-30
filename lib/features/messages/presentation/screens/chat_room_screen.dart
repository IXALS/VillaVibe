import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import '../../data/message_model.dart';
import '../providers/chat_providers.dart';
import '../widgets/message_bubble.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final Map<String, String> chat;

  const ChatRoomScreen({super.key, required this.chat});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Debounce typing updates
  DateTime? _lastTypingTime;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final chatId = widget.chat['id'] ?? 'unknown_chat';
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    final userId = user.uid;

    if (_controller.text.isNotEmpty) {
      if (_lastTypingTime == null || 
          DateTime.now().difference(_lastTypingTime!) > const Duration(seconds: 2)) {
        ref.read(chatControllerProvider.notifier).setTyping(chatId, userId, true);
        _lastTypingTime = DateTime.now();
      }
    } else {
      ref.read(chatControllerProvider.notifier).setTyping(chatId, userId, false);
      _lastTypingTime = null;
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final chatId = widget.chat['id'] ?? 'unknown_chat';
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    final userId = user.uid;
    
    final message = Message(
      id: const Uuid().v4(),
      senderId: userId,
      receiverId: widget.chat['userId'] ?? 'unknown_user',
      text: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    ref.read(chatControllerProvider.notifier).sendMessage(chatId, message);
    ref.read(chatControllerProvider.notifier).setTyping(chatId, userId, false);
    _controller.clear();
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Helper to build date separators
  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    String text;
    if (messageDate == today) {
      text = 'Today';
    } else if (messageDate == yesterday) {
      text = 'Yesterday';
    } else {
      text = DateFormat('MMMM d, y').format(date);
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final userId = user?.uid ?? '';
    final chatId = widget.chat['id'] ?? 'unknown_chat';
    final messagesAsync = ref.watch(chatStreamProvider(chatId));
    final typingUsersAsync = ref.watch(typingStatusProvider(chatId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: (widget.chat['image']?.isNotEmpty ?? false)
                  ? NetworkImage(widget.chat['image']!)
                  : const NetworkImage('https://i.pravatar.cc/150'),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat["name"] ?? "Chat",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                typingUsersAsync.when(
                  data: (users) {
                    // Filter out current user
                    final othersTyping = users.where((u) => u != userId).toList();
                    if (othersTyping.isNotEmpty) {
                      return const Text(
                        "Typing...",
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ).animate(onPlay: (c) => c.repeat()).fade();
                    }
                    return const Text(
                      "Online",
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          "No messages yet",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                // Mark unread messages as read
                // Note: In a real app, do this more carefully to avoid excessive writes
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  for (var msg in messages) {
                    if (!msg.isRead && msg.senderId != 'current_user_id') {
                      ref.read(chatControllerProvider.notifier).markAsRead(chatId, msg.id);
                    }
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final nextMsg = i > 0 ? messages[i - 1] : null; // Visually below (newer)
                    final prevMsg = i < messages.length - 1 ? messages[i + 1] : null; // Visually above (older)

                    bool isFirstInSequence = true;
                    bool isLastInSequence = true;
                    bool showDateHeader = false;

                    if (prevMsg != null) {
                      isFirstInSequence = prevMsg.senderId != msg.senderId;
                      
                      // Check for date change
                      final msgDate = DateTime(msg.timestamp.year, msg.timestamp.month, msg.timestamp.day);
                      final prevDate = DateTime(prevMsg.timestamp.year, prevMsg.timestamp.month, prevMsg.timestamp.day);
                      if (msgDate != prevDate) {
                        showDateHeader = true;
                        isFirstInSequence = true; // Force new sequence on new day
                      }
                    } else {
                      // Oldest message is always first in sequence
                      showDateHeader = true;
                    }

                    if (nextMsg != null) {
                      isLastInSequence = nextMsg.senderId != msg.senderId;
                      
                      // Check if next message is on a different day (rare in reverse list but possible)
                      final msgDate = DateTime(msg.timestamp.year, msg.timestamp.month, msg.timestamp.day);
                      final nextDate = DateTime(nextMsg.timestamp.year, nextMsg.timestamp.month, nextMsg.timestamp.day);
                      if (msgDate != nextDate) {
                        isLastInSequence = true;
                      }
                    }

                    return Column(
                      children: [
                        if (showDateHeader) _buildDateHeader(msg.timestamp),
                        MessageBubble(
                          message: msg,
                          isMe: msg.senderId == userId,
                          isFirstInSequence: isFirstInSequence,
                          isLastInSequence: isLastInSequence,
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
