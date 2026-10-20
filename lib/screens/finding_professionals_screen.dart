import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/widgets/outstanding_fee_prompt.dart';
import '../models/service_request.dart';
import '../models/service_request_model.dart';
import '../services/request_classifier.dart';
import '../services/request_service.dart';
import 'fixed_price_waiting_screen.dart';
import 'professionals_screen.dart';

class FindingProfessionalsScreen extends StatefulWidget {
  final ServiceRequest request;

  const FindingProfessionalsScreen({
    super.key,
    required this.request,
  });

  @override
  State<FindingProfessionalsScreen> createState() =>
      _FindingProfessionalsScreenState();
}

class _FindingProfessionalsScreenState
    extends State<FindingProfessionalsScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue =
      Color(0xFF1557FF);

  static const Color backgroundColor =
      Color(0xFFF7F8FC);

  late AnimationController _controller;
  late Animation<double> _animation;

  Timer? _navigationTimer;

  bool _requestProcessed = false;
  String? _processingError;

  // Quick Services (Cleaning + Helper Services) post a fixed price up
  // front instead of collecting bids -- this screen is shared with the
  // bidding flow, so a couple of lines of copy need to differ for that
  // case rather than talking about "quotations" that will never arrive.
  bool get _isFixedPrice => widget.request.pricingType == 'FIXED_PRICE';

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation =
        Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _processMarketplaceRequest();
  }

  // ============================================================
  // PROCESS REAL MARKETPLACE REQUEST
  // ============================================================

  Future<void>
      _processMarketplaceRequest() async {
    try {
      // --------------------------------------------------------
      // DEBUG — INSPECT REQUEST BEFORE PROCESSING
      // --------------------------------------------------------

      debugPrint(
        '========== PROJECT X REQUEST DEBUG ==========',
      );

      debugPrint(
        'Issue Description: '
        '${widget.request.issueDescription}',
      );

      debugPrint(
        'Address: '
        '${widget.request.address}',
      );

      debugPrint(
        'Latitude: '
        '${widget.request.latitude}',
      );

      debugPrint(
        'Longitude: '
        '${widget.request.longitude}',
      );

      debugPrint(
        'Customer ID: '
        '${widget.request.customerId}',
      );

      debugPrint(
        'Urgency: '
        '${widget.request.urgency}',
      );

      debugPrint(
        '==============================================',
      );

      // --------------------------------------------------------
      // 1. CHECK LOCATION
      // --------------------------------------------------------

      if (widget.request.latitude ==
              null ||
          widget.request.longitude ==
              null) {
        throw StateError(
          'Customer location is required before matching '
          'partners.',
        );
      }

      // --------------------------------------------------------
      // 2. CHECK CUSTOMER ID
      // --------------------------------------------------------

      if (widget.request.customerId ==
              null ||
          widget.request.customerId!
              .trim()
              .isEmpty) {
        throw StateError(
          'Customer authentication is required before creating '
          'a service request.',
        );
      }

      // --------------------------------------------------------
      // 2b. UNPAID CANCELLATION / NO-SHOW FEE (2026-10-07)
      // --------------------------------------------------------
      //
      // A customer who owes a fee can't place new requests (Firestore
      // rules refuse the write too). Check up front, so nothing is
      // uploaded for a request that can't be saved, and show the
      // Pay prompt instead.
      //

      final OutstandingFeeInfo? owedFee = await OutstandingFeePrompt.lookup();

      if (owedFee != null) {
        if (!mounted) {
          return;
        }

        await OutstandingFeePrompt.show(
          context,
          amountOwed: owedFee.amount,
          orderId: owedFee.orderId,
        );

        if (!mounted) {
          return;
        }

        Navigator.of(context).pop();
        return;
      }

      // --------------------------------------------------------
      // 3. DETERMINE CAPABILITY ID
      // --------------------------------------------------------
      //
      // If the customer picked a category/subcategory, the request
      // already carries the real capabilityId (same id professionals
      // register under). Only fall back to free-text classification
      // for the "Ask Habio" flow, which has no fixed subcategory.
      //

      String? requestTypeId = widget.request.requestTypeId;
      String? capabilityId = widget.request.capabilityId;
      String? categoryId = widget.request.categoryId;

      if (capabilityId == null || capabilityId.trim().isEmpty) {
        final classification = RequestClassifier.classify(
          widget.request.issueDescription,
        );

        if (classification == null) {
          throw StateError(
            'Habio could not understand the service request.',
          );
        }

        requestTypeId = classification.requestTypeId;
        capabilityId = classification.capabilityId;
        categoryId = classification.categoryId;
      }

      // --------------------------------------------------------
      // 4. SAVE REQUEST TO FIRESTORE
      // --------------------------------------------------------

      final ServiceRequestModel savedRequest =
          await RequestService.createRequest(
        customerId: widget.request.customerId!,
        requestTypeId: requestTypeId!,
        capabilityId: capabilityId,
        categoryId: categoryId ?? '',
        description: widget.request.issueDescription,
        latitude: widget.request.latitude!,
        longitude: widget.request.longitude!,
        urgency: widget.request.urgency,
        // The real urgency flag -- see ServiceRequestModel.isEmergency
        // and request_repository.dart for the rest of this fix
        // (2026-09-27). Previously dropped here entirely, which is
        // why "Need urgent help?" never reached the professional app.
        isEmergency: widget.request.isEmergency,
        // Display/schedule fields -- previously dropped here, which
        // is why the professional app's request card had nothing
        // beyond the generic "Service Request" title and posted
        // price. See ServiceRequestModel / RequestService /
        // RequestRepository for the rest of this fix.
        categoryName: widget.request.categoryName,
        subCategoryName: widget.request.subCategoryName,
        address: widget.request.address,
        preferredDate: widget.request.preferredDate,
        preferredTimeSlot: widget.request.preferredTimeSlot,
        // Fixed-price fields (Helper Services + Cleaning only) --
        // pricingType defaults to 'BID' on ServiceRequest itself,
        // so every other category's request is written exactly as
        // before. See fixed_price_service_config.dart.
        pricingType: widget.request.pricingType,
        fixedPriceAnswers: widget.request.fixedPriceAnswers,
        numberOfServiceRecipients: widget.request.numberOfServiceRecipients,
        serviceDurationHours: widget.request.serviceDurationHours,
        computedFairPrice: widget.request.computedFairPrice,
        postedPrice: widget.request.postedPrice,
        // Material sourcing (non-Quick-Service requests only) --
        // see ServiceRequestScreen. All null for FIXED_PRICE
        // requests, which never touch that screen.
        customerProvidesMaterial: widget.request.customerProvidesMaterial,
        materialGrade: widget.request.materialGrade,
        materialBrandPreference: widget.request.materialBrandPreference,
        // Appliances/Automobile narrower matching (2026-10-02) -- see
        // SubCategory.matchGroup (lib/models/subcategory.dart) and
        // ServiceRequestScreen for the full explanation.
        matchGroup: widget.request.matchGroup,
        vehicleType: widget.request.vehicleType,
        // Media (added 2026-10-02) -- uploaded to Firebase Storage
        // inside RequestService.createRequest once the real
        // requestId exists. See ServiceRequestMediaService and
        // ServiceRequestModel.photoUrls/videoUrl/voiceNoteUrl.
        photos: widget.request.photos,
        video: widget.request.video,
        voiceNote: widget.request.voiceNote,
      );

      // --------------------------------------------------------
      // 5. COPY MARKETPLACE IDENTIFIERS BACK
      // --------------------------------------------------------

      widget.request.requestId = savedRequest.requestId;
      widget.request.requestTypeId = savedRequest.requestTypeId;
      widget.request.capabilityId = savedRequest.capabilityId;
      widget.request.categoryId = savedRequest.categoryId;
      widget.request.customerId = savedRequest.customerId;

      // --------------------------------------------------------
      // 6. MATCHING HAPPENS SERVER-SIDE
      // --------------------------------------------------------
      //
      // A Cloud Function (matchServiceRequest, triggered on
      // service_requests create) does the professional lookup and
      // writes opportunity docs under
      // professional_opportunities/{uid}/requests/{requestId}.
      //
      // It has to run server-side because Firestore rules correctly
      // forbid a customer client from listing the `professionals`
      // collection or writing into another user's opportunity tree.
      // There's nothing more for this screen to do here — the
      // professional app will pick the opportunity up in realtime
      // once the function finishes (usually well under a second).
      //

      // --------------------------------------------------------
      // 7. LOG
      // --------------------------------------------------------

      debugPrint(
        '========== HABIO REQUEST PROCESSED ==========',
      );

      debugPrint('Request ID: ${savedRequest.requestId}');
      debugPrint('Request Type ID: ${savedRequest.requestTypeId}');
      debugPrint('Capability ID: ${savedRequest.capabilityId}');
      debugPrint('Customer ID: ${savedRequest.customerId}');

      // --------------------------------------------------------
      // 8. MARK PROCESSING COMPLETE
      // --------------------------------------------------------

      if (!mounted) {
        return;
      }

      setState(() {
        _requestProcessed = true;
        _processingError = null;
      });

      _navigationTimer = Timer(
        const Duration(seconds: 3),
        _openProfessionalsScreen,
      );
    } catch (error) {
      debugPrint(
        'PROJECT X MARKETPLACE REQUEST ERROR: $error',
      );

      if (!mounted) {
        return;
      }

      // Firestore refused the request itself (permission-denied): the
      // customer's account is suspended, or the category / pricing flow
      // has been paused by an admin. Say so, and go back, instead of
      // carrying on to a bid screen for a request that was never saved.
      if (error is FirebaseException && error.code == 'permission-denied') {
        await _handleRequestRefused();
        return;
      }

      setState(() {
        _processingError =
            error.toString();
      });

      _navigationTimer = Timer(
        const Duration(seconds: 3),
        _openProfessionalsScreen,
      );
    }
  }

  // ============================================================
  // REQUEST REFUSED (suspended account / paused service)
  // ============================================================

  Future<void> _handleRequestRefused() async {
    // An unpaid cancellation / no-show fee is refused by the same rule --
    // show the Pay prompt for that rather than the generic message.
    final OutstandingFeeInfo? owedFee = await OutstandingFeePrompt.lookup();

    if (owedFee != null) {
      if (!mounted) {
        return;
      }

      await OutstandingFeePrompt.show(
        context,
        amountOwed: owedFee.amount,
        orderId: owedFee.orderId,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      return;
    }

    var suspended = false;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        suspended = doc.data()?['isSuspended'] == true;
      }
    } catch (_) {
      // Fall through to the general message below.
    }

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(suspended ? 'Account on hold' : 'Service unavailable'),
        content: Text(
          suspended
              ? 'Your account is on hold, so new requests can\'t be placed '
                  'right now. Please contact Habio Support from the Help '
                  'section and we\'ll sort it out.'
              : 'We can\'t place this request right now. This service may be '
                  'paused for a short while. Please try again later or pick '
                  'another service.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  // ============================================================
  // OPEN PROFESSIONALS SCREEN
  // ============================================================

  void _openProfessionalsScreen() {
    if (!mounted) {
      return;
    }

    // Fixed-price requests (Helper Services + Cleaning) have no bids
    // to review -- any eligible professional can Accept the posted
    // price directly, so this goes to the waiting screen instead of
    // the bid list. Every other category is unaffected.
    final bool isFixedPrice = widget.request.pricingType == 'FIXED_PRICE';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isFixedPrice
            ? FixedPriceWaitingScreen(request: widget.request)
            : ProfessionalsScreen(request: widget.request),
      ),
    );
  }

  // ============================================================
  // STATUS ITEM
  // ============================================================

  Widget _statusItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration:
                BoxDecoration(
              color:
                  iconColor.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Colors.black87,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style:
                      TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons
                .check_circle_rounded,
            color: _requestProcessed
                ? Colors.green
                : Colors.grey.shade400,
            size: 21,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          backgroundColor,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            22,
            28,
            22,
            24,
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ------------------------------------------------
              // SEARCH ANIMATION
              // ------------------------------------------------

              ScaleTransition(
                scale: _animation,
                child: Container(
                  height: 118,
                  width: 118,
                  decoration:
                      BoxDecoration(
                    color:
                        primaryBlue,
                    shape:
                        BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            primaryBlue.withValues(
                          alpha: 0.20,
                        ),
                        blurRadius: 28,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child:
                      const Icon(
                    Icons
                        .search_rounded,
                    color:
                        Colors.white,
                    size: 54,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ------------------------------------------------
              // TITLE
              // ------------------------------------------------

              const Text(
                'Finding Partners',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Searching nearby verified partners\n'
                'who can help with your request.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      Colors.grey,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              // ------------------------------------------------
              // PROGRESS
              // ------------------------------------------------

              Container(
                width:
                    double.infinity,
                height: 7,
                clipBehavior:
                    Clip.antiAlias,
                decoration:
                    BoxDecoration(
                  color:
                      Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child:
                    const LinearProgressIndicator(
                  backgroundColor:
                      Colors.transparent,
                  valueColor:
                      AlwaysStoppedAnimation<
                          Color>(
                    primaryBlue,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ------------------------------------------------
              // STATUS CARD
              // ------------------------------------------------

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.fromLTRB(
                  17,
                  12,
                  17,
                  12,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  border: Border.all(
                    color:
                        Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    _statusItem(
                      icon:
                          Icons
                              .verified_rounded,
                      iconColor:
                          Colors.green,
                      title:
                          'Verified Partners Only',
                      subtitle:
                          'Matching trusted partners',
                    ),

                    Divider(
                      height: 1,
                      color:
                          Colors.grey.shade200,
                    ),

                    _statusItem(
                      icon:
                          Icons
                              .location_on_rounded,
                      iconColor:
                          primaryBlue,
                      title:
                          'Checking Your Location',
                      subtitle:
                          'Finding partners nearby',
                    ),

                    Divider(
                      height: 1,
                      color:
                          Colors.grey.shade200,
                    ),

                    _statusItem(
                      icon:
                          Icons
                              .request_quote_rounded,
                      iconColor:
                          Colors.orange,
                      title:
                          'Request Sent',
                      subtitle: _isFixedPrice
                          ? 'Waiting for a partner to accept'
                          : 'Waiting for quotations',
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // ------------------------------------------------
              // MARKETPLACE MESSAGE
              // ------------------------------------------------

              Text(
                _isFixedPrice
                    ? 'Your price is already set.\n'
                        'A nearby partner just needs to accept it.'
                    : 'Partners will decide their price.\n'
                        'You decide which offer is right for you.',
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      Colors.grey,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}