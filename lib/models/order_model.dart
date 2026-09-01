import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String requestId;
  final String professionalId;
  final String customerId;
  final String customerName;
  final String customerPhone;

  final String bidId;
  final double agreedPrice;
  final String warranty;

  final String status;

  // ============================================================
  // PAYMENT (NEW — 2026-08-21)
  // ============================================================
  //
  // paymentStatus: '' (not yet paid) or 'PAID'. paymentChannel:
  // '' or 'IN_APP' (mocked -- no real Razorpay yet) or 'CASH' (set
  // by completeJob if the professional closed the job before the
  // customer paid in-app). All written exclusively by the
  // recordPayment / completeJob Cloud Functions -- read-only here.
  //
  // The three charge fields mirror the exact calculation used
  // server-side (9.5% Platform Charges + 18% GST on that) --
  // customerTotal is what the customer actually owes/paid, always
  // slightly more than agreedPrice.
  //

  final String paymentStatus;
  final String paymentChannel;
  final DateTime? paidAt;
  final double customerPlatformCharge;
  final double customerGst;
  final double customerTotal;

  // ============================================================
  // CANCELLATION (NEW — 2026-08-29)
  // ============================================================
  //
  // cancellationFee: flat ₹150 charge written by the cancelOrder
  // Cloud Function whenever a customer withdraws from an
  // already-CONFIRMED/ACTIVE order (a still-searching request that
  // never had a bid accepted is cancelled for free, client-side --
  // this fee only applies once a professional is actually engaged).
  // Like the rest of the payment fields, this is MOCKED/recorded
  // only -- no real gateway collects it yet.
  //

  final double cancellationFee;

  // cancellationFeeStatus: '' (no fee/not yet charged), 'UNPAID', or
  // 'PAID' -- written by cancelOrder (sets UNPAID) and
  // payCancellationFee (sets PAID). Same mocked pattern as
  // paymentStatus above.
  final String cancellationFeeStatus;
  final DateTime? cancellationFeePaidAt;

  // ============================================================
  // PROFESSIONAL WITHDRAWAL (NEW — 2026-08-30)
  // ============================================================
  //
  // cancelledBy: '' or 'PROFESSIONAL' -- set only when the
  // PROFESSIONAL withdraws from an already-confirmed job
  // (professionalWithdrawOrder in index.js), never for a
  // customer-initiated cancellation. Deliberately a separate field
  // from cancellationFee/cancellationFeeStatus above: that ₹150 fee
  // is always the CUSTOMER's to pay, and this app must never show a
  // "Pay ₹150" prompt for a fee that's actually the professional's
  // to cover -- see order_status_screen.dart's cancelledBy check,
  // which shows a "find a new professional" card instead.
  //

  final String cancelledBy;

  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const OrderModel({
    required this.orderId,
    required this.requestId,
    required this.professionalId,
    required this.customerId,
    this.customerName = '',
    this.customerPhone = '',
    required this.bidId,
    required this.agreedPrice,
    this.warranty = '',
    required this.status,
    this.paymentStatus = '',
    this.paymentChannel = '',
    this.paidAt,
    this.customerPlatformCharge = 0,
    this.customerGst = 0,
    this.customerTotal = 0,
    this.cancellationFee = 0,
    this.cancellationFeeStatus = '',
    this.cancellationFeePaidAt,
    this.cancelledBy = '',
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  // ============================================================
  // IS PAID (convenience getter)
  // ============================================================

  bool get isPaid => paymentStatus == 'PAID';

  bool get isCancellationFeePaid => cancellationFeeStatus == 'PAID';

  bool get isWithdrawnByProfessional => cancelledBy == 'PROFESSIONAL';

  // ============================================================
  // FROM FIRESTORE
  // ============================================================

  factory OrderModel.fromFirestore(Map<String, dynamic> data) {
    return OrderModel(
      orderId: data['orderId'] as String? ?? '',
      requestId: data['requestId'] as String? ?? '',
      professionalId: data['professionalId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      bidId: data['bidId'] as String? ?? '',
      agreedPrice: (data['agreedPrice'] as num?)?.toDouble() ?? 0,
      warranty: data['warranty'] as String? ?? '',
      status: data['status'] as String? ?? '',
      paymentStatus: data['paymentStatus'] as String? ?? '',
      paymentChannel: data['paymentChannel'] as String? ?? '',
      paidAt: data['paidAt'] == null ? null : _readDate(data['paidAt']),
      customerPlatformCharge:
          (data['customerPlatformCharge'] as num?)?.toDouble() ?? 0,
      customerGst: (data['customerGst'] as num?)?.toDouble() ?? 0,
      customerTotal: (data['customerTotal'] as num?)?.toDouble() ?? 0,
      cancellationFee: (data['cancellationFee'] as num?)?.toDouble() ?? 0,
      cancellationFeeStatus: data['cancellationFeeStatus'] as String? ?? '',
      cancellationFeePaidAt: data['cancellationFeePaidAt'] == null
          ? null
          : _readDate(data['cancellationFeePaidAt']),
      cancelledBy: data['cancelledBy'] as String? ?? '',
      createdAt: _readDate(data['createdAt']),
      startedAt:
          data['startedAt'] == null ? null : _readDate(data['startedAt']),
      completedAt: data['completedAt'] == null
          ? null
          : _readDate(data['completedAt']),
    );
  }

  // ============================================================
  // FROM CALLABLE RESPONSE
  // ============================================================
  //
  // The acceptBid Cloud Function returns the freshly created order
  // as a plain map -- createdAt there is an ISO date STRING, not a
  // Timestamp. Payment fields don't exist yet at this point (a
  // brand-new order is never pre-paid), so they're left at defaults.
  //

  factory OrderModel.fromCallableResponse(Map<String, dynamic> data) {
    return OrderModel(
      orderId: data['orderId'] as String? ?? '',
      requestId: data['requestId'] as String? ?? '',
      professionalId: data['professionalId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      bidId: data['bidId'] as String? ?? '',
      agreedPrice: (data['agreedPrice'] as num?)?.toDouble() ?? 0,
      warranty: data['warranty'] as String? ?? '',
      status: data['status'] as String? ?? '',
      createdAt: _readDate(data['createdAt']),
      startedAt: null,
      completedAt: null,
    );
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}