import '../models/marketplace_status.dart';
import '../models/order_model.dart';
import 'bid_service.dart';
import 'opportunity_service.dart';
import 'order_service.dart';

class OrderAcceptanceService {
  // ============================================================
  // CUSTOMER ACCEPTS A BID
  // ============================================================

  static Future<OrderModel> acceptBid({
    required String bidId,
  }) async {
    // ----------------------------------------------------------
    // 1. FIND THE BID
    // ----------------------------------------------------------

    final allBids = BidService.getAllBids();

    final selectedBidIndex = allBids.indexWhere(
      (bid) => bid.bidId == bidId,
    );

    if (selectedBidIndex == -1) {
      throw StateError(
        'Bid not found.',
      );
    }

    final selectedBid = allBids[selectedBidIndex];

    // ----------------------------------------------------------
    // 2. BID MUST STILL BE SUBMITTED
    // ----------------------------------------------------------

    if (selectedBid.status !=
        MarketplaceStatus.submitted) {
      throw StateError(
        'Only a submitted bid can be accepted.',
      );
    }

    // ----------------------------------------------------------
    // 3. CHECK PROFESSIONAL ACTIVE ORDER LIMIT
    // ----------------------------------------------------------

    final activeOrderCount =
        OrderService.getActiveOrderCountForProfessional(
      selectedBid.professionalId,
    );

    if (activeOrderCount >=
        OrderService.maxActiveOrdersPerProfessional) {
      throw StateError(
        'Professional already has '
        '${OrderService.maxActiveOrdersPerProfessional} '
        'active orders.',
      );
    }

    // ----------------------------------------------------------
    // 4. ACCEPT THE SELECTED BID
    // ----------------------------------------------------------

    BidService.acceptBid(
      bidId,
    );

    // ----------------------------------------------------------
    // 5. CREATE THE ORDER
    // ----------------------------------------------------------

    final order = OrderService.createOrderFromBid(
      bidId: bidId,
    );

    // ----------------------------------------------------------
    // 6. REJECT ALL OTHER BIDS FOR THIS REQUEST
    // ----------------------------------------------------------

    final requestBids =
        BidService.getBidsForRequest(
      selectedBid.requestId,
    );

    for (final bid in requestBids) {
      if (bid.bidId == bidId) {
        continue;
      }

      if (bid.status ==
          MarketplaceStatus.submitted) {
        BidService.rejectBid(
          bid.bidId,
        );
      }
    }

    // ----------------------------------------------------------
    // 7. CLOSE OTHER OPPORTUNITIES
    // ----------------------------------------------------------

    await OpportunityService.closeOtherOpportunities(
      requestId: selectedBid.requestId,
      selectedProfessionalId:
          selectedBid.professionalId,
    );

    // ----------------------------------------------------------
    // 8. MARK SELECTED OPPORTUNITY
    // ----------------------------------------------------------

    await OpportunityService.markAsSelected(
      requestId: selectedBid.requestId,
      professionalId:
          selectedBid.professionalId,
    );

    // ----------------------------------------------------------
    // 9. RETURN CREATED ORDER
    // ----------------------------------------------------------

    return order;
  }
}