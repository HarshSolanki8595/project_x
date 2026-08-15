import '../models/marketplace_status.dart';
import 'bid_service.dart';
import 'marketplace_request_service.dart';
import 'opportunity_service.dart';
import 'order_acceptance_service.dart';
import 'request_processing_service.dart';

class MatchingDemo {
  static Future<void> run() async {
    print('');
    print('########################################');
    print('PROJECT X COMPETITIVE MARKETPLACE TEST');
    print('########################################');

    // ==========================================================
    // TEST 1
    // CUSTOMER CREATES REQUEST
    // ==========================================================

    print('');
    print('========================================');
    print('TEST 1: CUSTOMER CREATES REQUEST');
    print('========================================');

    final MatchingResult? result =
        await RequestProcessingService.processRequest(
      customerId: 'CUST_000001',
      customerText: 'My AC is leaking water',
      latitude: 19.0760,
      longitude: 72.8777,
    );

    if (result == null) {
      print('ERROR: Request could not be classified.');
      return;
    }

    final request = result.request;

    print('REQUEST CREATED √');
    print('Request ID: ${request.requestId}');
    print('Request Type ID: ${request.requestTypeId}');
    print('Capability ID: ${request.capabilityId}');
    print('Description: ${request.description}');

    // ==========================================================
    // TEST 2
    // VERIFY ELIGIBLE PROFESSIONALS
    // ==========================================================

    print('');
    print('========================================');
    print('TEST 2: PROFESSIONAL MATCHING');
    print('========================================');

    final eligibleProfessionals =
        result.eligibleProfessionals;

    print(
      'Eligible Professionals: '
      '${eligibleProfessionals.length}',
    );

    for (final professional in eligibleProfessionals) {
      print(
        'MATCHED → '
        '${professional.professionalId} | '
        '${professional.name}',
      );
    }

    if (eligibleProfessionals.length != 3) {
      print('');
      print(
        'WARNING: Expected 3 eligible professionals '
        'but found ${eligibleProfessionals.length}.',
      );
      print(
        'Check ProfessionalData and matching rules.',
      );
    }

    // ==========================================================
    // TEST 3
    // CREATE OPPORTUNITIES
    // ==========================================================

    print('');
    print('========================================');
    print('TEST 3: OPPORTUNITY CREATION');
    print('========================================');

    final marketplaceResult =
        MarketplaceRequestService
            .matchAndCreateOpportunities(
      request,
    );

    print(
      'Matched Professional IDs: '
      '${marketplaceResult.matchedProfessionalIds}',
    );

    print(
      'Opportunities created: '
      '${marketplaceResult.opportunities.length}',
    );

    for (final opportunity
        in marketplaceResult.opportunities) {
      print(
        '${opportunity.opportunityId} | '
        'Request: ${opportunity.requestId} | '
        'Professional: ${opportunity.professionalId} | '
        'Status: ${opportunity.status}',
      );
    }

    // ==========================================================
    // TEST 4
    // THREE PROFESSIONALS SUBMIT ONE BID EACH
    // ==========================================================

    print('');
    print('========================================');
    print('TEST 4: COMPETING BIDS');
    print('========================================');

    final bid1 =
        MarketplaceRequestService.submitProfessionalBid(
      requestId: request.requestId,
      professionalId: 'PRO_000001',
      quotedPrice: 800,
      estimatedTime: '1 hour',
      message: 'I can repair the AC.',
    );

    print(
      'BID 1 CREATED √ | '
      '${bid1.bidId} | '
      '${bid1.professionalId} | '
      '₹${bid1.quotedPrice}',
    );

    final bid2 =
        MarketplaceRequestService.submitProfessionalBid(
      requestId: request.requestId,
      professionalId: 'PRO_000002',
      quotedPrice: 700,
      estimatedTime: '1.5 hours',
      message: 'I can inspect and repair the AC.',
    );

    print(
      'BID 2 CREATED √ | '
      '${bid2.bidId} | '
      '${bid2.professionalId} | '
      '₹${bid2.quotedPrice}',
    );

    final bid3 =
        MarketplaceRequestService.submitProfessionalBid(
      requestId: request.requestId,
      professionalId: 'PRO_000003',
      quotedPrice: 900,
      estimatedTime: '1 hour',
      message: 'I can diagnose and repair the AC.',
    );

    print(
      'BID 3 CREATED √ | '
      '${bid3.bidId} | '
      '${bid3.professionalId} | '
      '₹${bid3.quotedPrice}',
    );

    // ==========================================================
    // TEST 5
    // CUSTOMER VIEWS ALL BIDS
    // ==========================================================

    print('');
    print('========================================');
    print('TEST 5: CUSTOMER VIEWS ALL BIDS');
    print('========================================');

    final customerBids =
        MarketplaceRequestService.getCustomerBids(
      request.requestId,
    );

    print(
      'Total bids: ${customerBids.length}',
    );

    for (final bid in customerBids) {
      print(
        '${bid.bidId} | '
        'Professional: ${bid.professionalId} | '
        'Price: ₹${bid.quotedPrice} | '
        'Time: ${bid.estimatedTime} | '
        'Status: ${bid.status}',
      );
    }

    if (customerBids.length != 3) {
      print('');
      print(
        'ERROR: Expected exactly 3 bids.',
      );
      return;
    }

    // ==========================================================
    // TEST 6
    // CUSTOMER SELECTS ONE PROFESSIONAL
    // ==========================================================

    print('');
    print('========================================');
    print('TEST 6: CUSTOMER SELECTS PROFESSIONAL');
    print('========================================');

    print(
      'CUSTOMER SELECTS → '
      '${bid2.professionalId}',
    );

    print(
      'Selected Bid → '
      '${bid2.bidId} | '
      '₹${bid2.quotedPrice}',
    );

    final order =
        OrderAcceptanceService.acceptBid(
      bidId: bid2.bidId,
    );

    print('');
    print('BID ACCEPTED √');
    print(
      'Accepted Bid ID: '
      '${bid2.bidId}',
    );
    print(
      'Accepted Professional: '
      '${bid2.professionalId}',
    );

    // ==========================================================
    // TEST 7
    // CONFIRMED ORDER
    // ==========================================================

    print('');
    print('========================================');
    print('TEST 7: CONFIRMED ORDER');
    print('========================================');

    print('ORDER CREATED √');
    print('Order ID: ${order.orderId}');
    print('Request ID: ${order.requestId}');
    print(
      'Professional ID: '
      '${order.professionalId}',
    );
    print('Bid ID: ${order.bidId}');
    print('Agreed Price: ₹${order.agreedPrice}');
    print('Status: ${order.status}');

    // ==========================================================
    // TEST 8
    // VERIFY FINAL BID STATES
    // ==========================================================

    print('');
    print('========================================');
    print('TEST 8: FINAL BID STATES');
    print('========================================');

    final finalBids =
        MarketplaceRequestService.getCustomerBids(
      request.requestId,
    );

    for (final bid in finalBids) {
      print(
        '${bid.bidId} | '
        '${bid.professionalId} | '
        '${bid.status}',
      );
    }

    // ==========================================================
    // TEST 9
    // VERIFY FINAL OPPORTUNITY STATES
    // ==========================================================

    print('');
    print('========================================');
    print('TEST 9: FINAL OPPORTUNITY STATES');
    print('========================================');

    final finalOpportunities =
        OpportunityService.getOpportunitiesForRequest(
      request.requestId,
    );

    for (final opportunity
        in finalOpportunities) {
      print(
        '${opportunity.opportunityId} | '
        'Professional: '
        '${opportunity.professionalId} | '
        'Status: ${opportunity.status}',
      );
    }

    // ==========================================================
    // TEST 10
    // FINAL MARKETPLACE VERIFICATION
    // ==========================================================

    print('');
    print('========================================');
    print('TEST 10: FINAL MARKETPLACE VERIFICATION');
    print('========================================');

    final acceptedBids = finalBids
        .where(
          (bid) =>
              bid.status ==
              MarketplaceStatus.accepted,
        )
        .length;

    final rejectedBids = finalBids
        .where(
          (bid) =>
              bid.status ==
              MarketplaceStatus.rejected,
        )
        .length;

    final selectedOpportunities =
        finalOpportunities
            .where(
              (opportunity) =>
                  opportunity.status ==
                  MarketplaceStatus.selected,
            )
            .length;

    final closedOpportunities =
        finalOpportunities
            .where(
              (opportunity) =>
                  opportunity.status ==
                  MarketplaceStatus.closed,
            )
            .length;

    print(
      'Accepted bids: '
      '$acceptedBids',
    );

    print(
      'Rejected bids: '
      '$rejectedBids',
    );

    print(
      'Selected opportunities: '
      '$selectedOpportunities',
    );

    print(
      'Closed opportunities: '
      '$closedOpportunities',
    );

    // ==========================================================
    // EXPECTED RESULT
    // ==========================================================

    if (acceptedBids == 1 &&
        rejectedBids == 2 &&
        selectedOpportunities == 1 &&
        closedOpportunities == 2) {
      print('');
      print('########################################');
      print('COMPETITIVE MARKETPLACE TEST PASSED √');
      print('########################################');
    } else {
      print('');
      print('########################################');
      print('COMPETITIVE MARKETPLACE TEST FAILED');
      print('########################################');
    }

    print('');
  }
}