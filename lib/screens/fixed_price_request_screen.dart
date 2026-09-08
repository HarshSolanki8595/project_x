import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/fixed_price_service_config.dart';
import '../models/service_request.dart';
import 'address_screen.dart';

// ================================================================
// FIXED-PRICE REQUEST SCREEN -- Helper Services & Cleaning only
// ================================================================
// Added 2026-09-02. Replaces ServiceRequestScreen (the free-text
// "describe your issue" flow) for the two categories on the new
// fixed-price pricing model. See fixed_price_service_config.dart
// for the tier structure and the reasoning behind what this screen
// does and doesn't ask.
//
// REVISED 2026-09-02 (same day): switched from hours/recipients
// steppers feeding a formula to a tier picker -- the customer taps
// one of 3 package tiers (subcategory-specific: property size for
// Cleaning, duration or headcount for most Helper Services), and
// that tier's price becomes the starting/floor price. Still
// editable, still warns if lowered below the tier price.
//
// Deliberately does NOT ask for location -- the existing, unchanged
// AddressScreen right after this one already collects that for
// every request type, so this screen only collects what's specific
// to fixed-price pricing: which tier the customer wants. From here
// on (Address -> Date/Time -> Booking Summary -> Finding
// Professionals) the request flows through the exact same screens
// as a normal bid-based request, unmodified.
// ================================================================

class FixedPriceRequestScreen extends StatefulWidget {
  final String categoryName;
  final String subCategoryName;
  final String subCategoryId;
  final String categoryId;

  const FixedPriceRequestScreen({
    super.key,
    required this.categoryName,
    required this.subCategoryName,
    required this.subCategoryId,
    required this.categoryId,
  });

  @override
  State<FixedPriceRequestScreen> createState() =>
      _FixedPriceRequestScreenState();
}

class _FixedPriceRequestScreenState extends State<FixedPriceRequestScreen> {
  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color pageBackground = Color(0xFFF7F8FC);
  static const Color warningBg = Color(0xFFFFF7ED);
  static const Color warningBorder = Color(0xFFFBBF24);
  static const Color warningText = Color(0xFF9A6B00);

  static const FixedPriceSubCategoryConfig _fallbackConfig =
      FixedPriceSubCategoryConfig(
    subCategoryId: '',
    tierAxisLabel: 'Package',
    tiers: [
      PriceTier(
        key: 'small',
        label: 'Small',
        description: 'A shorter or smaller job',
        price: 349,
        estimatedHours: 1.5,
      ),
      PriceTier(
        key: 'standard',
        label: 'Standard',
        description: 'A typical job of this kind',
        price: 599,
        estimatedHours: 2.5,
      ),
      PriceTier(
        key: 'large',
        label: 'Large',
        description: 'A bigger or longer job',
        price: 949,
        estimatedHours: 4,
      ),
    ],
  );

  late final FixedPriceSubCategoryConfig _config;
  late PriceTier _selectedTier;

  final TextEditingController _priceController = TextEditingController();
  bool _priceEditedByUser = false;

  @override
  void initState() {
    super.initState();

    _config =
        FixedPriceCatalog.forSubCategory(widget.subCategoryId) ??
            _fallbackConfig;

    _selectedTier = _config.defaultTier;
    _priceController.text = _selectedTier.price.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _selectTier(PriceTier tier) {
    setState(() {
      _selectedTier = tier;

      // Only auto-fill the price field while the customer hasn't
      // typed into it themselves -- once they've edited it,
      // switching tiers shouldn't silently overwrite their number.
      if (!_priceEditedByUser) {
        _priceController.text = tier.price.toStringAsFixed(0);
      }
    });
  }

  double? get _enteredPrice => double.tryParse(_priceController.text.trim());

  bool get _isBelowFair {
    final entered = _enteredPrice;
    if (entered == null) return false;
    return entered < _selectedTier.price;
  }

  void _continue() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in before creating a request.'),
        ),
      );
      return;
    }

    final entered = _enteredPrice;

    if (entered == null || entered <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price.')),
      );
      return;
    }

    final tier = _selectedTier;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressScreen(
          request: ServiceRequest(
            categoryName: widget.categoryName,
            subCategoryName: widget.subCategoryName,
            issueDescription:
                '${widget.subCategoryName} -- fixed-price request '
                '(${tier.label}).',
            isEmergency: false,
            capabilityId: widget.subCategoryId,
            requestTypeId: widget.subCategoryId,
            categoryId: widget.categoryId,
            customerId: currentUser.uid,
            pricingType: 'FIXED_PRICE',
            fixedPriceAnswers: {
              'tier': tier.key,
              'tierLabel': tier.label,
            },
            serviceDurationHours: tier.estimatedHours,
            computedFairPrice: tier.price,
            postedPrice: entered,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: darkText,
        title: const Text(
          'Request Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceHeader(),
              const SizedBox(height: 28),
              _buildTierSection(),
              const SizedBox(height: 26),
              _buildPriceSection(),
              const SizedBox(height: 30),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5EAF1)),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryName,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.subCategoryName,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _config.tierAxisLabel,
          style: const TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pick the option that best matches your job -- this sets the '
          'starting price below.',
          style: TextStyle(color: secondaryText, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 14),
        ..._config.tiers.map(
          (tier) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _tierCard(tier),
          ),
        ),
      ],
    );
  }

  Widget _tierCard(PriceTier tier) {
    final bool selected = tier.key == _selectedTier.key;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _selectTier(tier),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF3FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? primaryBlue : const Color(0xFFDCE3EC),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? primaryBlue : const Color(0xFFB6C0CE),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier.label,
                    style: TextStyle(
                      color: darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (tier.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      tier.description,
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '₹${tier.price.toStringAsFixed(0)}',
              style: const TextStyle(
                color: darkText,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your price',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Price for the "${_selectedTier.label}" package: '
          '₹${_selectedTier.price.toStringAsFixed(0)}. You can post at '
          'this price, or adjust it.',
          style: const TextStyle(
            color: secondaryText,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDCE3EC)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 4),
          child: Row(
            children: [
              const Text(
                '₹',
                style: TextStyle(
                  color: darkText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (_) {
                    setState(() {
                      _priceEditedByUser = true;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        if (_isBelowFair) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: warningBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: warningBorder),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: warningText,
                  size: 20,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Jobs priced this low are less likely to be accepted.',
                    style: TextStyle(
                      color: warningText,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _continue,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 9),
            Icon(Icons.arrow_forward_rounded, size: 21),
          ],
        ),
      ),
    );
  }
}
