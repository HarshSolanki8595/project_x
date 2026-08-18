import '../models/marketplace_status.dart';
import '../models/professional_bid_model.dart';
import 'opportunity_service.dart';

class BidService {
  static int _bidCounter = 1;

  static final List<ProfessionalBidModel> _bids = [];

  // ============================================================
  // SUBMIT BID
  // ============================================================
  //
  // RULE:
  // One professional can submit only ONE bid for one
  // customer request.
  //
  // A withdrawn/rejected bid does NOT allow another bid
  // from the same professional for the same request.
  //

  static Future<ProfessionalBidModel> submitBid({
    required String requestId,
    required String professionalId,
    required double quotedPrice,
    required String estimatedTime,
    required String message,
  }) async {
    // ----------------------------------------------------------
    // 1. PROFESSIONAL MUST HAVE A MATCHED OPPORTUNITY
    // ----------------------------------------------------------

    final bool canBid =
        await OpportunityService.canProfessionalBid(
      requestId: requestId,
      professionalId: professionalId,
    );

    if (!canBid) {
      throw StateError(
        'Professional is not authorized to bid on this request.',
      );
    }

    // ----------------------------------------------------------
    // 2. PROFESSIONAL CAN ONLY BID ONCE FOR THIS REQUEST
    // ----------------------------------------------------------

    final existingBid = _findBidForProfessionalAndRequest(
      requestId: requestId,
      professionalId: professionalId,
    );

    if (existingBid != null) {
      throw StateError(
        'Professional has already submitted a bid '
        'for this request.',
      );
    }

    // ----------------------------------------------------------
    // 3. VALIDATE PRICE
    // ----------------------------------------------------------

    if (quotedPrice <= 0) {
      throw ArgumentError(
        'Quoted price must be greater than zero.',
      );
    }

    // ----------------------------------------------------------
    // 4. VALIDATE ESTIMATED TIME
    // ----------------------------------------------------------

    if (estimatedTime.trim().isEmpty) {
      throw ArgumentError(
        'Estimated time cannot be empty.',
      );
    }

    // ----------------------------------------------------------
    // 5. GENERATE BID ID
    // ----------------------------------------------------------

    final String bidId =
        'BID_${_bidCounter.toString().padLeft(6, '0')}';

    _bidCounter++;

    // ----------------------------------------------------------
    // 6. CREATE BID
    // ----------------------------------------------------------

    final ProfessionalBidModel bid =
        ProfessionalBidModel(
      bidId: bidId,
      requestId: requestId,
      professionalId: professionalId,
      quotedPrice: quotedPrice,
      estimatedTime: estimatedTime,
      message: message,
      status: MarketplaceStatus.submitted,
      createdAt: DateTime.now(),
    );

    _bids.add(bid);

    // ----------------------------------------------------------
    // 7. UPDATE OPPORTUNITY
    // ----------------------------------------------------------
    //
    // The opportunity has now progressed from:
    //
    // SENT / VIEWED
    //       ↓
    // BID_SUBMITTED
    //

    await OpportunityService.markAsBidSubmitted(
      requestId: requestId,
      professionalId: professionalId,
    );

    return bid;
  }

  // ============================================================
  // ACCEPT BID
  // ============================================================

  static ProfessionalBidModel acceptBid(
    String bidId,
  ) {
    final int index = _bids.indexWhere(
      (bid) => bid.bidId == bidId,
    );

    if (index == -1) {
      throw StateError(
        'Bid not found.',
      );
    }

    final ProfessionalBidModel existingBid =
        _bids[index];

    if (existingBid.status !=
        MarketplaceStatus.submitted) {
      throw StateError(
        'Only a submitted bid can be accepted.',
      );
    }

    final ProfessionalBidModel acceptedBid =
        ProfessionalBidModel(
      bidId: existingBid.bidId,
      requestId: existingBid.requestId,
      professionalId: existingBid.professionalId,
      quotedPrice: existingBid.quotedPrice,
      estimatedTime: existingBid.estimatedTime,
      message: existingBid.message,
      status: MarketplaceStatus.accepted,
      createdAt: existingBid.createdAt,
    );

    _bids[index] = acceptedBid;

    return acceptedBid;
  }

  // ============================================================
  // REJECT BID
  // ============================================================

  static ProfessionalBidModel rejectBid(
    String bidId,
  ) {
    final int index = _bids.indexWhere(
      (bid) => bid.bidId == bidId,
    );

    if (index == -1) {
      throw StateError(
        'Bid not found.',
      );
    }

    final ProfessionalBidModel existingBid =
        _bids[index];

    if (existingBid.status !=
        MarketplaceStatus.submitted) {
      throw StateError(
        'Only a submitted bid can be rejected.',
      );
    }

    final ProfessionalBidModel rejectedBid =
        ProfessionalBidModel(
      bidId: existingBid.bidId,
      requestId: existingBid.requestId,
      professionalId: existingBid.professionalId,
      quotedPrice: existingBid.quotedPrice,
      estimatedTime: existingBid.estimatedTime,
      message: existingBid.message,
      status: MarketplaceStatus.rejected,
      createdAt: existingBid.createdAt,
    );

    _bids[index] = rejectedBid;

    return rejectedBid;
  }

  // ============================================================
  // WITHDRAW BID
  // ============================================================
  //
  // Withdrawal is allowed while the bid is still submitted.
  //
  // IMPORTANT:
  // Withdrawal does NOT allow the professional to submit
  // another bid for the same request.
  //

  static ProfessionalBidModel withdrawBid(
    String bidId,
  ) {
    final int index = _bids.indexWhere(
      (bid) => bid.bidId == bidId,
    );

    if (index == -1) {
      throw StateError(
        'Bid not found.',
      );
    }

    final ProfessionalBidModel existingBid =
        _bids[index];

    if (existingBid.status !=
        MarketplaceStatus.submitted) {
      throw StateError(
        'Only a submitted bid can be withdrawn.',
      );
    }

    final ProfessionalBidModel withdrawnBid =
        ProfessionalBidModel(
      bidId: existingBid.bidId,
      requestId: existingBid.requestId,
      professionalId: existingBid.professionalId,
      quotedPrice: existingBid.quotedPrice,
      estimatedTime: existingBid.estimatedTime,
      message: existingBid.message,
      status: MarketplaceStatus.withdrawn,
      createdAt: existingBid.createdAt,
    );

    _bids[index] = withdrawnBid;

    return withdrawnBid;
  }

  // ============================================================
  // GET BIDS FOR REQUEST
  // ============================================================

  static List<ProfessionalBidModel> getBidsForRequest(
    String requestId,
  ) {
    return _bids
        .where(
          (bid) => bid.requestId == requestId,
        )
        .toList();
  }

  // ============================================================
  // GET ALL BIDS
  // ============================================================

  static List<ProfessionalBidModel> getAllBids() {
    return List.unmodifiable(_bids);
  }

  // ============================================================
  // GET BID BY ID
  // ============================================================

  static ProfessionalBidModel? getBidById(
    String bidId,
  ) {
    for (final bid in _bids) {
      if (bid.bidId == bidId) {
        return bid;
      }
    }

    return null;
  }

  // ============================================================
  // INTERNAL LOOKUP
  // ============================================================
  //
  // IMPORTANT:
  // We deliberately search ALL bids, not only submitted bids.
  //
  // This enforces:
  //
  // PRO_000001
  //      ↓
  // REQ_000001
  //      ↓
  // BID_000001
  //      ↓
  // WITHDRAWN
  //      ↓
  // Cannot create BID_000002 for REQ_000001
  //

  static ProfessionalBidModel?
      _findBidForProfessionalAndRequest({
    required String requestId,
    required String professionalId,
  }) {
    for (final bid in _bids) {
      if (bid.requestId == requestId &&
          bid.professionalId == professionalId) {
        return bid;
      }
    }

    return null;
  }
}