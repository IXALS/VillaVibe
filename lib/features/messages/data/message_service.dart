import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_model.dart';

class MessageService {
  final _db = FirebaseFirestore.instance;

  Future<void> sendMessage(Message message) async {
    await _db
        .collection("messages")
        .doc(message.id)
        .set(message.toMap());
  }

  Stream<List<Message>> streamMessages(String userA, String userB) {
    return _db
        .collection("messages")
        .where("senderId", whereIn: [userA, userB])
        .where("receiverId", whereIn: [userA, userB])
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data()))
            .toList());
  }
}
