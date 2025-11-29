import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/message_thread.dart';

// This replaces your old dummy provider
final messageThreadsProvider =
    StateNotifierProvider<MessageThreadsNotifier, List<MessageThread>>((ref) {
  return MessageThreadsNotifier();
});

class MessageThreadsNotifier extends StateNotifier<List<MessageThread>> {
  MessageThreadsNotifier()
      : super([
          MessageThread(
            id: "1",
            name: "Sophie",
            lastMessage: "Amazing, thank you!",
            avatarUrl: "https://randomuser.me/api/portraits/women/44.jpg",
            timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
            unread: true,
            tripStatus: "Currently hosting",
            subtitle: "May 13–15 • Yucca Valley",
          ),
          MessageThread(
            id: "2",
            name: "Jason",
            lastMessage: "Airbnb update: A request to book...",
            avatarUrl: "https://randomuser.me/api/portraits/men/32.jpg",
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            unread: false,
            tripStatus: "Trip requested",
            subtitle: "Jul 7–13 • Yucca Valley",
          ),
          MessageThread(
            id: "3",
            name: "Lisa & Edward",
            lastMessage: "So excited!",
            avatarUrl: "https://randomuser.me/api/portraits/women/12.jpg",
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            unread: false,
            tripStatus: "Trip confirmed",
            subtitle: "Aug 14–17 • Yucca Valley",
          ),
        ]);

  void addThread(MessageThread thread) {
    state = [...state, thread];
  }
}
