import '../models/marketplace_status.dart';
import '../models/order_model.dart';
import 'bid_service.dart';

class OrderService {
  static int _orderCounter = 1;

  static final List<OrderModel> _orders = [];

  // ============================================================
  // CONSTANT
  // ============================================================

  static const int maxActiveOrdersPerProfessional = 2;

  // ============================================================
  // CREATE ORDER FROM ACCEPTED BID
  // ============================================================
  //
  // This method is called when the customer accepts a bid.
  //
  // Before creating the order we check whether the professional
  // already has 2 active orders.
  //
  static OrderModel createOrderFromBid({
    required String bidId,
  }) {
    // ----------------------------------------------------------
    // 1. FIND BID
    // ----------------------------------------------------------

    final bids = BidService.getAllBids();

    final bidIndex = bids.indexWhere(
      (bid) => bid.bidId == bidId,
    );

    if (bidIndex == -1) {
      throw StateError(
        'Bid not found.',
      );
    }

    final bid = bids[bidIndex];

    // ----------------------------------------------------------
    // 2. BID MUST BE ACCEPTED
    // ----------------------------------------------------------

    if (bid.status != MarketplaceStatus.accepted) {
      throw StateError(
        'Order can only be created from an accepted bid.',
      );
    }

    // ----------------------------------------------------------
    // 3. PREVENT DUPLICATE ORDER FOR SAME BID
    // ----------------------------------------------------------

    final existingOrder = _findOrderByBidId(
      bidId,
    );

    if (existingOrder != null) {
      throw StateError(
        'An order already exists for this bid.',
      );
    }

    // ----------------------------------------------------------
    // 4. CHECK ACTIVE ORDER LIMIT
    // ----------------------------------------------------------

    final activeOrderCount =
        getActiveOrderCountForProfessional(
      bid.professionalId,
    );

    if (activeOrderCount >=
        maxActiveOrdersPerProfessional) {
      throw StateError(
        'Professional already has '
        '$maxActiveOrdersPerProfessional active orders.',
      );
    }

    // ----------------------------------------------------------
    // 5. CREATE ORDER ID
    // ----------------------------------------------------------

    final String orderId =
        'ORDER_${_orderCounter.toString().padLeft(6, '0')}';

    _orderCounter++;

    // ----------------------------------------------------------
    // 6. CREATE ORDER
    // ----------------------------------------------------------

    final order = OrderModel(
      orderId: orderId,
      requestId: bid.requestId,
      professionalId: bid.professionalId,
      bidId: bid.bidId,
      agreedPrice: bid.quotedPrice,
      estimatedTime: bid.estimatedTime,
      status: MarketplaceStatus.confirmed,
      createdAt: DateTime.now(),
    );

    _orders.add(order);

    return order;
  }

  // ============================================================
  // GET ACTIVE ORDER COUNT
  // ============================================================

  static int getActiveOrderCountForProfessional(
    String professionalId,
  ) {
    return _orders.where(
      (order) =>
          order.professionalId == professionalId &&
          _isActiveOrderStatus(order.status),
    ).length;
  }

  // ============================================================
  // GET ACTIVE ORDERS
  // ============================================================

  static List<OrderModel> getActiveOrdersForProfessional(
    String professionalId,
  ) {
    return _orders
        .where(
          (order) =>
              order.professionalId == professionalId &&
              _isActiveOrderStatus(order.status),
        )
        .toList();
  }

  // ============================================================
  // GET ORDERS FOR REQUEST
  // ============================================================

  static List<OrderModel> getOrdersForRequest(
    String requestId,
  ) {
    return _orders
        .where(
          (order) => order.requestId == requestId,
        )
        .toList();
  }

  // ============================================================
  // GET ORDER BY ID
  // ============================================================

  static OrderModel? getOrderById(
    String orderId,
  ) {
    for (final order in _orders) {
      if (order.orderId == orderId) {
        return order;
      }
    }

    return null;
  }

  // ============================================================
  // MARK ORDER ACTIVE
  // ============================================================
  //
  // CONFIRMED means the customer accepted the bid.
  //
  // ACTIVE means the order is ready to begin or work has begun.
  //

  static OrderModel markOrderActive(
    String orderId,
  ) {
    final int index = _orders.indexWhere(
      (order) => order.orderId == orderId,
    );

    if (index == -1) {
      throw StateError(
        'Order not found.',
      );
    }

    final existingOrder = _orders[index];

    if (existingOrder.status !=
        MarketplaceStatus.confirmed) {
      throw StateError(
        'Only a confirmed order can become active.',
      );
    }

    final updatedOrder = OrderModel(
      orderId: existingOrder.orderId,
      requestId: existingOrder.requestId,
      professionalId: existingOrder.professionalId,
      bidId: existingOrder.bidId,
      agreedPrice: existingOrder.agreedPrice,
      estimatedTime: existingOrder.estimatedTime,
      status: MarketplaceStatus.active,
      createdAt: existingOrder.createdAt,
    );

    _orders[index] = updatedOrder;

    return updatedOrder;
  }

  // ============================================================
  // COMPLETE ORDER
  // ============================================================

  static OrderModel completeOrder(
    String orderId,
  ) {
    final int index = _orders.indexWhere(
      (order) => order.orderId == orderId,
    );

    if (index == -1) {
      throw StateError(
        'Order not found.',
      );
    }

    final existingOrder = _orders[index];

    if (existingOrder.status !=
            MarketplaceStatus.confirmed &&
        existingOrder.status !=
            MarketplaceStatus.active) {
      throw StateError(
        'Only a confirmed or active order can be completed.',
      );
    }

    final completedOrder = OrderModel(
      orderId: existingOrder.orderId,
      requestId: existingOrder.requestId,
      professionalId: existingOrder.professionalId,
      bidId: existingOrder.bidId,
      agreedPrice: existingOrder.agreedPrice,
      estimatedTime: existingOrder.estimatedTime,
      status: MarketplaceStatus.orderCompleted,
      createdAt: existingOrder.createdAt,
    );

    _orders[index] = completedOrder;

    return completedOrder;
  }

  // ============================================================
  // CANCEL ORDER
  // ============================================================

  static OrderModel cancelOrder(
    String orderId,
  ) {
    final int index = _orders.indexWhere(
      (order) => order.orderId == orderId,
    );

    if (index == -1) {
      throw StateError(
        'Order not found.',
      );
    }

    final existingOrder = _orders[index];

    if (existingOrder.status !=
            MarketplaceStatus.confirmed &&
        existingOrder.status !=
            MarketplaceStatus.active) {
      throw StateError(
        'Only a confirmed or active order can be cancelled.',
      );
    }

    final cancelledOrder = OrderModel(
      orderId: existingOrder.orderId,
      requestId: existingOrder.requestId,
      professionalId: existingOrder.professionalId,
      bidId: existingOrder.bidId,
      agreedPrice: existingOrder.agreedPrice,
      estimatedTime: existingOrder.estimatedTime,
      status: MarketplaceStatus.orderCancelled,
      createdAt: existingOrder.createdAt,
    );

    _orders[index] = cancelledOrder;

    return cancelledOrder;
  }

  // ============================================================
  // GET ALL ORDERS
  // ============================================================

  static List<OrderModel> getAllOrders() {
    return List.unmodifiable(_orders);
  }

  // ============================================================
  // INTERNAL: FIND ORDER BY BID
  // ============================================================

  static OrderModel? _findOrderByBidId(
    String bidId,
  ) {
    for (final order in _orders) {
      if (order.bidId == bidId) {
        return order;
      }
    }

    return null;
  }

  // ============================================================
  // INTERNAL: ACTIVE ORDER STATUS
  // ============================================================
  //
  // CONFIRMED and ACTIVE both count toward the professional's
  // 2-order limit because the customer has already accepted
  // the bid and the engagement is confirmed/ready to begin.
  //
  // COMPLETED and CANCELLED do not count.
  //

  static bool _isActiveOrderStatus(
    String status,
  ) {
    return status == MarketplaceStatus.confirmed ||
        status == MarketplaceStatus.active;
  }
}