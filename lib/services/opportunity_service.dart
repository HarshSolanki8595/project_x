import '../models/matched_opportunity_model.dart';
import '../models/marketplace_status.dart';

class OpportunityService {
  static int _opportunityCounter = 1;

  static final List<MatchedOpportunityModel> _opportunities = [];

  // ============================================================
  // CREATE OPPORTUNITY
  // ============================================================

  static MatchedOpportunityModel createOpportunity({
    required String requestId,
    required String professionalId,
  }) {
    final existingOpportunity = _findOpportunity(
      requestId: requestId,
      professionalId: professionalId,
    );

    if (existingOpportunity != null) {
      return existingOpportunity;
    }

    final String opportunityId =
        'OPP_${_opportunityCounter.toString().padLeft(6, '0')}';

    _opportunityCounter++;

    final opportunity = MatchedOpportunityModel(
      opportunityId: opportunityId,
      requestId: requestId,
      professionalId: professionalId,
      status: MarketplaceStatus.sent,
      createdAt: DateTime.now(),
    );

    _opportunities.add(opportunity);

    return opportunity;
  }

  // ============================================================
  // CREATE OPPORTUNITIES FOR MATCHED PROFESSIONALS
  // ============================================================

  static List<MatchedOpportunityModel>
      createForMatchedProfessionals({
    required String requestId,
    required List<String> professionalIds,
  }) {
    final List<MatchedOpportunityModel> opportunities = [];

    for (final professionalId in professionalIds) {
      final opportunity = createOpportunity(
        requestId: requestId,
        professionalId: professionalId,
      );

      opportunities.add(opportunity);
    }

    return opportunities;
  }

  // ============================================================
  // CHECK WHETHER PROFESSIONAL CAN BID
  // ============================================================

  static bool canProfessionalBid({
    required String requestId,
    required String professionalId,
  }) {
    final opportunity = _findOpportunity(
      requestId: requestId,
      professionalId: professionalId,
    );

    if (opportunity == null) {
      return false;
    }

    return opportunity.status == MarketplaceStatus.sent ||
        opportunity.status == MarketplaceStatus.viewed;
  }

  // ============================================================
  // MARK OPPORTUNITY AS VIEWED
  // ============================================================

  static bool markAsViewed({
    required String requestId,
    required String professionalId,
  }) {
    final int index = _findOpportunityIndex(
      requestId: requestId,
      professionalId: professionalId,
    );

    if (index == -1) {
      return false;
    }

    final existing = _opportunities[index];

    if (existing.status != MarketplaceStatus.sent) {
      return false;
    }

    _opportunities[index] = MatchedOpportunityModel(
      opportunityId: existing.opportunityId,
      requestId: existing.requestId,
      professionalId: existing.professionalId,
      status: MarketplaceStatus.viewed,
      createdAt: existing.createdAt,
    );

    return true;
  }

  // ============================================================
  // MARK OPPORTUNITY AS BID SUBMITTED
  // ============================================================
  //
  // Called after a professional successfully submits a bid.
  //

  static bool markAsBidSubmitted({
    required String requestId,
    required String professionalId,
  }) {
    final int index = _findOpportunityIndex(
      requestId: requestId,
      professionalId: professionalId,
    );

    if (index == -1) {
      return false;
    }

    final existing = _opportunities[index];

    if (existing.status != MarketplaceStatus.sent &&
        existing.status != MarketplaceStatus.viewed) {
      return false;
    }

    _opportunities[index] = MatchedOpportunityModel(
      opportunityId: existing.opportunityId,
      requestId: existing.requestId,
      professionalId: existing.professionalId,
      status: MarketplaceStatus.bidSubmitted,
      createdAt: existing.createdAt,
    );

    return true;
  }

  // ============================================================
  // MARK SELECTED OPPORTUNITY
  // ============================================================

  static bool markAsSelected({
    required String requestId,
    required String professionalId,
  }) {
    final int index = _findOpportunityIndex(
      requestId: requestId,
      professionalId: professionalId,
    );

    if (index == -1) {
      return false;
    }

    final existing = _opportunities[index];

    if (existing.status !=
        MarketplaceStatus.bidSubmitted) {
      return false;
    }

    _opportunities[index] = MatchedOpportunityModel(
      opportunityId: existing.opportunityId,
      requestId: existing.requestId,
      professionalId: existing.professionalId,
      status: MarketplaceStatus.selected,
      createdAt: existing.createdAt,
    );

    return true;
  }

  // ============================================================
  // CLOSE OTHER OPPORTUNITIES
  // ============================================================
  //
  // When the customer selects one professional, all other
  // opportunities for that request are closed.
  //

  static void closeOtherOpportunities({
    required String requestId,
    required String selectedProfessionalId,
  }) {
    for (int i = 0; i < _opportunities.length; i++) {
      final opportunity = _opportunities[i];

      if (opportunity.requestId != requestId) {
        continue;
      }

      if (opportunity.professionalId ==
          selectedProfessionalId) {
        continue;
      }

      if (opportunity.status ==
              MarketplaceStatus.sent ||
          opportunity.status ==
              MarketplaceStatus.viewed ||
          opportunity.status ==
              MarketplaceStatus.bidSubmitted) {
        _opportunities[i] =
            MatchedOpportunityModel(
          opportunityId: opportunity.opportunityId,
          requestId: opportunity.requestId,
          professionalId: opportunity.professionalId,
          status: MarketplaceStatus.closed,
          createdAt: opportunity.createdAt,
        );
      }
    }
  }

  // ============================================================
  // GET OPPORTUNITIES FOR PROFESSIONAL
  // ============================================================

  static List<MatchedOpportunityModel>
      getOpportunitiesForProfessional(
    String professionalId,
  ) {
    return _opportunities
        .where(
          (opportunity) =>
              opportunity.professionalId == professionalId,
        )
        .toList();
  }

  // ============================================================
  // GET OPPORTUNITIES FOR REQUEST
  // ============================================================

  static List<MatchedOpportunityModel>
      getOpportunitiesForRequest(
    String requestId,
  ) {
    return _opportunities
        .where(
          (opportunity) =>
              opportunity.requestId == requestId,
        )
        .toList();
  }

  // ============================================================
  // GET OPPORTUNITY BY ID
  // ============================================================

  static MatchedOpportunityModel? getOpportunityById(
    String opportunityId,
  ) {
    for (final opportunity in _opportunities) {
      if (opportunity.opportunityId == opportunityId) {
        return opportunity;
      }
    }

    return null;
  }

  // ============================================================
  // INTERNAL LOOKUP
  // ============================================================

  static MatchedOpportunityModel? _findOpportunity({
    required String requestId,
    required String professionalId,
  }) {
    for (final opportunity in _opportunities) {
      if (opportunity.requestId == requestId &&
          opportunity.professionalId == professionalId) {
        return opportunity;
      }
    }

    return null;
  }

  // ============================================================
  // INTERNAL INDEX LOOKUP
  // ============================================================

  static int _findOpportunityIndex({
    required String requestId,
    required String professionalId,
  }) {
    return _opportunities.indexWhere(
      (opportunity) =>
          opportunity.requestId == requestId &&
          opportunity.professionalId == professionalId,
    );
  }
}