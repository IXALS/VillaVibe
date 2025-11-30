import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'message_model.dart';
import '../domain/models/message_thread.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(FirebaseFirestore.instance);
});

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository(this._firestore);

  // Get messages stream for a specific chat
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
    });
  }

  // Send a new message
  Future<void> sendMessage(String chatId, Message message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
        
    // Update last message in chat document (optional but good for list view)
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': message.text,
      'lastMessageTime': message.timestamp.millisecondsSinceEpoch,
      'participants': [message.senderId, message.receiverId],
    }, SetOptions(merge: true));
  }

  // Mark message as read
  Future<void> markAsRead(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true, 'status': MessageStatus.read.name});
  }

  // Set typing status
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping) async {
    await _firestore.collection('chats').doc(chatId).set({
      'typingUsers': {
        userId: isTyping,
      }
    }, SetOptions(merge: true));
  }

  // Stream typing status
  Stream<List<String>> streamTypingUsers(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return [];
      final data = snapshot.data();
      if (data == null || !data.containsKey('typingUsers')) return [];
      
      final typingMap = Map<String, bool>.from(data['typingUsers'] as Map);
      return typingMap.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
    });
  }

  // Create or get existing chat
  Future<String> createOrGetChat(
    String currentUserId,
    String otherUserId, {
    required Map<String, dynamic> currentUserData,
    required Map<String, dynamic> otherUserData,
  }) async {
    // Check for existing chat
    final querySnapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in querySnapshot.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      if (participants.contains(otherUserId)) {
        // HEAL: Update userData if it exists but might be missing data
        await doc.reference.set({
          'userData': {
            currentUserId: currentUserData,
            otherUserId: otherUserData,
          }
        }, SetOptions(merge: true));
        
        return doc.id;
      }
    }

    // Create new chat
    final docRef = await _firestore.collection('chats').add({
      'participants': [currentUserId, otherUserId],
      'userData': {
        currentUserId: currentUserData,
        otherUserId: otherUserData,
      },
      'lastMessage': '',
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      'typingUsers': {},
    });

    return docRef.id;
  }

  // Stream of chat threads for a user
  Stream<List<MessageThread>> getChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final userDataMap = data['userData'];
        Map<String, dynamic> safeUserDataMap = {};
        if (userDataMap is Map) {
          safeUserDataMap = Map<String, dynamic>.from(userDataMap);
        }
        
        // Find the OTHER user's data
        String otherUserId = '';
        final participants = List<String>.from(data['participants'] ?? []);
        for (var p in participants) {
          if (p != userId) {
            otherUserId = p;
            break;
          }
        }

        final otherUserRaw = safeUserDataMap[otherUserId];
        final otherUser = (otherUserRaw is Map) 
            ? Map<String, dynamic>.from(otherUserRaw) 
            : <String, dynamic>{};
            
        final name = otherUser['name'] ?? 'Unknown User';
        final avatar = otherUser['avatar'] ?? '';
        
        final lastMessageTime = DateTime.fromMillisecondsSinceEpoch(
            data['lastMessageTime'] ?? DateTime.now().millisecondsSinceEpoch);

        return MessageThread(
          id: doc.id,
          name: name,
          lastMessage: data['lastMessage'] ?? '',
          avatarUrl: avatar,
          timestamp: lastMessageTime,
          unread: false, // TODO: Implement unread count logic
          tripStatus: 'Inquiry', // Placeholder
          subtitle: 'Tap to view',
          otherUserId: otherUserId,
        );
      }).toList();
    });
  }
}
