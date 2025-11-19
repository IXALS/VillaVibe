import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String propertyId;
  final String guestId;
  final String hostId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalPrice;
  final String status; // 'paid', 'cancelled', 'pending'

  Booking({
    required this.id,
    required this.propertyId,
    required this.guestId,
    required this.hostId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      propertyId: data['propertyId'] ?? '',
      guestId: data['guestId'] ?? '',
      hostId: data['hostId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      totalPrice: data['totalPrice'] ?? 0,
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'guestId': guestId,
      'hostId': hostId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalPrice': totalPrice,
      'status': status,
    };
  }
}
