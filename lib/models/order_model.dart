class OrderModel {
  final String orderId;
  final String requestId;
  final String professionalId;
  final String bidId;

  final double agreedPrice;
  final String estimatedTime;

  final String status;
  final DateTime createdAt;

  const OrderModel({
    required this.orderId,
    required this.requestId,
    required this.professionalId,
    required this.bidId,
    required this.agreedPrice,
    required this.estimatedTime,
    required this.status,
    required this.createdAt,
  });
}