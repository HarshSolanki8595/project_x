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
import 'professionals_screen.dart';
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
// PAYMENT (NEW — 2026-08-21): shows a "Pay Now" prompt whenever the
// order isn't cancelled and hasn't been paid yet, and a "Paid"
// confirmation once it has. This is Stage 3 of the payment/wallet
// build -- a MOCKED/SIMULATED payment (no real Razorpay yet). Tapping
// "Pay Now" opens a bottom sheet with the price breakdown (agreed
// price + Platform Charges + GST) and a single confirm action that
// calls the recordPayment Cloud Function.
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
  bool _withdrawing = false;

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
    final bool showPaymentSection =
        order.status != MarketplaceStatus.orderCancelled;

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
        if (showPaymentSection) ...[
          const SizedBox(height: 14),
          _buildPaymentCard(order),
        ],
        const SizedBox(height: 14),
        _buildRequestDetailsCard(),
        // ------------------------------------------------------
        // WITHDRAW vs. PAY-TO-CANCEL (REVISED 2026-09-01)
        // ------------------------------------------------------
        //
        // A booking is NOT actually cancelled until the ₹150 fee is
        // paid (see cancelOrder/payCancellationFee in index.js) --
        // so as long as the order is still CONFIRMED/ACTIVE, one of
        // these two cards shows, never both: the "Need to withdraw?"
        // entry point if no cancellation has been requested yet, or
        // the pending-fee card (from _buildCancellationFeeCard,
        // unpaid state) if one has and is just waiting on payment.
        // cancellationFee/cancellationFeeStatus now show up on a
        // still-CONFIRMED/ACTIVE order, not only a cancelled one --
        // that's the whole point of the fix.
        //
        if (order.status == MarketplaceStatus.confirmed ||
            order.status == MarketplaceStatus.active) ...[
          const SizedBox(height: 14),
          if (order.cancellationFee > 0 && !order.isCancellationFeePaid)
            _buildCancellationFeeCard(order)
          else
            _buildWithdrawCard(order),
        ],
        if (order.status == MarketplaceStatus.orderCancelled &&
            order.isWithdrawnByProfessional) ...[
          const SizedBox(height: 14),
          _buildProfessionalWithdrewCard(),
        ],
        if (order.status == MarketplaceStatus.orderCancelled &&
            order.cancellationFee > 0) ...[
          const SizedBox(height: 14),
          _buildCancellationFeeCard(order),
        ],
        if (order.status == MarketplaceStatus.orderCompleted) ...[
          const SizedBox(height: 14),
          _buildReviewCard(order),
        ],
      ],
    );
  }

  // ============================================================
  // WITHDRAW FROM BOOKING (NEW — 2026-08-29)
  // ============================================================
  //
  // Lets a customer back out of an already-confirmed/active order
  // from the detail screen, not just from the Bookings list. Reuses
  // the existing cancelOrder Cloud Function (OrderService.cancelOrder)
  // -- no new backend action, just a second, more visible entry
  // point to it, with the flat ₹150 fee clearly disclosed before the
  // customer confirms.
  //

  Widget _buildWithdrawCard(OrderModel order) {
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
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Need to withdraw?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'You can withdraw from this booking. A flat ₹150 cancellation fee applies once a professional has been confirmed.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _withdrawing ? null : () => _confirmWithdraw(order),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Color(0xFFE5B7B7)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: _withdrawing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : const Text(
                      'Withdraw from Booking',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFESSIONAL WITHDREW CARD (NEW — 2026-08-30)
  // ============================================================
  //
  // Shown instead of the cancellation-fee card whenever the
  // PROFESSIONAL is the one who backed out of an already-confirmed
  // job (professionalWithdrawOrder in index.js sets
  // cancelledBy: 'PROFESSIONAL') -- the ₹150 fee in that case is
  // auto-deducted from the professional's own wallet, so this
  // customer is never asked to pay anything. Instead, "Find New
  // Professional" reopens the same request in ProfessionalsScreen,
  // reusing widget.request rather than re-fetching it, since the
  // matching Cloud Function already created fresh opportunities for
  // other eligible professionals server-side.
  //

  Widget _buildProfessionalWithdrewCard() {
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
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Your professional withdrew',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Don't worry — we're finding you a new professional for "
            "this job at no extra cost to you.",
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) =>
                        ProfessionalsScreen(request: widget.request),
                  ),
                );
              },
              child: const Text(
                'Find New Professional',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CANCELLATION FEE CARD (2026-08-30)
  // ============================================================
  //
  // Originally just a passive "a fee was applied" banner -- Harsh
  // pointed out withdrawing looked "not fully cancelled" because
  // there was no actual screen to pay the ₹150 to the company.
  // Rebuilt to match the same Pay Now / Paid pattern already used
  // for the main job payment above (_buildPayNowCard/_buildPaidCard),
  // just for the flat cancellation fee instead of the job price.
  //

  Widget _buildCancellationFeeCard(OrderModel order) {
    if (order.isCancellationFeePaid) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F8EE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: green, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cancellation fee of ₹${order.cancellationFee.toStringAsFixed(0)} paid.',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

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
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.red,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Cancellation fee pending',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'A flat ₹${order.cancellationFee.toStringAsFixed(0)} cancellation fee applies. Your booking stays active until it\'s paid — pay it to complete the cancellation.',
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _openCancellationFeeSheet(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(
                'Pay ₹${order.cancellationFee.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCancellationFeeSheet(OrderModel order) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _CancellationFeeSheet(order: order);
      },
    );
  }

  Future<void> _confirmWithdraw(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Withdraw from booking?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          content: const Text(
            'A flat ₹150 cancellation fee applies. Your booking stays active — the professional isn\'t notified and nothing changes — until you pay it on the next screen.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Keep Booking',
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Withdraw',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _withdrawing = true);

    try {
      await OrderService.cancelOrder(order.orderId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Bad state: ', ''),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _withdrawing = false);
      }
    }
  }

  // ============================================================
  // PAYMENT CARD (NEW — 2026-08-21)
  // ============================================================
  //
  // Two states: not yet paid (prompt + "Pay Now" button opening the
  // bottom sheet below) or already paid (green confirmation summary,
  // read-only). MOCKED payment -- no real Razorpay integration.
  //

  Widget _buildPaymentCard(OrderModel order) {
    if (order.isPaid) {
      return _buildPaidCard(order);
    }

    return _buildPayNowCard(order);
  }

  Widget _buildPayNowCard(OrderModel order) {
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
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Payment pending',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Pay securely in the app whenever you\'re ready — no need to wait for the job to finish.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _openPaymentSheet(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaidCard(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8EE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: green,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Text(
                'Paid',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: green,
                ),
              ),
              const Spacer(),
              Text(
                '₹${order.customerTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _paymentBreakdownRow(
            'Service amount',
            order.agreedPrice,
            textSecondary,
          ),
          const SizedBox(height: 5),
          _paymentBreakdownRow(
            'Platform charges',
            order.customerPlatformCharge,
            textSecondary,
          ),
          const SizedBox(height: 5),
          _paymentBreakdownRow(
            'GST on platform charges',
            order.customerGst,
            textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _paymentBreakdownRow(String label, double amount, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12.5, color: color),
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT SHEET (NEW — 2026-08-21)
  // ============================================================

  Future<void> _openPaymentSheet(OrderModel order) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _PaymentSheet(order: order);
      },
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
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: const Text(
                'How was your experience with this job?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  height: 1.35,
                ),
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
              // Overrides the app-wide ElevatedButtonTheme default of
              // minimumSize: Size(double.infinity, 62) (see app_theme.dart).
              // That default is fine for full-width buttons wrapped in their
              // own SizedBox, but this button sits loose inside a Row, which
              // gives non-flex children unbounded width during layout --
              // combined with an infinite minimumSize that threw
              // "BoxConstraints forces an infinite width" and corrupted this
              // Row's whole layout (including the text next to it).
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                if ((professional?.phoneNumber ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    professional!.phoneNumber,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
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

// ================================================================
// PAYMENT SHEET (NEW — 2026-08-21)
// ================================================================
//
// Bottom sheet showing the price breakdown and a mocked payment
// method selector (UPI / Card -- purely visual, no real gateway).
// A single "Pay ₹X" button calls OrderService.payForOrder, which
// invokes the recordPayment Cloud Function.
// ================================================================

class _PaymentSheet extends StatefulWidget {
  final OrderModel order;

  const _PaymentSheet({required this.order});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  String _method = 'UPI';
  bool _isPaying = false;

  // Same 9.5% Platform Charges + 18% GST math used server-side --
  // shown here purely for display before the customer confirms.
  // The Cloud Function recomputes and writes the authoritative
  // values; this is not itself a source of truth.
  double get _platformCharge => widget.order.agreedPrice * 0.095;
  double get _gst => _platformCharge * 0.18;
  double get _total => widget.order.agreedPrice + _platformCharge + _gst;

  Future<void> _confirmPayment() async {
    if (_isPaying) return;

    setState(() => _isPaying = true);

    try {
      await OrderService.payForOrder(widget.order.orderId);

      if (mounted) {
        Navigator.pop(context);
      }
    } on StateError catch (e) {
      if (mounted) {
        setState(() => _isPaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isPaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to process payment right now.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const Text(
                'Review & Pay',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              _row('Service amount', widget.order.agreedPrice),
              const SizedBox(height: 8),
              _row('Platform charges (9.5%)', _platformCharge),
              const SizedBox(height: 8),
              _row('GST on platform charges (18%)', _gst),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFE4E7EC)),
              ),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total to pay',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '₹${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Text(
                'Payment method',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _methodOption(
                      label: 'UPI',
                      icon: Icons.qr_code_rounded,
                      value: 'UPI',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _methodOption(
                      label: 'Card',
                      icon: Icons.credit_card_rounded,
                      value: 'Card',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isPaying ? null : _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isPaying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Pay ₹${_total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, double amount) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: textSecondary),
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _methodOption({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final bool selected = _method == value;

    return GestureDetector(
      onTap: () => setState(() => _method = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF3FF) : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? primaryBlue : const Color(0xFFE1E7EF),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? primaryBlue : textSecondary,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? primaryBlue : textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// CANCELLATION FEE SHEET (NEW — 2026-08-30)
// ================================================================
//
// Same mocked payment-method-selector pattern as _PaymentSheet
// above, but for the flat ₹150 cancellation fee instead of the job
// price breakdown. Calls OrderService.payCancellationFee, which
// invokes the payCancellationFee Cloud Function.
// ================================================================

class _CancellationFeeSheet extends StatefulWidget {
  final OrderModel order;

  const _CancellationFeeSheet({required this.order});

  @override
  State<_CancellationFeeSheet> createState() => _CancellationFeeSheetState();
}

class _CancellationFeeSheetState extends State<_CancellationFeeSheet> {
  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  String _method = 'UPI';
  bool _isPaying = false;

  Future<void> _confirmPayment() async {
    if (_isPaying) return;

    setState(() => _isPaying = true);

    try {
      await OrderService.payCancellationFee(widget.order.orderId);

      if (mounted) {
        Navigator.pop(context);
      }
    } on StateError catch (e) {
      if (mounted) {
        setState(() => _isPaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isPaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to process payment right now.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fee = widget.order.cancellationFee;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const Text(
                'Pay Cancellation Fee',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Cancellation fee',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  ),
                  Text(
                    '₹${fee.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFE4E7EC)),
              ),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total to pay',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '₹${fee.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Text(
                'Payment method',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _methodOption(
                      label: 'UPI',
                      icon: Icons.qr_code_rounded,
                      value: 'UPI',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _methodOption(
                      label: 'Card',
                      icon: Icons.credit_card_rounded,
                      value: 'Card',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isPaying ? null : _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isPaying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Pay ₹${fee.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _methodOption({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final bool selected = _method == value;

    return GestureDetector(
      onTap: () => setState(() => _method = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF3FF) : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? primaryBlue : const Color(0xFFE1E7EF),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? primaryBlue : textSecondary,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? primaryBlue : textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}