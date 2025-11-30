import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentService {
  final FirebaseFunctions _functions;

  PaymentService(this._functions);

  Future<Map<String, dynamic>> createTransaction({
    required String bookingId,
    required double amount,
  }) async {
    try {
      final callable = _functions.httpsCallable('createMidtransTransaction');
      final result = await callable.call({
        'orderId': bookingId,
        'amount': amount,
      });

      // Result data should now contain qrString and transactionId
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(FirebaseFunctions.instance);
});
