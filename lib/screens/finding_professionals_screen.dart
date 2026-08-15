import 'dart:async';

import 'package:flutter/material.dart';

import '../models/service_request.dart';
import '../services/marketplace_request_service.dart';
import '../services/request_processing_service.dart';
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
      // 1. CHECK LOCATION
      // --------------------------------------------------------

      if (widget.request.latitude ==
              null ||
          widget.request.longitude ==
              null) {
        throw StateError(
          'Customer location is required before matching '
          'professionals.',
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
      // 3. PROCESS CUSTOMER REQUEST
      // --------------------------------------------------------

      final MatchingResult? result =
          await RequestProcessingService
              .processRequest(
        customerId:
            widget.request.customerId!,
        customerText:
            widget.request.issueDescription,
        latitude:
            widget.request.latitude!,
        longitude:
            widget.request.longitude!,
        urgency:
            widget.request.urgency,
      );

      // --------------------------------------------------------
      // 4. REQUEST COULD NOT BE CLASSIFIED
      // --------------------------------------------------------

      if (result == null) {
        throw StateError(
          'Project X could not understand the service request.',
        );
      }

      // --------------------------------------------------------
      // 5. COPY MARKETPLACE IDENTIFIERS BACK
      // --------------------------------------------------------

      widget.request.requestId =
          result.request.requestId;

      widget.request.requestTypeId =
          result.request.requestTypeId;

      widget.request.capabilityId =
          result.request.capabilityId;

      widget.request.customerId =
          result.request.customerId;

      // --------------------------------------------------------
      // 6. CREATE PROFESSIONAL OPPORTUNITIES
      // --------------------------------------------------------

      final marketplaceResult =
          MarketplaceRequestService
              .matchAndCreateOpportunities(
        result.request,
      );

      // --------------------------------------------------------
      // 7. LOG MARKETPLACE RESULT
      // --------------------------------------------------------

      debugPrint(
        '========== PROJECT X REQUEST PROCESSED ==========',
      );

      debugPrint(
        'Request ID: '
        '${result.request.requestId}',
      );

      debugPrint(
        'Request Type ID: '
        '${result.request.requestTypeId}',
      );

      debugPrint(
        'Capability ID: '
        '${result.request.capabilityId}',
      );

      debugPrint(
        'Customer ID: '
        '${result.request.customerId}',
      );

      debugPrint(
        'Matched Professionals: '
        '${marketplaceResult.matchedProfessionalIds.length}',
      );

      for (final professionalId
          in marketplaceResult
              .matchedProfessionalIds) {
        debugPrint(
          'MATCHED → $professionalId',
        );
      }

      debugPrint(
        'Opportunities Created: '
        '${marketplaceResult.opportunities.length}',
      );

      for (final opportunity
          in marketplaceResult.opportunities) {
        debugPrint(
          'OPPORTUNITY → '
          '${opportunity.opportunityId} | '
          'Request: ${opportunity.requestId} | '
          'Professional: ${opportunity.professionalId}',
        );
      }

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
  // OPEN PROFESSIONALS SCREEN
  // ============================================================

  void _openProfessionalsScreen() {
    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProfessionalsScreen(
          request: widget.request,
        ),
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
                'Finding Professionals',
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
                'Searching nearby verified professionals\n'
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
                          'Verified Professionals Only',
                      subtitle:
                          'Matching trusted professionals',
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
                          'Finding professionals nearby',
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
                      subtitle:
                          'Waiting for quotations',
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // ------------------------------------------------
              // MARKETPLACE MESSAGE
              // ------------------------------------------------

              const Text(
                'Professionals will decide their price.\n'
                'You decide which offer is right for you.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
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