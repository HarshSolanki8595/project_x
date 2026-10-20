import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../screens/order_status_screen.dart';
import '../../services/order_service.dart';

// ================================================================
// OUTSTANDING FEE PROMPT -- Added 2026-10-07
// ================================================================
// A customer who owes a cancellation / no-show fee can't place new
// requests or accept offers until it's paid. This is the blocked-state
// message: it says how much is owed and offers "Pay" which opens the same
// cancellation-fee payment sheet used on the booking screen.
// ================================================================

class OutstandingFeeInfo {
  final double amount;
  final String? orderId;

  const OutstandingFeeInfo({required this.amount, this.orderId});
}

class OutstandingFeePrompt {
  OutstandingFeePrompt._();

  /// Reads the signed-in customer's owed fee, or null if nothing is owed
  /// (or it can't be read -- the server is the real gate either way).
  static Future<OutstandingFeeInfo?> lookup() async {
    try {
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;

      final DocumentSnapshot<Map<String, dynamic>> doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final Map<String, dynamic>? data = doc.data();
      final double amount =
          (data?['outstandingFee'] as num?)?.toDouble() ?? 0;

      if (amount <= 0) return null;

      final dynamic ids = data?['outstandingFeeOrderIds'];
      String? orderId;
      if (ids is List && ids.isNotEmpty && ids.first is String) {
        orderId = ids.first as String;
      }

      return OutstandingFeeInfo(amount: amount, orderId: orderId);
    } catch (_) {
      return null;
    }
  }

  /// Shows the blocked-state dialog. Returns true if the customer went
  /// through to the payment sheet.
  static Future<bool> show(
    BuildContext context, {
    double? amountOwed,
    String? orderId,
  }) async {
    double amount = amountOwed ?? 0;
    String? targetOrderId = orderId;

    if (amount <= 0 || targetOrderId == null) {
      final OutstandingFeeInfo? info = await lookup();
      if (info != null) {
        if (amount <= 0) amount = info.amount;
        targetOrderId ??= info.orderId;
      }
    }

    if (!context.mounted) return false;

    final String amountText = amount > 0 ? amount.toStringAsFixed(0) : '150';

    final bool? pay = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Cancellation fee due',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(
            'You have an unpaid cancellation fee of ₹$amountText on a '
            'cancelled booking. Please pay it to place new requests or '
            'accept offers.',
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Not now'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('Pay ₹$amountText'),
            ),
          ],
        );
      },
    );

    if (pay != true || !context.mounted) return false;

    if (targetOrderId == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text(
            'Open the cancelled booking in My Bookings to pay the fee.',
          ),
        ),
      );
      return false;
    }

    final order = await OrderService.getOrder(targetOrderId);

    if (!context.mounted) return false;

    if (order == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Unable to open that booking right now.'),
        ),
      );
      return false;
    }

    await showCancellationFeeSheet(context, order);
    return true;
  }
}

/// Thrown by OrderAcceptanceService.acceptBid when the customer owes a fee.
class OutstandingFeeException implements Exception {
  final String message;
  final double amountOwed;
  final String? orderId;

  const OutstandingFeeException(
    this.message, {
    this.amountOwed = 0,
    this.orderId,
  });

  @override
  String toString() => message;
}
