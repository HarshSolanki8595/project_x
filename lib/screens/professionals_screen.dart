import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

import '../core/widgets/safety_awareness_carousel.dart';
import '../core/widgets/why_choose_us_carousel.dart';
import '../models/marketplace_status.dart';
import '../models/professional_bid_model.dart';
import '../models/professional_model.dart';
import '../models/service_request.dart';
import '../services/bid_service.dart';
import '../services/order_acceptance_service.dart';
import '../services/professional_firestore_service.dart';
import '../utils/pricing.dart';
import 'main_navigation_screen.dart';
import 'professional_profile_screen.dart';

class ProfessionalsScreen extends StatefulWidget {
  final ServiceRequest request;

  const ProfessionalsScreen({
    super.key,
    required this.request,
  });

  @override
  State<ProfessionalsScreen> createState() =>
      _ProfessionalsScreenState();
}

class _ProfessionalsScreenState
    extends State<ProfessionalsScreen> {
  // ============================================================
  // DESIGN SYSTEM
  // ============================================================

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);
  static const Color background = Color(0xFFF7F8FC);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE1E7EF);

  static const Color starGold = Color(0xFFF5A524);

  static const Color waivedGreen = Color(0xFF15803D);
  static const Color waivedGreenBg = Color(0xFFEAF6EC);

  // ============================================================
  // STATE
  // ============================================================

  bool _acceptingBid = false;

  // ============================================================
  // FEE WAIVER PREVIEW (NEW — 2026-09-27, Harsh's point 11)
  // ============================================================
  //
  // Whether the customer's next paid order would have its Platform
  // Charges + GST waived under the first-orders launch offer (see
  // FIRST_ORDERS_FEE_WAIVER_COUNT in functions/index.js and the
  // matching mirror in utils/pricing.dart). Fetched once here -- a
  // plain read of the customer's own users/{uid} doc, not a Cloud
  // Function call -- purely so the "Accept This Offer" and "Order
  // Confirmed" price previews below reflect the same offer the real
  // payment screen (order_status_screen.dart) already shows. This is
  // a PREVIEW ONLY: the real charge is always decided authoritatively
  // server-side at actual payment time, so a stale/failed read here
  // just falls back to showing the full breakdown -- it can never
  // cause an under- or over-charge.
  //
  bool _feeWaivedPreview = false;

  // ============================================================
  // BID DIAGNOSIS VOICE NOTE PLAYBACK -- added 2026-10-02
  // ============================================================
  //
  // One shared player for every bid card on this screen (the bid
  // list below and the Accept confirmation sheet) -- only one voice
  // note plays at a time. _playingVoiceNoteBidId tracks which bid's
  // note is currently playing (by ProfessionalBidModel.bidId, unique
  // per bid), so each card knows whether to show play or pause.
  //

  final AudioPlayer _bidVoiceNotePlayer = AudioPlayer();
  String? _playingVoiceNoteBidId;

  @override
  void initState() {
    super.initState();
    _loadFeeWaiverPreview();

    _bidVoiceNotePlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _playingVoiceNoteBidId = null;
      });
    });
  }

  @override
  void dispose() {
    _bidVoiceNotePlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleBidVoiceNote(ProfessionalBidModel bid) async {
    final String? url = bid.diagnosisVoiceNoteUrl;
    if (url == null || url.trim().isEmpty) return;

    if (_playingVoiceNoteBidId == bid.bidId) {
      await _bidVoiceNotePlayer.pause();
      setState(() {
        _playingVoiceNoteBidId = null;
      });
    } else {
      await _bidVoiceNotePlayer.play(UrlSource(url));
      setState(() {
        _playingVoiceNoteBidId = bid.bidId;
      });
    }
  }

  // ============================================================
  // DIAGNOSIS VOICE NOTE CHIP -- added 2026-10-02
  // ============================================================
  //
  // Small play/pause control shown alongside the diagnosis message
  // wherever a bid is displayed -- the bid list card
  // (_professionalBidCardContent) and the Accept confirmation sheet
  // (_showAcceptConfirmation). Renders nothing when the bid has no
  // voice note (every bid submitted before this feature existed,
  // and any bid where the professional skipped it -- it's optional).
  //

  Widget _diagnosisVoiceNoteChip(ProfessionalBidModel bid) {
    final String? url = bid.diagnosisVoiceNoteUrl;
    if (url == null || url.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isPlaying = _playingVoiceNoteBidId == bid.bidId;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () => _toggleBidVoiceNote(bid),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                color: primaryBlue,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isPlaying
                    ? 'Playing diagnosis voice note...'
                    : "Play partner's voice note",
                style: const TextStyle(
                  color: primaryBlue,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadFeeWaiverPreview() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final int waiversUsed =
          (snapshot.data()?['platformFeeWaiversUsed'] as num?)?.toInt() ?? 0;

      if (mounted) {
        setState(() {
          _feeWaivedPreview =
              waiversUsed < CustomerPricing.firstOrdersFeeWaiverCount;
        });
      }
    } catch (_) {
      // Leave _feeWaivedPreview at its safe default (false) -- worst
      // case the customer just doesn't see the waiver messaging early,
      // and still sees it correctly on the actual payment screen.
    }
  }

  // ============================================================
  // DISTANCE
  // ============================================================

  double _calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat =
        _degreesToRadians(lat2 - lat1);

    final dLon =
        _degreesToRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) *
            math.sin(dLat / 2) +
        math.cos(
              _degreesToRadians(lat1),
            ) *
            math.cos(
              _degreesToRadians(lat2),
            ) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c =
        2 *
        math.atan2(
          math.sqrt(a),
          math.sqrt(1 - a),
        );

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  // ============================================================
  // ESTIMATED ARRIVAL (NEW — 2026-08-21)
  // ============================================================
  //
  // Distance-based estimate, NOT live GPS tracking. Uses an
  // 18 km/h average speed assumption (realistic for Mumbai city
  // traffic, not open-road speed) plus a fixed 10-minute buffer
  // for the professional to gather tools/park/walk the last mile.
  // Shown as a rounded 10-minute-wide range rather than a single
  // number, so it reads honestly as an estimate rather than a
  // precise promise.
  //

  String _estimatedArrivalText(double? distanceKm) {
    if (distanceKm == null) {
      return 'Arrival time unavailable';
    }

    const double averageSpeedKmh = 18.0;
    const int prepBufferMinutes = 10;

    final double rawMinutes =
        (distanceKm / averageSpeedKmh) * 60 + prepBufferMinutes;

    final int lowerBound =
        ((rawMinutes / 10).floor() * 10).clamp(10, 999);

    final int upperBound = lowerBound + 15;

    if (rawMinutes >= 90) {
      final double lowerHours = lowerBound / 60;
      final double upperHours = upperBound / 60;
      return '~${lowerHours.toStringAsFixed(1)}–${upperHours.toStringAsFixed(1)} hrs away';
    }

    return '~$lowerBound–$upperBound min away';
  }

  // ============================================================
  // ACCEPT BID
  // ============================================================

  Future<void> _acceptBid(
    ProfessionalBidModel bid,
    ProfessionalModel professional,
  ) async {
    if (_acceptingBid) {
      return;
    }

    final shouldAccept =
        await _showAcceptConfirmation(
      bid,
      professional,
    );

    if (!shouldAccept) {
      return;
    }

    setState(() {
      _acceptingBid = true;
    });

    try {
      final order =
          await OrderAcceptanceService.acceptBid(
        requestId: bid.requestId,
        professionalId: bid.professionalId,
      );

      if (!mounted) {
        return;
      }

      await _showOrderCreatedDialog(
        orderId: order.orderId,
        professionalName:
            professional.name,
        price: order.agreedPrice,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst(
              'Bad state: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _acceptingBid = false;
        });
      }
    }
  }

  // ============================================================
  // ACCEPT CONFIRMATION
  // ============================================================

  Future<bool> _showAcceptConfirmation(
    ProfessionalBidModel bid,
    ProfessionalModel professional,
  ) async {
    final result =
        await showModalBottomSheet<bool>(
      context: context,
      // FIX (2026-09-11): isScrollControlled lets this sheet grow past
      // the default ~56% screen-height cap showModalBottomSheet
      // otherwise imposes. Without it, a quote with a warranty note
      // and/or a message from the professional could push the
      // "Accept This Offer" button below that cap -- rendered but
      // clipped below the visible sheet, exactly the bug Harsh
      // reported (button visible in his screenshot, not actually
      // tappable). Paired with the SingleChildScrollView wrap below,
      // which handles the rarer case where content is taller than the
      // full screen too.
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20,
            ),
            child: SingleChildScrollView(
              child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 42,
                  decoration: BoxDecoration(
                    color:
                        Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: primaryBlue,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  professional.name,
                  textAlign:
                      TextAlign.center,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '₹${bid.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 28,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const Text(
                  "Professional's quote",
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                ),

                // --------------------------------------------------
                // FIX (2026-09-06): Harsh's point 7 -- "when the
                // customer sees the quote and accepts the quote it
                // should show what it would have to pay at the end."
                // Before this, the only figure shown here was the
                // professional's raw quote -- the customer had no
                // idea, at the moment they're deciding whether to
                // accept, that Platform Charges + GST would be added
                // on top. See utils/pricing.dart, which mirrors
                // functions/index.js's calculatePlatformCharges()
                // exactly, so this estimate matches to the rupee
                // what recordPayment will actually charge later.
                // --------------------------------------------------
                const SizedBox(height: 14),

                Builder(
                  builder: (context) {
                    final pricing =
                        CustomerPricing.fromAgreedPrice(bid.totalPrice);

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFFE1E7EF),
                        ),
                      ),
                      child: Column(
                        children: [
                          // ----------------------------------------
                          // FEE WAIVER (2026-09-27, Harsh's point 11)
                          // ----------------------------------------
                          //
                          // "When selecting a bid, [the] amount to pay
                          // appears -- it should say when in [the]
                          // offer period that the charges are waived
                          // off... or should not be shown at all."
                          // Same banner + strikethrough treatment as
                          // the real payment screen, so the customer
                          // sees a consistent number here and later.
                          //
                          if (_feeWaivedPreview) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: waivedGreenBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.celebration_rounded,
                                    color: waivedGreen,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Platform fee waived — welcome offer on your first orders',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: waivedGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          _priceBreakdownRow(
                            "Service quote",
                            '₹${pricing.agreedPrice.toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 6),
                          // Percentage deliberately not shown
                          // (2026-09-27, Harsh's point 12) -- the
                          // exact platform commission rate shouldn't
                          // be disclosed anywhere in the app. GST's
                          // rate stays shown below -- it's a
                          // statutory tax rate, not a business figure.
                          _priceBreakdownRow(
                            'Platform Charges',
                            '+ ₹${pricing.platformCharge.toStringAsFixed(0)}',
                            waived: _feeWaivedPreview,
                          ),
                          const SizedBox(height: 6),
                          _priceBreakdownRow(
                            'GST on Platform Charges (18%)',
                            '+ ₹${pricing.gst.toStringAsFixed(0)}',
                            waived: _feeWaivedPreview,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 1,
                            color: const Color(0xFFE1E7EF),
                          ),
                          const SizedBox(height: 10),
                          _priceBreakdownRow(
                            "You'll pay",
                            '₹${(_feeWaivedPreview ? pricing.agreedPrice : pricing.total).toStringAsFixed(0)}',
                            emphasize: true,
                            emphasizeColor: _feeWaivedPreview ? waivedGreen : null,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                if (bid.warranty.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),

                  Text(
                    'Warranty: ${bid.warranty}',
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],

                if (bid.message.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFF8FAFC),
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                    child: Text(
                      bid.message,
                      style:
                          const TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),

                  _diagnosisVoiceNoteChip(bid),
                ],

                const SizedBox(height: 20),

                const Text(
                  'Accepting this offer will create your order and close the other offers for this request.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        true,
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          primaryBlue,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Accept This Offer',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        false,
                      );
                    },
                    child: const Text(
                      'Not Now',
                      style: TextStyle(
                        color: textSecondary,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              ),
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  // ------------------------------------------------------------
  // PRICE BREAKDOWN ROW (2026-09-06, Harsh's point 7)
  // ------------------------------------------------------------

  Widget _priceBreakdownRow(
    String label,
    String value, {
    bool emphasize = false,
    // NEW (2026-09-27, Harsh's point 11): strikes the value through
    // when this row's charge has been waived under the first-orders
    // offer -- same treatment as order_status_screen.dart's payment
    // sheet, so the two screens read consistently.
    bool waived = false,
    // NEW (2026-09-27, Harsh's point 11): lets the emphasized "You'll
    // pay" row turn waivedGreen instead of primaryBlue when waived.
    Color? emphasizeColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasize ? textPrimary : textSecondary,
              fontSize: emphasize ? 14 : 12.5,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: waived
                ? textSecondary
                : (emphasize ? (emphasizeColor ?? primaryBlue) : textPrimary),
            fontSize: emphasize ? 16 : 12.5,
            fontWeight: FontWeight.w700,
            decoration: waived ? TextDecoration.lineThrough : null,
            decorationColor: textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ORDER CREATED DIALOG
  // ============================================================

  Future<void> _showOrderCreatedDialog({
    required String orderId,
    required String professionalName,
    required double price,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),
          title: const Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    Color(0xFFE8F7EE),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 36,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Order Confirmed',
                textAlign:
                    TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Text(
                professionalName,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                  fontSize: 16,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              // --------------------------------------------------
              // FIX (2026-09-06): Harsh's point 7 -- show what the
              // customer actually pays (service quote + Platform
              // Charges + GST), not just the raw professional quote,
              // now that the order is confirmed. See
              // utils/pricing.dart.
              //
              // UPDATED (2026-09-27, Harsh's point 11): reflects the
              // same first-orders fee-waiver preview shown on the
              // "Accept This Offer" sheet just before this, so the
              // number doesn't jump between the two.
              // --------------------------------------------------
              Builder(
                builder: (context) {
                  final pricing = CustomerPricing.fromAgreedPrice(price);
                  final double amountDue =
                      _feeWaivedPreview ? pricing.agreedPrice : pricing.total;

                  return Column(
                    children: [
                      Text(
                        '₹${amountDue.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: _feeWaivedPreview ? waivedGreen : primaryBlue,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Total amount you will pay',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      if (_feeWaivedPreview) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: waivedGreenBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Platform fee waived — welcome offer',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: waivedGreen,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 14),

              Container(
                padding:
                    const EdgeInsets.all(10),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xFFF8FAFC),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Text(
                  'Order ID: $orderId',
                  style:
                      const TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // --------------------------------------------------
                  // ENHANCEMENT (2026-08-24): guaranteed navigation
                  // --------------------------------------------------
                  //
                  // Previously just popped twice, which only worked
                  // reliably if this screen was reached via one
                  // specific path. Since it can also be opened by
                  // tapping a card on the Bookings tab, a plain
                  // double-pop sometimes left the customer on a
                  // stale intermediate screen instead of landing on
                  // Bookings. This clears the entire navigation
                  // stack and lands cleanly on the home tab every
                  // time, regardless of how the customer arrived
                  // here.
                  //
                  // FIXED (2026-09-06, Harsh's point 10): this used
                  // to push MainScreen(initialIndex: 1) -- but
                  // MainScreen is a leftover/orphaned navigation
                  // shell that the rest of the app never actually
                  // uses (the real app is rooted at
                  // MainNavigationScreen, reached from splash/login/
                  // OTP/create-profile). Landing here meant the
                  // customer's "Done" tap dropped them into a
                  // disconnected duplicate shell on the Bookings tab
                  // instead of back into the real app on Home --
                  // which read as "nothing happened" / stuck on the
                  // same screen. Now routes to the real shell,
                  // MainNavigationScreen, which opens on its Home tab
                  // by default.
                  //
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(),
                    ),
                    (route) => false,
                  );
                },
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryBlue,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  // ============================================================
  // BACK NAVIGATION -- close the loop (2026-09-27, Harsh's point 8)
  // ============================================================
  //
  // This screen sits at the end of a long request-creation stack
  // (category -> subcategory -> service details -> date/time ->
  // review -> finding-professionals). Once the request is actually
  // placed and the customer is here choosing a professional, a
  // plain back pop used to retrace that entire stack screen by
  // screen. Now back -- whether the AppBar arrow, the Android
  // system back gesture, or an edge swipe -- always jumps straight
  // to Home instead, same as the "Done" action below already does
  // once an order is confirmed. The request itself isn't lost: it's
  // still visible under Bookings -> Upcoming.
  //
  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestId =
        widget.request.requestId;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goHome(context);
      },
      child: Scaffold(
        backgroundColor: background,

        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,

          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 22,
            ),
            onPressed: () => _goHome(context),
          ),

          title: const Text(
            'Professionals & Quotes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        body: requestId == null ||
                requestId.trim().isEmpty
            ? _buildMissingRequest()
            : _buildMarketplace(requestId),
      ),
    );
  }

  // ============================================================
  // MISSING REQUEST
  // ============================================================

  Widget _buildMissingRequest() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.orange,
              size: 48,
            ),

            const SizedBox(height: 15),

            const Text(
              'Request information is missing.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w700,
                color: textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please create the service request again.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MARKETPLACE
  // ============================================================

  // ============================================================
  // SORT (NEW — 2026-08-23)
  // ============================================================
  //
  // Lets the customer reorder bids on the "Choose the right
  // professional" screen. Sorting by rating/distance needs each
  // bid's professional profile loaded up front (rather than the
  // old per-card lazy FutureBuilder), so _buildMarketplace below
  // now fetches all professionals for the current bid list in
  // parallel before rendering, once, and sorts that combined list.
  //

  _SortOption _sortOption = _SortOption.bestMatch;

  List<_BidWithProfessional> _sortBids(
    List<_BidWithProfessional> items,
    double? requestLat,
    double? requestLng,
  ) {
    final sorted = List<_BidWithProfessional>.from(items);

    switch (_sortOption) {
      case _SortOption.bestMatch:
        break; // Keep natural arrival order.

      case _SortOption.lowestPrice:
        sorted.sort(
          (a, b) => a.bid.totalPrice.compareTo(b.bid.totalPrice),
        );
        break;

      case _SortOption.highestRating:
        sorted.sort(
          (a, b) => (b.professional?.averageRating ?? 0)
              .compareTo(a.professional?.averageRating ?? 0),
        );
        break;

      case _SortOption.nearest:
        sorted.sort((a, b) {
          final distanceA = _distanceFor(a.professional, requestLat, requestLng);
          final distanceB = _distanceFor(b.professional, requestLat, requestLng);
          return distanceA.compareTo(distanceB);
        });
        break;
    }

    return sorted;
  }

  double _distanceFor(
    ProfessionalModel? professional,
    double? requestLat,
    double? requestLng,
  ) {
    if (professional == null || requestLat == null || requestLng == null) {
      return double.infinity;
    }

    return _calculateDistanceKm(
      requestLat,
      requestLng,
      professional.latitude,
      professional.longitude,
    );
  }

  Widget _buildMarketplace(String requestId) {
    return StreamBuilder<List<ProfessionalBidModel>>(
      stream: BidService.watchBidsForRequest(requestId),
      builder: (context, snapshot) {
        final List<ProfessionalBidModel> bids =
            (snapshot.data ?? [])
                .where(
                  (bid) =>
                      bid.status ==
                          MarketplaceStatus.submitted ||
                      bid.status ==
                          MarketplaceStatus.accepted,
                )
                .toList();

        return FutureBuilder<List<_BidWithProfessional>>(
          future: _loadBidsWithProfessionals(bids),
          builder: (context, pairedSnapshot) {
            final paired = pairedSnapshot.data ??
                bids
                    .map((bid) => _BidWithProfessional(bid: bid))
                    .toList();

            final sorted = _sortBids(
              paired,
              widget.request.latitude,
              widget.request.longitude,
            );

            return ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(
                parent:
                    BouncingScrollPhysics(),
              ),
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                14,
                16,
                30,
              ),
              children: [
                // ------------------------------------------------------
                // HEADER
                // ------------------------------------------------------

                const Text(
                  'Choose the right professional',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.15,
                    fontWeight:
                        FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Compare verified professionals, their offers and their experience before deciding.',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 15),

                const WhyChooseUsCarousel(),

                const SizedBox(height: 14),

                // ------------------------------------------------------
                // SAFETY AWARENESS CAROUSEL (NEW — 2026-09-27)
                // ------------------------------------------------------

                const SafetyAwarenessCarousel(),

                const SizedBox(height: 14),

                // ------------------------------------------------------
                // REQUEST INFORMATION
                // ------------------------------------------------------

                _requestInformation(),

                const SizedBox(height: 14),

                // ------------------------------------------------------
                // SORT CONTROL (NEW — 2026-08-23)
                // ------------------------------------------------------

                if (bids.isNotEmpty) ...[
                  _buildSortControl(),
                  const SizedBox(height: 14),
                ],

                // ------------------------------------------------------
                // BIDS
                // ------------------------------------------------------

                if (bids.isEmpty)
                  _buildWaitingForBids()
                else
                  ...sorted.map(
                    (item) => Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: item.professional == null
                          ? _unknownProfessionalCard(item.bid)
                          : _professionalBidCardContent(
                              item.bid,
                              item.professional!,
                            ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // LOAD BIDS WITH PROFESSIONALS (NEW — 2026-08-23)
  // ============================================================
  //
  // Fetches every bid's professional profile in parallel, once,
  // rather than the old per-card lazy FutureBuilder -- needed so
  // the whole list can be sorted by rating/distance, which requires
  // every professional's data to already be available up front.
  //

  Future<List<_BidWithProfessional>> _loadBidsWithProfessionals(
    List<ProfessionalBidModel> bids,
  ) async {
    final results = await Future.wait(
      bids.map(
        (bid) async {
          final professional =
              await ProfessionalFirestoreService.getProfessional(
            bid.professionalId,
          );
          return _BidWithProfessional(bid: bid, professional: professional);
        },
      ),
    );

    return results;
  }

  // ============================================================
  // SORT CONTROL WIDGET (NEW — 2026-08-23)
  // ============================================================

  Widget _buildSortControl() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _SortOption.values.map((option) {
          final selected = _sortOption == option;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(option.label),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _sortOption = option;
                });
              },
              selectedColor: primaryBlue,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : textSecondary,
              ),
              side: BorderSide(
                color: selected ? primaryBlue : borderColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  // ============================================================
  // MARKETPLACE MESSAGE
  // ============================================================

  // ============================================================
  // REQUEST INFORMATION
  // ============================================================

  Widget _requestInformation() {
    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: primaryBlue,
              size: 22,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request',
                  style: TextStyle(
                    color:
                        textSecondary,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  widget.request.issueDescription,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        textPrimary,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            widget.request.requestId!,
            style:
                const TextStyle(
              color: textSecondary,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WAITING FOR BIDS
  // ============================================================

  Widget _buildWaitingForBids() {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        32,
        22,
        32,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              color: lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: primaryBlue,
              size: 34,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Waiting for quotes',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Your request has been sent to matched professionals. Their offers will appear here as they submit them.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 18,
                width: 18,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryBlue,
                ),
              ),

              const SizedBox(width: 8),

              const Text(
                'Checking for new offers...',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFESSIONAL BID CARD
  // ============================================================

  Widget _professionalBidCardContent(
    ProfessionalBidModel bid,
    ProfessionalModel professional,
  ) {
    final distance =
        widget.request.latitude != null &&
                widget.request.longitude !=
                    null
            ? _calculateDistanceKm(
                widget.request.latitude!,
                widget.request.longitude!,
                professional.latitude,
                professional.longitude,
              )
            : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: .025,
            ),
            blurRadius: 10,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------
            // HEADER
            // ----------------------------------------------------

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ----------------------------------------------------
                // ENHANCEMENT (2026-08-23): avatar + name now tappable
                // ----------------------------------------------------
                //
                // Opens the new ProfessionalProfileScreen (work
                // history, ratings, past-work photos, full reviews).
                // Previously this section was purely informational
                // with no tap action at all.
                //
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfessionalProfileScreen(
                          professionalId: professional.professionalId,
                        ),
                      ),
                    );
                  },
                  child: Container(
                  height: 54,
                  width: 54,
                  decoration:
                      BoxDecoration(
                    color: lightBlue,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color:
                        primaryBlue,
                    size: 30,
                  ),
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfessionalProfileScreen(
                                professionalId: professional.professionalId,
                              ),
                            ),
                          );
                        },
                        child: Text(
                        professional.name,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 17,
                          height: 1.15,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              textPrimary,
                        ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ------------------------------------------
                      // ENHANCEMENT (2026-08-21): rating row
                      // ------------------------------------------
                      //
                      // Shows star rating + completed job count
                      // next to the verified badge, so a customer
                      // can compare professionals by track record
                      // alongside price. Falls back to a neutral
                      // "New professional" label when there are no
                      // reviews yet, rather than showing 0 stars.
                      //

                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment:
                            WrapCrossAlignment.center,
                        children: [
                          if (professional.isVerified)
                            _verifiedBadge(),

                          _ratingBadge(professional),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            // ----------------------------------------------------
            // PROFESSIONAL DETAILS
            // ----------------------------------------------------

            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF8FAFC,
                ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: Column(
                children: [
                  _detailRow(
                    Icons.badge_outlined,
                    'Professional ID',
                    professional
                        .professionalId,
                  ),

                  const SizedBox(height: 8),

                  _detailRow(
                    Icons.location_on_outlined,
                    'Distance',
                    distance == null
                        ? 'Location unavailable'
                        : '${distance.toStringAsFixed(1)} km away',
                  ),

                  // ------------------------------------------------
                  // ENHANCEMENT (2026-08-21): estimated arrival
                  // ------------------------------------------------
                  //
                  // Distance-based estimate (see
                  // _estimatedArrivalText above) -- not live GPS
                  // tracking. Uses the same distance fallback
                  // behaviour as the row above it.
                  //

                  const SizedBox(height: 8),

                  _detailRow(
                    Icons.directions_run_rounded,
                    'Estimated Arrival',
                    _estimatedArrivalText(distance),
                  ),

                  const SizedBox(height: 8),

                  _detailRow(
                    Icons.circle,
                    'Availability',
                    professional
                            .isAvailable
                        ? 'Available'
                        : 'Currently unavailable',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ----------------------------------------------------
            // CAPABILITIES
            // ----------------------------------------------------

            if (professional
                .capabilityIds
                .isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    professional.capabilityIds
                        .map(
                          (capability) =>
                              Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  lightBlue,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),
                            child: Text(
                              capability,
                              style:
                                  const TextStyle(
                                color:
                                    primaryBlue,
                                fontSize:
                                    12,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),

            const SizedBox(height: 13),

            // ----------------------------------------------------
            // ACTUAL BID
            // ----------------------------------------------------

            Container(
              padding:
                  const EdgeInsets.fromLTRB(
                13,
                11,
                13,
                11,
              ),
              decoration:
                  BoxDecoration(
                color:
                    lightBlue,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          'Their offer',
                          style:
                              TextStyle(
                            color:
                                textSecondary,
                            fontSize:
                                12,
                            fontWeight:
                                FontWeight
                                    .w500,
                          ),
                        ),

                        const SizedBox(
                            height: 2),

                        Text(
                          '₹${bid.totalPrice.toStringAsFixed(0)}',
                          style:
                              const TextStyle(
                            color:
                                primaryBlue,
                            fontSize:
                                24,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (bid.warranty
                      .trim()
                      .isNotEmpty)
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .end,
                      children: [
                        const Text(
                          'Warranty',
                          style:
                              TextStyle(
                            color:
                                textSecondary,
                            fontSize:
                                12,
                          ),
                        ),

                        const SizedBox(
                            height: 3),

                        Text(
                          bid.warranty,
                          style:
                              const TextStyle(
                            color:
                                textPrimary,
                            fontSize:
                                13,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // ----------------------------------------------------
            // MESSAGE
            // ----------------------------------------------------

            if (bid.message
                .trim()
                .isNotEmpty) ...[
              const SizedBox(height: 10),

              Text(
                bid.message,
                maxLines: 3,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  color:
                      textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              _diagnosisVoiceNoteChip(bid),
            ],

            // ----------------------------------------------------
            // EMPLOYEE ASSIGNED -- Business (GST) registrations
            // only, added 2026-09-04
            // ----------------------------------------------------

            if (bid.employeeName != null &&
                bid.employeeName!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.badge_outlined,
                    size: 15,
                    color: textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Employee assigned: ${bid.employeeName}',
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 13),

            // ----------------------------------------------------
            // CHOOSE
            // ----------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    _acceptingBid
                        ? null
                        : () =>
                            _acceptBid(
                              bid,
                              professional,
                            ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryBlue,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade300,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
                child: _acceptingBid
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Text(
                        'Choose This Professional',
                        style:
                            TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // VERIFIED BADGE
  // ============================================================

  Widget _verifiedBadge() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFE8F7EE),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: const Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            color:
                Color(0xFF35A853),
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            'Verified Professional',
            style: TextStyle(
              color:
                  Color(0xFF35A853),
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RATING BADGE (NEW — 2026-08-21)
  // ============================================================
  //
  // professional.averageRating / completedJobsCount are populated
  // by the onReviewCreated Cloud Function -- see
  // professional_model.dart. A professional with zero completed
  // jobs shows a neutral "New professional" label instead of a
  // 0-star rating, since 0 stars would misleadingly read as a bad
  // rating rather than "no data yet".
  //

  Widget _ratingBadge(ProfessionalModel professional) {
    if (professional.completedJobsCount <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'New professional',
          style: TextStyle(
            color: textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: starGold,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '${professional.averageRating.toStringAsFixed(1)} · ${professional.completedJobsCount} job${professional.completedJobsCount == 1 ? '' : 's'}',
            style: const TextStyle(
              color: Color(0xFF92620A),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: textSecondary,
          size: 16,
        ),

        const SizedBox(width: 8),

        Text(
          '$title:',
          style:
              const TextStyle(
            color: textSecondary,
            fontSize: 12,
          ),
        ),

        const SizedBox(width: 5),

        Expanded(
          child: Text(
            value,
            textAlign:
                TextAlign.right,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              color: textPrimary,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // UNKNOWN PROFESSIONAL
  // ============================================================

  Widget _unknownProfessionalCard(
    ProfessionalBidModel bid,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Text(
        'Professional ${bid.professionalId} submitted a bid of ₹${bid.totalPrice.toStringAsFixed(0)}.',
        style:
            const TextStyle(
          color: textPrimary,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ================================================================
// SORT OPTION (NEW — 2026-08-23)
// ================================================================

enum _SortOption {
  bestMatch,
  lowestPrice,
  highestRating,
  nearest;

  String get label {
    switch (this) {
      case _SortOption.bestMatch:
        return 'Best Match';
      case _SortOption.lowestPrice:
        return 'Lowest Price';
      case _SortOption.highestRating:
        return 'Highest Rated';
      case _SortOption.nearest:
        return 'Nearest';
    }
  }
}

// ================================================================
// BID + PROFESSIONAL PAIR (NEW — 2026-08-23)
// ================================================================
//
// Pairs a bid with its already-fetched professional profile, so
// the bid list can be sorted by professional-level fields (rating,
// distance) without each card doing its own lazy fetch.
//

class _BidWithProfessional {
  final ProfessionalBidModel bid;
  final ProfessionalModel? professional;

  const _BidWithProfessional({
    required this.bid,
    this.professional,
  });
}