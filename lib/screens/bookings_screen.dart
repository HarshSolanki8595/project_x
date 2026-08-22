import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/marketplace_status.dart';
import '../models/order_model.dart';
import '../models/professional_model.dart';
import '../models/service_request.dart';
import '../models/service_request_model.dart';
import '../services/order_service.dart';
import '../services/professional_firestore_service.dart';
import '../services/request_repository.dart';
import 'order_status_screen.dart';
import 'professionals_screen.dart';

// ================================================================
// BOOKINGS SCREEN — REBUILT ON REAL DATA (2026-08-21)
// ================================================================
//
// Same 4 tabs, same visual card language as before (Upcoming /
// Ongoing / Completed / Cancelled). What changed is ONLY the data
// source: this used to read from the old mock Booking model via
// BookingRepository (see booking.dart / booking_repository.dart --
// left untouched and now unused, per instruction to leave orphaned
// files alone). It now reads directly from the real
// service_requests and orders collections that the actual bidding
// flow writes to.
//
// STAGE MAPPING (kept the existing 4 tab labels unchanged):
//   Upcoming   = service_requests still OPEN with no order yet
//                (covers: searching for professionals, waiting for
//                quotes, quotes received but not yet chosen)
//   Ongoing    = orders with status CONFIRMED or ACTIVE
//                (covers: just accepted, through active work)
//   Completed  = orders with status ORDER_COMPLETED
//   Cancelled  = orders with status ORDER_CANCELLED, OR requests
//                cancelled before any bid was accepted
//
// Tapping a card reuses your EXISTING screens rather than a new
// details screen: Upcoming -> ProfessionalsScreen (the same
// "Choose the right professional" screen used everywhere else),
// Ongoing/Completed/Cancelled -> OrderStatusScreen (the same real
// order-tracking screen already used after accepting a bid). No
// new screens were built, and bidding/bid-visibility code was not
// touched.
//

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // HABIO BLUE
  // ============================================================

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);
  static const Color background = Color(0xFFF7F8FC);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  late TabController _tabController;

  bool _cancelling = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================
  // CONVERT REAL MODEL -> LEGACY ServiceRequest
  // ============================================================
  //
  // ProfessionalsScreen and OrderStatusScreen both take the OLDER
  // `ServiceRequest` model (service_request.dart), not the real
  // Firestore-backed `ServiceRequestModel` this screen now reads.
  // Rather than rebuild either of those already-working screens,
  // this small adapter bridges the two -- only the fields those
  // screens actually read (issueDescription, requestId, latitude,
  // longitude, customerId, urgency, capabilityId/requestTypeId/
  // categoryId) are populated; fields the real model doesn't track
  // (subCategoryName, preferredDate, preferredTimeSlot, address)
  // are left at sensible defaults.
  //

  ServiceRequest _toLegacyRequest(ServiceRequestModel model) {
    return ServiceRequest(
      categoryName: model.categoryId,
      subCategoryName: model.requestTypeId,
      issueDescription: model.description,
      isEmergency: model.urgency.toUpperCase() == 'URGENT',
      latitude: model.latitude,
      longitude: model.longitude,
      requestId: model.requestId,
      requestTypeId: model.requestTypeId,
      capabilityId: model.capabilityId,
      categoryId: model.categoryId,
      customerId: model.customerId,
      urgency: model.urgency,
    );
  }

  // ============================================================
  // CANCEL REQUEST (UPCOMING TAB)
  // ============================================================

  Future<void> _cancelRequest(ServiceRequestModel request) async {
    final confirmed = await _showCancelConfirmation(
      title: 'Cancel this request?',
      message:
          'This will stop the search for professionals and close any offers already received.',
    );

    if (!confirmed || _cancelling) {
      return;
    }

    setState(() {
      _cancelling = true;
    });

    try {
      await RequestRepository.cancelRequest(request.requestId);

      if (!mounted) {
        return;
      }

      _tabController.animateTo(3);
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage('Unable to cancel this request right now.');
    } finally {
      if (mounted) {
        setState(() {
          _cancelling = false;
        });
      }
    }
  }

  // ============================================================
  // CANCEL ORDER (ONGOING TAB)
  // ============================================================

  Future<void> _cancelOrder(OrderModel order) async {
    final confirmed = await _showCancelConfirmation(
      title: 'Cancel this booking?',
      message:
          'The professional will be notified and this slot will be released.',
    );

    if (!confirmed || _cancelling) {
      return;
    }

    setState(() {
      _cancelling = true;
    });

    try {
      await OrderService.cancelOrder(order.orderId);

      if (!mounted) {
        return;
      }

      _tabController.animateTo(3);
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst('Bad state: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cancelling = false;
        });
      }
    }
  }

  // ============================================================
  // CANCEL CONFIRMATION
  // ============================================================

  Future<bool> _showCancelConfirmation({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Keep Booking',
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(
                  color: Color(0xFFD92D20),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(
          child: Text(
            "Please login first.",
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 22,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "My Bookings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),

        bottom: TabBar(
          controller: _tabController,

          isScrollable: true,

          tabAlignment: TabAlignment.start,

          labelColor: primaryBlue,

          unselectedLabelColor: textSecondary,

          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),

          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),

          indicatorColor: primaryBlue,

          indicatorWeight: 2.5,

          indicatorSize: TabBarIndicatorSize.label,

          dividerColor: const Color(0xFFD9DDE5),

          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Ongoing"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),

      body: StreamBuilder<List<ServiceRequestModel>>(
        stream: RequestRepository.watchRequestsForCustomer(user.uid),
        builder: (context, requestsSnapshot) {
          if (requestsSnapshot.connectionState ==
                  ConnectionState.waiting &&
              !requestsSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            );
          }

          if (requestsSnapshot.hasError) {
            return _errorState(requestsSnapshot.error.toString());
          }

          final requests = requestsSnapshot.data ?? const [];

          return StreamBuilder<List<OrderModel>>(
            stream: OrderService.watchOrdersForCustomer(user.uid),
            builder: (context, ordersSnapshot) {
              if (ordersSnapshot.connectionState ==
                      ConnectionState.waiting &&
                  !ordersSnapshot.hasData) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: primaryBlue),
                );
              }

              if (ordersSnapshot.hasError) {
                return _errorState(ordersSnapshot.error.toString());
              }

              final orders = ordersSnapshot.data ?? const [];

              final orderRequestIds =
                  orders.map((o) => o.requestId).toSet();

              // ------------------------------------------------
              // UPCOMING
              // ------------------------------------------------
              //
              // Still-open requests with no order created yet.
              //

              final upcomingRequests = requests.where((r) {
                return r.status.toUpperCase() == 'OPEN' &&
                    !orderRequestIds.contains(r.requestId);
              }).toList();

              // ------------------------------------------------
              // ONGOING
              // ------------------------------------------------

              final ongoingOrders = orders.where((o) {
                return o.status == MarketplaceStatus.confirmed ||
                    o.status == MarketplaceStatus.active;
              }).toList();

              // ------------------------------------------------
              // COMPLETED
              // ------------------------------------------------

              final completedOrders = orders.where((o) {
                return o.status == MarketplaceStatus.orderCompleted;
              }).toList();

              // ------------------------------------------------
              // CANCELLED
              // ------------------------------------------------

              final cancelledOrders = orders.where((o) {
                return o.status == MarketplaceStatus.orderCancelled;
              }).toList();

              final cancelledRequests = requests.where((r) {
                return r.status.toUpperCase() == 'CANCELLED' &&
                    !orderRequestIds.contains(r.requestId);
              }).toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildUpcomingList(upcomingRequests),
                  _buildOrdersList(
                    ongoingOrders,
                    requests,
                    showCancel: true,
                  ),
                  _buildOrdersList(completedOrders, requests),
                  _buildCancelledList(
                    cancelledOrders,
                    cancelledRequests,
                    requests,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // UPCOMING LIST
  // ============================================================

  Widget _buildUpcomingList(List<ServiceRequestModel> requests) {
    if (requests.isEmpty) {
      return _emptyState(
        'No upcoming requests',
        'Requests you create will appear here while you search for professionals or review quotes.',
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _requestCard(request),
        );
      },
    );
  }

  // ============================================================
  // ORDERS LIST (ONGOING / COMPLETED)
  // ============================================================

  Widget _buildOrdersList(
    List<OrderModel> orders,
    List<ServiceRequestModel> allRequests, {
    bool showCancel = false,
  }) {
    if (orders.isEmpty) {
      return _emptyState(
        'No bookings here yet',
        'Bookings will move here as they progress.',
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        final matchingRequest = allRequests
            .where((r) => r.requestId == order.requestId)
            .cast<ServiceRequestModel?>()
            .firstWhere((r) => r != null, orElse: () => null);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _orderCard(
            order,
            matchingRequest,
            showCancel: showCancel,
          ),
        );
      },
    );
  }

  // ============================================================
  // CANCELLED LIST (ORDERS + PRE-ORDER CANCELLED REQUESTS)
  // ============================================================

  Widget _buildCancelledList(
    List<OrderModel> cancelledOrders,
    List<ServiceRequestModel> cancelledRequests,
    List<ServiceRequestModel> allRequests,
  ) {
    if (cancelledOrders.isEmpty && cancelledRequests.isEmpty) {
      return _emptyState(
        'No cancelled bookings',
        'Anything you cancel will appear here.',
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      children: [
        ...cancelledOrders.map((order) {
          final matchingRequest = allRequests
              .where((r) => r.requestId == order.requestId)
              .cast<ServiceRequestModel?>()
              .firstWhere((r) => r != null, orElse: () => null);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _orderCard(order, matchingRequest),
          );
        }),
        ...cancelledRequests.map((request) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _requestCard(request),
          );
        }),
      ],
    );
  }

  // ============================================================
  // REQUEST CARD (UPCOMING / CANCELLED-BEFORE-ORDER)
  // ============================================================

  Widget _requestCard(ServiceRequestModel request) {
    final bool isCancelled =
        request.status.toUpperCase() == 'CANCELLED';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfessionalsScreen(
                request: _toLegacyRequest(request),
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE1E7EF),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      request.requestTypeId.isEmpty
                          ? 'Service Request'
                          : request.requestTypeId,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: _statusChip(
                      isCancelled ? 'Cancelled' : 'Searching',
                      isCancelled
                          ? const Color(0xFFFDECEC)
                          : lightBlue,
                      isCancelled
                          ? const Color(0xFFD92D20)
                          : primaryBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                request.description.trim().isEmpty
                    ? 'No description provided.'
                    : request.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 14),

              const Divider(height: 1, color: Color(0xFFE4E7EC)),

              const SizedBox(height: 12),

              _infoLine(
                Icons.schedule_outlined,
                _formatDate(request.createdAt),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isCancelled)
                    TextButton(
                      onPressed: _cancelling
                          ? null
                          : () => _cancelRequest(request),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFFD92D20),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfessionalsScreen(
                            request: _toLegacyRequest(request),
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: primaryBlue,
                      size: 18,
                    ),
                    label: const Text(
                      "View Details",
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ORDER CARD (ONGOING / COMPLETED / CANCELLED-AFTER-ORDER)
  // ============================================================

  Widget _orderCard(
    OrderModel order,
    ServiceRequestModel? request, {
    bool showCancel = false,
  }) {
    return FutureBuilder<ProfessionalModel?>(
      future:
          ProfessionalFirestoreService.getProfessional(order.professionalId),
      builder: (context, snapshot) {
        final professional = snapshot.data;

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: request == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderStatusScreen(
                          request: _toLegacyRequest(request),
                        ),
                      ),
                    );
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE1E7EF),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.035),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          request == null ||
                                  request.requestTypeId.isEmpty
                              ? 'Service Booking'
                              : request.requestTypeId,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: _orderStatusChip(order.status),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: primaryBlue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              professional?.name ?? 'Professional',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFC107),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    professional == null ||
                                            professional
                                                    .completedJobsCount <=
                                                0
                                        ? 'New professional'
                                        : '${professional.averageRating.toStringAsFixed(1)} • ${professional.completedJobsCount} jobs',
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '₹${order.agreedPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  const Divider(height: 1, color: Color(0xFFE4E7EC)),

                  const SizedBox(height: 12),

                  _infoLine(
                    Icons.schedule_outlined,
                    _formatDate(order.createdAt),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      if (showCancel)
                        TextButton(
                          onPressed: _cancelling
                              ? null
                              : () => _cancelOrder(order),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFFD92D20),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      if (request != null)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderStatusScreen(
                                  request:
                                      _toLegacyRequest(request),
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: primaryBlue,
                            size: 18,
                          ),
                          label: const Text(
                            "View Details",
                            style: TextStyle(
                              color: primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // INFO LINE
  // ============================================================

  Widget _infoLine(
    IconData icon,
    String text, {
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF64748B),
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: textPrimary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS CHIP (GENERIC)
  // ============================================================

  Widget _statusChip(
    String label,
    Color background,
    Color foreground,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // ORDER STATUS CHIP
  // ============================================================

  Widget _orderStatusChip(String status) {
    switch (status) {
      case MarketplaceStatus.confirmed:
        return _statusChip('Accepted', lightBlue, primaryBlue);

      case MarketplaceStatus.active:
        return _statusChip(
          'In Progress',
          const Color(0xFFE8F7EE),
          const Color(0xFF35A853),
        );

      case MarketplaceStatus.orderCompleted:
        return _statusChip(
          'Completed',
          const Color(0xFFE8F7EE),
          const Color(0xFF35A853),
        );

      case MarketplaceStatus.orderCancelled:
        return _statusChip(
          'Cancelled',
          const Color(0xFFFDECEC),
          const Color(0xFFD92D20),
        );

      default:
        return _statusChip(status, lightBlue, primaryBlue);
    }
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "Unable to load your bookings.\n\n$error",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}