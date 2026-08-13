class MarketplaceStatus {
  MarketplaceStatus._();

  // ============================================================
  // REQUEST STATUSES
  // ============================================================

  static const String draft = 'DRAFT';

  static const String open = 'OPEN';

  static const String bidding = 'BIDDING';

  static const String professionalSelected =
      'PROFESSIONAL_SELECTED';

  static const String inProgress = 'IN_PROGRESS';

  static const String completed = 'COMPLETED';

  static const String cancelled = 'CANCELLED';

  // Request remains available for the business day and
  // expires when that day ends without a professional
  // being selected.
  static const String expired = 'EXPIRED';

  // ============================================================
  // OPPORTUNITY STATUSES
  // ============================================================

  // Request opportunity has been sent to the professional.
  static const String sent = 'SENT';

  // Professional has viewed the opportunity.
  static const String viewed = 'VIEWED';

  // Professional has submitted a bid for the opportunity.
  static const String bidSubmitted = 'BID_SUBMITTED';

  // Customer selected this professional's bid.
  static const String selected = 'SELECTED';

  // Opportunity is no longer available.
  static const String closed = 'CLOSED';

  // ============================================================
  // BID STATUSES
  // ============================================================

  // Professional submitted the bid.
  static const String submitted = 'SUBMITTED';

  // Customer accepted this bid.
  static const String accepted = 'ACCEPTED';

  // Customer selected another bid.
  static const String rejected = 'REJECTED';

  // Professional withdrew the bid.
  static const String withdrawn = 'WITHDRAWN';

  // ============================================================
  // ORDER STATUSES
  // ============================================================

  // Customer accepted the bid and the order is confirmed.
  static const String confirmed = 'CONFIRMED';

  // Order is active: the work is ready to begin or has begun.
  static const String active = 'ACTIVE';

  // Order work has been completed.
  static const String orderCompleted = 'ORDER_COMPLETED';

  // Order has been cancelled.
  static const String orderCancelled = 'ORDER_CANCELLED';
}