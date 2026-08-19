import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/marketplace_status.dart';
import '../models/order_model.dart';
import '../models/professional_model.dart';
import '../models/review_model.dart';
import '../models/service_request.dart';
import '../services/order_service.dart';
import '../services/professional_firestore_service.dart';
import '../services/review_service.dart';
import 'rate_review_screen.dart';

// ================================================================
// ORDER STATUS SCREEN
// ================================================================
//
// Where the customer lands after accepting a bid. Streams the real
// order document (OrderService.watchOrderForRequest) so the status
// here updates live once the professional side starts moving the
// job through ACTIVE / ORDER_COMPLETED. Once completed, shows the
// Rate & Review card at the bottom.
//

class OrderStatusScreen extends StatefulWidget {
  final ServiceRequest request;

  const OrderStatusScreen({
    super.key,
    required this.request,
  });

  @override
  State<OrderStatusScreen> createState() =>
      _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);
  static const Color background = Color(0xFFF7F8FC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE1E7EF);
  static const Color green = Color(0xFF15803D);

  ProfessionalModel? _professional;
  bool _loadingProfessional = true;

  @override
  Widget build(BuildContext context) {
    final requestId = widget.request.requestId;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Order Status',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: requestId == null || requestId.trim().isEmpty
          ? _buildMissingRequest()
          : SafeArea(
              child: StreamBuilder<OrderModel?>(
                stream: OrderService.watchOrderForRequest(requestId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                          ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: primaryBlue,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState(
                      snapshot.error.toString(),
                    );
                  }

                  final order = snapshot.data;

                  if (order == null) {
                    return _buildErrorState(
                      'This order could not be found.',
                    );
                  }

                  _ensureProfessionalLoaded(order.professionalId);

                  return _buildOrder(order);
                },
              ),
            ),
    );
  }

  // ============================================================
  // LOAD PROFESSIONAL (ONCE)
  // ============================================================

  void _ensureProfessionalLoaded(String professionalId) {
    if (_professional != null || !_loadingProfessional) {
      return;
    }

    ProfessionalFirestoreService.getProfessional(professionalId)
        .then((professional) {
      if (!mounted) return;
      setState(() {
        _professional = professional;
        _loadingProfessional = false;
      });
    });
  }

  // ============================================================
  // MISSING REQUEST
  // ============================================================

  Widget _buildMissingRequest() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Text(
          'Order information is missing.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 44,
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load your order',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================

  Widget _buildOrder(OrderModel order) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      children: [
        _buildStatusHeader(order),
        const SizedBox(height: 14),
        _buildStatusTimeline(order),
        const SizedBox(height: 14),
        _buildProfessionalCard(order),
        const SizedBox(height: 14),
        _buildPriceCard(order),
        const SizedBox(height: 14),
        _buildRequestDetailsCard(),
        if (order.status == MarketplaceStatus.orderCompleted) ...[
          const SizedBox(height: 14),
          _buildReviewCard(order),
        ],
      ],
    );
  }

  // ============================================================
  // REVIEW CARD
  // ============================================================
  //
  // Only rendered once the order is ORDER_COMPLETED. Streams
  // reviews/{orderId} -- if it doesn't exist yet, shows the
  // "Rate this service" prompt; once submitted, shows the
  // customer's own rating/comment read-only (a review can't be
  // edited or re-submitted, see firestore.rules).
  //

  Widget _buildReviewCard(OrderModel order) {
    return StreamBuilder<ReviewModel?>(
      stream: ReviewService.watchReviewForOrder(order.orderId),
      builder: (context, snapshot) {
        final review = snapshot.data;

        if (review != null) {
          return _buildSubmittedReviewCard(review);
        }

        return _buildRatePromptCard(order);
      },
    );
  }

  Widget _buildRatePromptCard(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              color: primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Text(
              'How was your experience with this job?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _openRateReview(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Rate',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittedReviewCard(ReviewModel review) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your review',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (index) {
              final filled = index < review.rating;
              return Icon(
                filled ? Icons.star_rounded : Icons.star_border_rounded,
                color: filled ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                size: 22,
              );
            }),
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 13,
                color: textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openRateReview(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RateReviewScreen(
          order: order,
          professional: _professional,
        ),
      ),
    );
  }

  // ============================================================
  // STATUS HEADER
  // ============================================================

  Widget _buildStatusHeader(OrderModel order) {
    final config = _statusConfig(order.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: config.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              config.icon,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  config.subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS TIMELINE
  // ============================================================

  Widget _buildStatusTimeline(OrderModel order) {
    final steps = [
      ('Confirmed', MarketplaceStatus.confirmed),
      ('In Progress', MarketplaceStatus.active),
      ('Completed', MarketplaceStatus.orderCompleted),
    ];

    final currentIndex = order.status == MarketplaceStatus.orderCancelled
        ? -1
        : steps.indexWhere((s) => s.$2 == order.status);

    if (order.status == MarketplaceStatus.orderCancelled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'This order was cancelled.',
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final beforeIndex = index ~/ 2;
            final done = beforeIndex < currentIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: done ? primaryBlue : borderColor,
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isDone = stepIndex < currentIndex;
          final isCurrent = stepIndex == currentIndex;
          final label = steps[stepIndex].$1;

          return Column(
            children: [
              Container(
                height: 26,
                width: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone || isCurrent
                      ? primaryBlue
                      : const Color(0xFFE8EDF5),
                ),
                child: isDone
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(height: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isDone || isCurrent
                      ? textPrimary
                      : textSecondary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ============================================================
  // PROFESSIONAL CARD
  // ============================================================

  Widget _buildProfessionalCard(OrderModel order) {
    if (_loadingProfessional) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: primaryBlue,
          ),
        ),
      );
    }

    final professional = _professional;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professional?.name ?? 'Professional',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                if (professional?.isVerified ?? false) ...[
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.verified_rounded,
                        color: green,
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Verified Professional',
                        style: TextStyle(
                          color: green,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if ((professional?.phoneNumber ?? '').trim().isNotEmpty)
            IconButton(
              onPressed: () => _callProfessional(
                professional!.phoneNumber,
              ),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: lightBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_rounded,
                  color: primaryBlue,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _callProfessional(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);

    final launched = await launchUrl(uri);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open the dialer.'),
        ),
      );
    }
  }

  // ============================================================
  // PRICE CARD
  // ============================================================

  Widget _buildPriceCard(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E2FF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agreed price',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '₹${order.agreedPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Warranty',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                order.warranty.trim().isEmpty
                    ? '—'
                    : order.warranty,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REQUEST DETAILS CARD
  // ============================================================

  Widget _buildRequestDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _detailRow(
            Icons.receipt_long_outlined,
            'Description',
            widget.request.issueDescription.trim().isEmpty
                ? 'No description provided.'
                : widget.request.issueDescription,
          ),
          const SizedBox(height: 8),
          _detailRow(
            Icons.location_on_outlined,
            'Address',
            widget.request.address?.trim().isNotEmpty == true
                ? widget.request.address!
                : 'Not provided',
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS CONFIG
  // ============================================================

  _StatusConfig _statusConfig(String status) {
    switch (status) {
      case MarketplaceStatus.active:
        return const _StatusConfig(
          title: 'Job In Progress',
          subtitle:
              'Your professional is working on this request.',
          color: Color(0xFFB45309),
          icon: Icons.build_circle_outlined,
        );
      case MarketplaceStatus.orderCompleted:
        return const _StatusConfig(
          title: 'Job Completed',
          subtitle: 'Rate your experience once your review is ready.',
          color: green,
          icon: Icons.check_circle_outline_rounded,
        );
      case MarketplaceStatus.orderCancelled:
        return const _StatusConfig(
          title: 'Order Cancelled',
          subtitle: 'This order was cancelled.',
          color: Colors.red,
          icon: Icons.cancel_outlined,
        );
      case MarketplaceStatus.confirmed:
      default:
        return const _StatusConfig(
          title: 'Order Confirmed',
          subtitle:
              'Your professional will begin the job soon.',
          color: primaryBlue,
          icon: Icons.event_available_outlined,
        );
    }
  }
}

class _StatusConfig {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _StatusConfig({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}