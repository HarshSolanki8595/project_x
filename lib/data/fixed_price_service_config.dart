// ================================================================
// FIXED-PRICE SERVICE CONFIG -- Helper Services & Cleaning only
// ================================================================
//
// Added 2026-09-02, per Harsh's confirmed pricing model (see
// "Helper Services & Cleaning -- new pricing model" in the master
// to-do doc): these two categories skip professional-quoted bidding
// entirely. Instead, the customer picks a package tier, the app
// shows that tier's price as the starting/floor price, and
// professionals just Accept or Ignore at that posted price -- no
// counter-offers.
//
// REVISED 2026-09-02 (same day): switched from a linear
// "hourly rate x hours + base fee" formula to tiered/package
// pricing, per Harsh's explicit follow-up decision. Each
// subcategory now offers exactly 3 fixed-price tiers instead of a
// computed number -- e.g. Cleaning tiers by property/item size
// (1 BHK / 2 BHK / 3+ BHK), Helper Services mostly tier by duration
// or headcount (2 hrs / 4 hrs / 8 hrs). Tier CRITERIA are
// deliberately subcategory-specific rather than one universal
// Small/Medium/Large label, per Harsh's choice -- a "Medium"
// babysitting booking means nothing on its own, but "4 hours" does.
//
// EVERY PRICE BELOW IS A PLACEHOLDER. None of this has been
// calibrated against real bookings -- it's a reasonable starting
// guess at Indian home-services market rates so the mechanism has
// something real to compute with. Tune tier prices/labels freely;
// nothing else in the app needs to change when you do, since the
// whole pricing engine reads from this one table.
//
// WHAT "FLOOR PRICE" MEANS HERE: there is no separate static floor
// beyond the selected tier's own price. Once the customer picks a
// tier, that tier's price both (a) auto-fills the order's price
// field, and (b) is the threshold a customer-lowered price is
// compared against for the "priced below floor" warning. Flagging
// this reading explicitly, same as with the earlier formula-based
// build -- correct it here if a floor independent of the chosen
// tier was meant instead.
//
// LOCATION is deliberately NOT collected on this screen even though
// it's one of the three required common fields -- the existing,
// unchanged AddressScreen immediately downstream already collects
// it for every request type, so duplicating it here would just be
// the same question asked twice in one flow.
// ================================================================

/// One selectable package for a subcategory -- e.g. "2 BHK" for
/// home cleaning, or "4 Hours" for babysitting.
class PriceTier {
  final String key;
  final String label;
  final String description;
  final double price;

  // Rough duration estimate for this tier, shown to the customer as
  // context and available to the professional -- not itself a price
  // input anymore (the tier's price is fixed), just useful framing.
  final double estimatedHours;

  const PriceTier({
    required this.key,
    required this.label,
    required this.description,
    required this.price,
    this.estimatedHours = 1,
  });
}

class FixedPriceSubCategoryConfig {
  final String subCategoryId;

  // The question shown above the tier picker on the request screen,
  // e.g. "Home size", "Duration", "Number of bathrooms".
  final String tierAxisLabel;

  // Always exactly 3 tiers in this build, ordered smallest/shortest
  // to largest/longest. The middle tier (index 1) is pre-selected
  // as the sensible default when the screen opens.
  final List<PriceTier> tiers;

  const FixedPriceSubCategoryConfig({
    required this.subCategoryId,
    required this.tierAxisLabel,
    required this.tiers,
  });

  PriceTier get defaultTier => tiers.length > 1 ? tiers[1] : tiers.first;

  PriceTier? tierByKey(String key) {
    for (final tier in tiers) {
      if (tier.key == key) return tier;
    }
    return null;
  }
}

class FixedPriceCatalog {
  FixedPriceCatalog._();

  static const Map<String, FixedPriceSubCategoryConfig> configs = {
    // ============================================================
    // CLEANING (17 subcategories)
    // ============================================================
    'home_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'home_cleaning',
      tierAxisLabel: 'Home size',
      tiers: [
        PriceTier(key: '1bhk', label: '1 BHK', description: '1 bedroom, hall, kitchen', price: 499, estimatedHours: 2),
        PriceTier(key: '2bhk', label: '2 BHK', description: '2 bedrooms, hall, kitchen', price: 799, estimatedHours: 3),
        PriceTier(key: '3bhk_plus', label: '3+ BHK', description: '3 or more bedrooms', price: 1199, estimatedHours: 4.5),
      ],
    ),
    'kitchen_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'kitchen_cleaning',
      tierAxisLabel: 'Kitchen size',
      tiers: [
        PriceTier(key: 'compact', label: 'Compact', description: 'Small or galley kitchen', price: 349, estimatedHours: 1.5),
        PriceTier(key: 'standard', label: 'Standard', description: 'Regular modular kitchen', price: 549, estimatedHours: 2.5),
        PriceTier(key: 'large', label: 'Large', description: 'Large or open-plan kitchen', price: 799, estimatedHours: 3.5),
      ],
    ),
    'bathroom_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'bathroom_cleaning',
      tierAxisLabel: 'Number of bathrooms',
      tiers: [
        PriceTier(key: 'one', label: '1 Bathroom', description: 'Single bathroom, full clean', price: 249, estimatedHours: 1),
        PriceTier(key: 'two', label: '2 Bathrooms', description: 'Two bathrooms, full clean', price: 449, estimatedHours: 1.75),
        PriceTier(key: 'three_plus', label: '3+ Bathrooms', description: 'Three or more bathrooms', price: 649, estimatedHours: 2.5),
      ],
    ),
    'sofa_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'sofa_cleaning',
      tierAxisLabel: 'Sofa size',
      tiers: [
        PriceTier(key: 'up_to_3_seater', label: 'Up to 3-Seater', description: 'Single sofa or loveseat', price: 399, estimatedHours: 1.5),
        PriceTier(key: 'five_seater', label: '5-Seater', description: 'Mid-size living room set', price: 599, estimatedHours: 2),
        PriceTier(key: 'seven_seater_plus', label: '7-Seater+ / Sectional', description: 'Large set or L-shaped sectional', price: 899, estimatedHours: 3),
      ],
    ),
    'carpet_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'carpet_cleaning',
      tierAxisLabel: 'Carpet size',
      tiers: [
        PriceTier(key: 'small', label: 'Small', description: 'Up to 5x7 ft', price: 349, estimatedHours: 1),
        PriceTier(key: 'medium', label: 'Medium', description: 'Up to 8x10 ft', price: 549, estimatedHours: 1.5),
        PriceTier(key: 'large', label: 'Large', description: '9x12 ft or bigger', price: 849, estimatedHours: 2.5),
      ],
    ),
    'window_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'window_cleaning',
      tierAxisLabel: 'Number of windows',
      tiers: [
        PriceTier(key: 'up_to_5', label: 'Up to 5 Windows', description: '', price: 299, estimatedHours: 1.5),
        PriceTier(key: 'six_to_10', label: '6-10 Windows', description: '', price: 499, estimatedHours: 2.5),
        PriceTier(key: 'eleven_plus', label: '11+ Windows', description: '', price: 799, estimatedHours: 4),
      ],
    ),
    'water_tank_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'water_tank_cleaning',
      tierAxisLabel: 'Tank size',
      tiers: [
        PriceTier(key: 'small', label: 'Small', description: 'Up to 500 litres', price: 599, estimatedHours: 1.5),
        PriceTier(key: 'medium', label: 'Medium', description: '500-1,000 litres', price: 899, estimatedHours: 2),
        PriceTier(key: 'large', label: 'Large', description: '1,000+ litres', price: 1299, estimatedHours: 3),
      ],
    ),
    'chimney_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'chimney_cleaning',
      tierAxisLabel: 'Cleaning type',
      tiers: [
        PriceTier(key: 'standard', label: 'Standard', description: 'Regular filter + duct clean', price: 699, estimatedHours: 1.5),
        PriceTier(key: 'heavy_duty', label: 'Heavy-Duty / Commercial', description: 'Restaurant or heavy-use chimney', price: 1099, estimatedHours: 2.5),
        PriceTier(key: 'deep_degrease', label: 'Deep Degreasing', description: 'Full strip-down grease removal', price: 1499, estimatedHours: 3.5),
      ],
    ),
    'car_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'car_cleaning',
      tierAxisLabel: 'Vehicle type',
      tiers: [
        PriceTier(key: 'hatchback', label: 'Hatchback', description: '', price: 399, estimatedHours: 1),
        PriceTier(key: 'sedan', label: 'Sedan', description: '', price: 499, estimatedHours: 1.25),
        PriceTier(key: 'suv', label: 'SUV / MUV', description: '', price: 649, estimatedHours: 1.75),
      ],
    ),
    'office_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'office_cleaning',
      tierAxisLabel: 'Office size',
      tiers: [
        PriceTier(key: 'small', label: 'Small', description: 'Up to 1,000 sq ft', price: 999, estimatedHours: 3),
        PriceTier(key: 'medium', label: 'Medium', description: '1,000-3,000 sq ft', price: 1799, estimatedHours: 5),
        PriceTier(key: 'large', label: 'Large', description: '3,000+ sq ft', price: 2999, estimatedHours: 8),
      ],
    ),
    'move_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'move_cleaning',
      tierAxisLabel: 'Property size',
      tiers: [
        PriceTier(key: '1bhk', label: '1 BHK', description: 'Move-in / move-out clean', price: 1299, estimatedHours: 5),
        PriceTier(key: '2bhk', label: '2 BHK', description: 'Move-in / move-out clean', price: 1899, estimatedHours: 7),
        PriceTier(key: '3bhk_plus', label: '3+ BHK', description: 'Move-in / move-out clean', price: 2599, estimatedHours: 10),
      ],
    ),
    'mattress_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'mattress_cleaning',
      tierAxisLabel: 'Mattress size',
      tiers: [
        PriceTier(key: 'single', label: 'Single', description: '', price: 399, estimatedHours: 1),
        PriceTier(key: 'double_queen', label: 'Double / Queen', description: '', price: 549, estimatedHours: 1.5),
        PriceTier(key: 'king', label: 'King', description: '', price: 699, estimatedHours: 2),
      ],
    ),
    'curtain_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'curtain_cleaning',
      tierAxisLabel: 'Number of panels',
      tiers: [
        PriceTier(key: 'up_to_4', label: 'Up to 4 Panels', description: '', price: 349, estimatedHours: 1),
        PriceTier(key: 'five_to_8', label: '5-8 Panels', description: '', price: 599, estimatedHours: 1.75),
        PriceTier(key: 'nine_plus', label: '9+ Panels', description: '', price: 899, estimatedHours: 2.5),
      ],
    ),
    'garden_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'garden_cleaning',
      tierAxisLabel: 'Garden size',
      tiers: [
        PriceTier(key: 'small', label: 'Small', description: 'Up to 500 sq ft', price: 499, estimatedHours: 2),
        PriceTier(key: 'medium', label: 'Medium', description: '500-1,500 sq ft', price: 799, estimatedHours: 3),
        PriceTier(key: 'large', label: 'Large', description: '1,500+ sq ft', price: 1299, estimatedHours: 4.5),
      ],
    ),
    'post_construction_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'post_construction_cleaning',
      tierAxisLabel: 'Property size',
      tiers: [
        PriceTier(key: '1bhk', label: '1 BHK', description: 'Post-construction deep clean', price: 2499, estimatedHours: 6),
        PriceTier(key: '2bhk', label: '2 BHK', description: 'Post-construction deep clean', price: 3499, estimatedHours: 8),
        PriceTier(key: '3bhk_plus_villa', label: '3+ BHK / Villa', description: 'Post-construction deep clean', price: 4999, estimatedHours: 12),
      ],
    ),
    'disinfection_service': FixedPriceSubCategoryConfig(
      subCategoryId: 'disinfection_service',
      tierAxisLabel: 'Space size',
      tiers: [
        PriceTier(key: 'small', label: 'Small', description: 'Up to 1,000 sq ft', price: 799, estimatedHours: 1.5),
        PriceTier(key: 'medium', label: 'Medium', description: '1,000-2,500 sq ft', price: 1299, estimatedHours: 2.5),
        PriceTier(key: 'large', label: 'Large', description: '2,500+ sq ft', price: 1999, estimatedHours: 4),
      ],
    ),
    'general_cleaning': FixedPriceSubCategoryConfig(
      subCategoryId: 'general_cleaning',
      tierAxisLabel: 'Job scope',
      tiers: [
        PriceTier(key: 'light', label: 'Light / Quick Tidy', description: '', price: 349, estimatedHours: 1.5),
        PriceTier(key: 'standard', label: 'Standard Clean', description: '', price: 599, estimatedHours: 2.5),
        PriceTier(key: 'deep', label: 'Deep Clean', description: '', price: 949, estimatedHours: 4),
      ],
    ),

    // ============================================================
    // HELPER SERVICES (15 subcategories)
    // ============================================================
    'maid_fulltime': FixedPriceSubCategoryConfig(
      subCategoryId: 'maid_fulltime',
      tierAxisLabel: 'Hours needed',
      tiers: [
        PriceTier(key: 'half_day', label: 'Half-Day (4 hrs)', description: '', price: 699, estimatedHours: 4),
        PriceTier(key: 'full_day', label: 'Full-Day (8 hrs)', description: '', price: 1299, estimatedHours: 8),
        PriceTier(key: 'live_in', label: 'Live-In (12 hrs)', description: '', price: 1899, estimatedHours: 12),
      ],
    ),
    'maid_parttime': FixedPriceSubCategoryConfig(
      subCategoryId: 'maid_parttime',
      tierAxisLabel: 'Visit duration',
      tiers: [
        PriceTier(key: 'two_hours', label: '2 Hours', description: '', price: 349, estimatedHours: 2),
        PriceTier(key: 'three_hours', label: '3 Hours', description: '', price: 499, estimatedHours: 3),
        PriceTier(key: 'four_hours', label: '4 Hours', description: '', price: 649, estimatedHours: 4),
      ],
    ),
    'cook': FixedPriceSubCategoryConfig(
      subCategoryId: 'cook',
      tierAxisLabel: 'Meal scope',
      tiers: [
        PriceTier(key: 'single_meal', label: 'Single Meal', description: 'One meal, one visit', price: 399, estimatedHours: 2),
        PriceTier(key: 'two_meals', label: 'Two Meals / Day', description: '', price: 699, estimatedHours: 3.5),
        PriceTier(key: 'full_day', label: 'Full-Day (3 Meals)', description: '', price: 999, estimatedHours: 5),
      ],
    ),
    'babysitter': FixedPriceSubCategoryConfig(
      subCategoryId: 'babysitter',
      tierAxisLabel: 'Duration',
      tiers: [
        PriceTier(key: 'two_hours', label: '2 Hours', description: '', price: 399, estimatedHours: 2),
        PriceTier(key: 'four_hours', label: '4 Hours', description: '', price: 699, estimatedHours: 4),
        PriceTier(key: 'full_day', label: '8 Hours / Full-Day', description: '', price: 1299, estimatedHours: 8),
      ],
    ),
    'elderly_care': FixedPriceSubCategoryConfig(
      subCategoryId: 'elderly_care',
      tierAxisLabel: 'Duration',
      tiers: [
        PriceTier(key: 'four_hours', label: '4 Hours', description: '', price: 999, estimatedHours: 4),
        PriceTier(key: 'eight_hours', label: '8 Hours', description: '', price: 1799, estimatedHours: 8),
        PriceTier(key: 'twelve_hours', label: '12 Hours', description: '', price: 2599, estimatedHours: 12),
      ],
    ),
    'driver': FixedPriceSubCategoryConfig(
      subCategoryId: 'driver',
      tierAxisLabel: 'Trip type',
      tiers: [
        PriceTier(key: 'short_trip', label: 'Short Trip', description: 'Up to 2 hours', price: 399, estimatedHours: 2),
        PriceTier(key: 'half_day', label: 'Half-Day', description: 'Up to 4 hours', price: 799, estimatedHours: 4),
        PriceTier(key: 'full_day', label: 'Full-Day', description: '8 hours', price: 1499, estimatedHours: 8),
      ],
    ),
    'dog_walking': FixedPriceSubCategoryConfig(
      subCategoryId: 'dog_walking',
      tierAxisLabel: 'Walk duration',
      tiers: [
        PriceTier(key: 'twenty_min', label: '20 Minutes', description: '', price: 149, estimatedHours: 0.33),
        PriceTier(key: 'thirty_min', label: '30 Minutes', description: '', price: 199, estimatedHours: 0.5),
        PriceTier(key: 'forty_five_plus', label: '45+ Minutes', description: '', price: 299, estimatedHours: 0.75),
      ],
    ),
    'gardener': FixedPriceSubCategoryConfig(
      subCategoryId: 'gardener',
      tierAxisLabel: 'Job scope',
      tiers: [
        PriceTier(key: 'basic', label: 'Basic Upkeep', description: 'Up to 1 hour', price: 349, estimatedHours: 1),
        PriceTier(key: 'standard', label: 'Standard Maintenance', description: 'Up to 2 hours', price: 599, estimatedHours: 2),
        PriceTier(key: 'extensive', label: 'Extensive', description: '3+ hours', price: 899, estimatedHours: 3),
      ],
    ),
    'errand_assistant': FixedPriceSubCategoryConfig(
      subCategoryId: 'errand_assistant',
      tierAxisLabel: 'Task scope',
      tiers: [
        PriceTier(key: 'single_errand', label: 'Single Quick Errand', description: 'Up to 1 hour', price: 249, estimatedHours: 1),
        PriceTier(key: 'multiple_errands', label: 'Multiple Errands', description: 'Up to 2 hours', price: 449, estimatedHours: 2),
        PriceTier(key: 'half_day', label: 'Half-Day Tasks', description: 'Up to 4 hours', price: 799, estimatedHours: 4),
      ],
    ),
    'laundry_ironing': FixedPriceSubCategoryConfig(
      subCategoryId: 'laundry_ironing',
      tierAxisLabel: 'Load size',
      tiers: [
        PriceTier(key: 'small', label: 'Small Load', description: 'Up to 15 pieces', price: 249, estimatedHours: 1),
        PriceTier(key: 'medium', label: 'Medium Load', description: '16-30 pieces', price: 449, estimatedHours: 2),
        PriceTier(key: 'large', label: 'Large Load', description: '30+ pieces', price: 699, estimatedHours: 3),
      ],
    ),
    'night_caregiver': FixedPriceSubCategoryConfig(
      subCategoryId: 'night_caregiver',
      tierAxisLabel: 'Shift length',
      tiers: [
        PriceTier(key: 'six_hour', label: '6-Hour Shift', description: '', price: 1199, estimatedHours: 6),
        PriceTier(key: 'eight_hour', label: '8-Hour Shift', description: '', price: 1599, estimatedHours: 8),
        PriceTier(key: 'ten_hour', label: '10-Hour Shift', description: '', price: 1999, estimatedHours: 10),
      ],
    ),
    'party_cooking': FixedPriceSubCategoryConfig(
      subCategoryId: 'party_cooking',
      tierAxisLabel: 'Guest count',
      tiers: [
        PriceTier(key: 'up_to_10', label: 'Up to 10 Guests', description: '', price: 1499, estimatedHours: 4),
        PriceTier(key: 'eleven_to_25', label: '11-25 Guests', description: '', price: 2499, estimatedHours: 6),
        PriceTier(key: 'twentysix_to_50', label: '26-50 Guests', description: '', price: 3999, estimatedHours: 8),
      ],
    ),
    'pet_grooming': FixedPriceSubCategoryConfig(
      subCategoryId: 'pet_grooming',
      tierAxisLabel: 'Pet size',
      tiers: [
        PriceTier(key: 'small', label: 'Small Pet', description: 'Up to 10 kg', price: 499, estimatedHours: 1),
        PriceTier(key: 'medium', label: 'Medium Pet', description: '10-25 kg', price: 699, estimatedHours: 1.5),
        PriceTier(key: 'large', label: 'Large Pet', description: '25 kg+', price: 999, estimatedHours: 2),
      ],
    ),
    'plant_care': FixedPriceSubCategoryConfig(
      subCategoryId: 'plant_care',
      tierAxisLabel: 'Number of plants',
      tiers: [
        PriceTier(key: 'up_to_10', label: 'Up to 10 Plants', description: '', price: 249, estimatedHours: 0.5),
        PriceTier(key: 'eleven_to_25', label: '11-25 Plants', description: '', price: 399, estimatedHours: 1),
        PriceTier(key: 'twentysix_plus', label: '26+ Plants', description: '', price: 599, estimatedHours: 1.5),
      ],
    ),
    'general_helper': FixedPriceSubCategoryConfig(
      subCategoryId: 'general_helper',
      tierAxisLabel: 'Duration',
      tiers: [
        PriceTier(key: 'two_hours', label: '2 Hours', description: '', price: 349, estimatedHours: 2),
        PriceTier(key: 'four_hours', label: '4 Hours', description: '', price: 599, estimatedHours: 4),
        PriceTier(key: 'full_day', label: '8 Hours / Full-Day', description: '', price: 999, estimatedHours: 8),
      ],
    ),
  };

  static FixedPriceSubCategoryConfig? forSubCategory(String subCategoryId) {
    return configs[subCategoryId];
  }
}
