import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/marketplace_status.dart';
import '../models/professional_bid_model.dart';
import '../models/professional_model.dart';
import '../models/service_request.dart';
import '../services/bid_service.dart';
import '../services/order_acceptance_service.dart';
import '../services/professional_firestore_service.dart';

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

  // ============================================================
  // STATE
  // ============================================================

  bool _acceptingBid = false;

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
                    fontSize: 21,
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
        );
      },
    );

    return result ?? false;
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

              Text(
                '₹${price.toStringAsFixed(0)}',
                style:
                    const TextStyle(
                  color: primaryBlue,
                  fontSize: 24,
                  fontWeight:
                      FontWeight.w800,
                ),
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
                  Navigator.pop(
                    context,
                  );
                  Navigator.pop(
                    context,
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

  @override
  Widget build(BuildContext context) {
    final requestId =
        widget.request.requestId;

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,

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
                fontSize: 27,
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

            _marketplaceMessage(),

            const SizedBox(height: 14),

            // ------------------------------------------------------
            // REQUEST INFORMATION
            // ------------------------------------------------------

            _requestInformation(),

            const SizedBox(height: 14),

            // ------------------------------------------------------
            // BIDS
            // ------------------------------------------------------

            if (bids.isEmpty)
              _buildWaitingForBids()
            else
              ...bids.map(
                (bid) => Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child:
                      _professionalBidCard(
                    bid,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MARKETPLACE MESSAGE
  // ============================================================

  Widget _marketplaceMessage() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFD7E2FF),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.compare_arrows_rounded,
            color: primaryBlue,
            size: 24,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Professionals decide their price. You decide which offer gives you the best value.',
              style: TextStyle(
                color:
                    Color(0xFF475569),
                fontSize: 13,
                height: 1.35,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                    fontSize: 11,
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
              fontSize: 10,
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

  Widget _professionalBidCard(
    ProfessionalBidModel bid,
  ) {
    return FutureBuilder<ProfessionalModel?>(
      future: ProfessionalFirestoreService.getProfessional(
        bid.professionalId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
                ConnectionState.waiting &&
            !snapshot.hasData) {
          return Container(
            height: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
              ),
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

        final professional = snapshot.data;

        if (professional == null) {
          return _unknownProfessionalCard(bid);
        }

        return _professionalBidCardContent(
          bid,
          professional,
        );
      },
    );
  }

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
                Container(
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

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
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
                                    10.5,
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
                                11,
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
                                25,
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
                                10,
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
              fontSize: 11,
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
            fontSize: 11,
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
              fontSize: 11,
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
            fontSize: 11.5,
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
              fontSize: 11.5,
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