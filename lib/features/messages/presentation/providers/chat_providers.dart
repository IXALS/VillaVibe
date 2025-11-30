import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/chat_repository.dart';
import '../../data/message_model.dart';
import '../../domain/models/message_thread.dart';

// Stream provider for messages in a specific chat
final chatStreamProvider = StreamProvider.family<List<Message>, String>((ref, chatId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getMessages(chatId);
});

final chatControllerProvider = StateNotifierProvider<ChatController, AsyncValue<void>>((ref) {
  return ChatController(ref.watch(chatRepositoryProvider));
});

final typingStatusProvider = StreamProvider.family<List<String>, String>((ref, chatId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.streamTypingUsers(chatId);
});

// Stream provider for chat list
final chatListStreamProvider = StreamProvider.family<List<MessageThread>, String>((ref, userId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getChats(userId);
});

// Controller for sending messages
class ChatController extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repository;

  ChatController(this._repository) : super(const AsyncValue.data(null));

  Future<void> sendMessage(String chatId, Message message) async {
    state = const AsyncValue.loading();
    try {
      await _repository.sendMessage(chatId, message);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setTyping(String chatId, String userId, bool isTyping) async {
    try {
      await _repository.setTypingStatus(chatId, userId, isTyping);
    } catch (_) {
      // Ignore typing errors
    }
  }
  
  Future<void> markAsRead(String chatId, String messageId) async {
    try {
      await _repository.markAsRead(chatId, messageId);
    } catch (_) {
      // Ignore errors
    }
  }

  Future<String?> createOrGetChat(
    String currentUserId,
    String otherUserId, {
    required Map<String, dynamic> currentUserData,
    required Map<String, dynamic> otherUserData,
  }) async {
    state = const AsyncValue.loading();
    try {
      final chatId = await _repository.createOrGetChat(
        currentUserId,
        otherUserId,
        currentUserData: currentUserData,
        otherUserData: otherUserData,
      );
      state = const AsyncValue.data(null);
      return chatId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}
