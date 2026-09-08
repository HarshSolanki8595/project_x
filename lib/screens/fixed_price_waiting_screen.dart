import 'dart:async';

import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../models/service_request.dart';
import '../services/fixed_price_service.dart';
import '../services/order_service.dart';
import 'order_status_screen.dart';

// ================================================================
// FIXED-PRICE WAITING SCREEN -- Helper Services & Cleaning only
// ================================================================
// Added 2026-09-02. Replaces ProfessionalsScreen (the bid list) for
// FIXED_PRICE requests -- there are no bids to review here, just a
// posted price that any eligible professional can Accept. Streams
// orders/{requestId} (OrderService.watchOrderForRequest, the same
// stream OrderStatusScreen itself uses) and moves on to
// OrderStatusScreen the moment a professional accepts and the order
// document appears, same as the acceptBid path does today.
//
// Also offers the Rapido-style "raise your price" action while
// still waiting, per the confirmed pricing model -- customer sets
// the raise amount themselves, no system-suggested increment.
// ================================================================

class FixedPriceWaitingScreen extends StatefulWidget {
  final ServiceRequest request;

  const FixedPriceWaitingScreen({super.key, required this.request});

  @override
  State<FixedPriceWaitingScreen> createState() =>
      _FixedPriceWaitingScreenState();
}

class _FixedPriceWaitingScreenState extends State<FixedPriceWaitingScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color backgroundColor = Color(0xFFF7F8FC);

  late AnimationController _controller;
  late Animation<double> _animation;

  late double _postedPrice;
  bool _raising = false;
  bool _navigated = false;

  // No backend signal exists for "no eligible professional exists" --
  // the request just waits silently otherwise, which looks stuck or
  // broken with nothing to explain why. After a while on this screen,
  // surface a gentle nudge toward raising the price instead.
  bool _takingLong = false;
  Timer? _longWaitTimer;

  final TextEditingController _raiseController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _postedPrice = widget.request.postedPrice ??
        widget.request.computedFairPrice ??
        0;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _longWaitTimer = Timer(const Duration(seconds: 45), () {
      if (mounted) setState(() => _takingLong = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _raiseController.dispose();
    _longWaitTimer?.cancel();
    super.dispose();
  }

  void _handleOrderCreated() {
    if (_navigated || !mounted) return;
    _navigated = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderStatusScreen(request: widget.request),
      ),
    );
  }

  Future<void> _showRaisePriceSheet() async {
    _raiseController.clear();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1E7EF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Raise your price',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Currently posted at ₹${_postedPrice.toStringAsFixed(0)}. '
                      'Choose how much to add -- there\'s no suggested amount, '
                      'it\'s your call.',
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFDCE3EC)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: Row(
                        children: [
                          const Text(
                            '+ ₹',
                            style: TextStyle(
                              color: darkText,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _raiseController,
                              autofocus: true,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: false,
                              ),
                              style: const TextStyle(
                                color: darkText,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 14),
                                hintText: '50',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _raising
                            ? null
                            : () async {
                                final amount =
                                    double.tryParse(_raiseController.text.trim());

                                if (amount == null || amount <= 0) {
                                  ScaffoldMessenger.of(sheetContext)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Enter an amount greater than ₹0.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setSheetState(() => _raising = true);

                                try {
                                  final newPrice =
                                      await FixedPriceService.raisePrice(
                                    requestId: widget.request.requestId!,
                                    raiseAmount: amount,
                                  );

                                  if (!mounted) return;

                                  setState(() {
                                    _postedPrice = newPrice;
                                    widget.request.postedPrice = newPrice;
                                  });

                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                  }
                                } catch (e) {
                                  if (sheetContext.mounted) {
                                    ScaffoldMessenger.of(sheetContext)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          e.toString().replaceFirst(
                                                'Bad state: ',
                                                '',
                                              ),
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  setSheetState(() => _raising = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _raising
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                            : const Text(
                                'Raise price',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestId = widget.request.requestId;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: StreamBuilder<OrderModel?>(
          stream: requestId == null
              ? Stream<OrderModel?>.empty()
              : OrderService.watchOrderForRequest(requestId),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleOrderCreated();
              });
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  ScaleTransition(
                    scale: _animation,
                    child: Container(
                      height: 118,
                      width: 118,
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withValues(alpha: 0.20),
                            blurRadius: 28,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Finding You a Professional',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your request has been sent to nearby verified '
                    'professionals at your posted price.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Posted price',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${_postedPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: darkText,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  if (_takingLong) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7E6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFCE3A6),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFFB7791F),
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This is taking longer than usual. Raising '
                              'your price can help nearby professionals '
                              'notice your request faster.',
                              style: TextStyle(
                                color: Color(0xFF7A5A15),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  OutlinedButton(
                    onPressed: _showRaisePriceSheet,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryBlue,
                      side: const BorderSide(color: primaryBlue),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'No one accepted yet? Raise your price',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
