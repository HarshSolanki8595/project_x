import '../models/matched_opportunity_model.dart';
import '../models/professional_bid_model.dart';
import '../models/service_request_model.dart';
import 'bid_service.dart';
import 'matching_service.dart';
import 'opportunity_service.dart';

class MarketplaceRequestResult {
  final ServiceRequestModel request;
  final List<String> matchedProfessionalIds;
  final List<MatchedOpportunityModel> opportunities;

  const MarketplaceRequestResult({
    required this.request,
    required this.matchedProfessionalIds,
    required this.opportunities,
  });
}

class MarketplaceRequestService {
  // ============================================================
  // MATCH REQUEST AND CREATE OPPORTUNITIES
  // ============================================================
  //
  // This is the marketplace flow after a request has been created.
  //
  // Request
  //    ↓
  // MatchingService
  //    ↓
  // Eligible Professionals
  //    ↓
  // OpportunityService
  //    ↓
  // Professional Opportunities
  //
  static MarketplaceRequestResult
      matchAndCreateOpportunities(
    ServiceRequestModel request,
  ) {
    // ----------------------------------------------------------
    // 1. FIND ELIGIBLE PROFESSIONALS
    // ----------------------------------------------------------

    final eligibleProfessionals =
        MatchingService.matchRequest(request);

    // ----------------------------------------------------------
    // 2. EXTRACT PROFESSIONAL IDs
    // ----------------------------------------------------------

    final professionalIds = eligibleProfessionals
        .map((professional) => professional.id)
        .toList();

    // ----------------------------------------------------------
    // 3. CREATE OPPORTUNITY FOR EACH MATCHED PROFESSIONAL
    // ----------------------------------------------------------

    final opportunities =
        OpportunityService.createForMatchedProfessionals(
      requestId: request.requestId,
      professionalIds: professionalIds,
    );

    // ----------------------------------------------------------
    // 4. RETURN COMPLETE RESULT
    // ----------------------------------------------------------

    return MarketplaceRequestResult(
      request: request,
      matchedProfessionalIds: professionalIds,
      opportunities: opportunities,
    );
  }

  // ============================================================
  // PROFESSIONAL SUBMITS BID
  // ============================================================

  static ProfessionalBidModel submitProfessionalBid({
    required String requestId,
    required String professionalId,
    required double quotedPrice,
    required String estimatedTime,
    required String message,
  }) {
    return BidService.submitBid(
      requestId: requestId,
      professionalId: professionalId,
      quotedPrice: quotedPrice,
      estimatedTime: estimatedTime,
      message: message,
    );
  }

  // ============================================================
  // GET CUSTOMER BIDS
  // ============================================================

  static List<ProfessionalBidModel> getCustomerBids(
    String requestId,
  ) {
    return BidService.getBidsForRequest(requestId);
  }
}