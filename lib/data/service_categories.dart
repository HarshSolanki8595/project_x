import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/subcategory.dart';

class ServiceCategories {
  static const List<Category> all = [
Category(
  id: 'electrical',
  name: 'Electrical',
  icon: Icons.electrical_services_rounded,
  color: Colors.amber,
  subCategories: [
    SubCategory(
      id: 'fans',
      name: 'Fans',
      icon: Icons.mode_fan_off_rounded,
      description: 'Ceiling, exhaust, wall and pedestal fans.',
      keywords: [
        'fan',
        'ceiling fan',
        'exhaust fan',
        'wall fan',
        'pedestal fan',
      ],
    ),
    SubCategory(
      id: 'lights',
      name: 'Lights & Lighting',
      icon: Icons.lightbulb_outline,
      description: 'Indoor and outdoor lighting.',
      keywords: [
        'light',
        'bulb',
        'led',
        'tube light',
        'lamp',
        'chandelier',
      ],
    ),
    SubCategory(
      id: 'switches',
      name: 'Switches & Sockets',
      icon: Icons.toggle_on_outlined,
      description: 'Switches, sockets and plug points.',
      keywords: [
        'switch',
        'socket',
        'plug',
        'plug point',
        'board',
      ],
    ),
    SubCategory(
      id: 'wiring',
      name: 'Wiring',
      icon: Icons.cable,
      description: 'Electrical wiring and rewiring.',
      keywords: [
        'wire',
        'wiring',
        'rewiring',
        'cable',
      ],
    ),
    SubCategory(
      id: 'distribution_board',
      name: 'Distribution Board (MCB/Fuse)',
      icon: Icons.electrical_services,
      description: 'MCB, fuse and distribution board work.',
      keywords: [
        'mcb',
        'fuse',
        'distribution board',
        'trip',
        'breaker',
      ],
    ),
    SubCategory(
      id: 'inverter',
      name: 'Inverter & UPS',
      icon: Icons.battery_charging_full,
      description: 'Inverter, UPS and battery services.',
      keywords: [
        'inverter',
        'ups',
        'battery',
      ],
    ),
    SubCategory(
      id: 'doorbell',
      name: 'Doorbell & Intercom',
      icon: Icons.doorbell,
      description: 'Doorbell and intercom installation & repair.',
      keywords: [
        'doorbell',
        'intercom',
        'video doorbell',
      ],
    ),
    SubCategory(
      id: 'earthing',
      name: 'Earthing',
      icon: Icons.travel_explore,
      description: 'Earthing and grounding services.',
      keywords: [
        'earthing',
        'grounding',
      ],
    ),
    SubCategory(
      id: 'meter',
      name: 'Electrical Meter',
      icon: Icons.speed,
      description: 'Electrical meter installation & repair.',
      keywords: [
        'meter',
        'electric meter',
      ],
    ),
    SubCategory(
      id: 'inspection',
      name: 'Electrical Inspection & Safety',
      icon: Icons.fact_check_outlined,
      description: 'Electrical inspection and safety checks.',
      keywords: [
        'inspection',
        'audit',
        'safety',
      ],
    ),
    SubCategory(
      id: 'general',
      name: 'General Electrical Issue',
      icon: Icons.help_outline,
      description: 'Not sure? Choose this option.',
      keywords: [
        'electrical',
        'other',
        'unknown',
      ],
    ),
  ],
),
Category(
  id: 'plumbing',
  name: 'Plumbing',
  icon: Icons.plumbing,
  color: Colors.blue,
  subCategories: [
    SubCategory(
      id: 'water_leakage',
      name: 'Water Leakage',
      icon: Icons.water_drop_outlined,
      description: 'Leakage from pipes, taps, walls or ceilings.',
      keywords: [
        'water leak',
        'pipe leak',
        'tap leak',
        'ceiling leak',
        'wall leak',
      ],
    ),
    SubCategory(
      id: 'tap_sink_basin',
      name: 'Tap, Sink & Basin',
      icon: Icons.water,
      description: 'Repair and installation of taps, sinks and basins.',
      keywords: [
        'tap',
        'faucet',
        'sink',
        'wash basin',
        'kitchen sink',
      ],
    ),
    SubCategory(
      id: 'toilet_bathroom',
      name: 'Toilet & Bathroom Fittings',
      icon: Icons.bathtub_outlined,
      description: 'Repair and installation of toilets, flushes, showers and bathroom fittings.',
      keywords: [
        'toilet',
        'commode',
        'flush',
        'shower',
        'jet spray',
        'bathroom',
      ],
    ),
    SubCategory(
      id: 'drainage',
      name: 'Drainage & Blockage',
      icon: Icons.cleaning_services_outlined,
      description: 'Drain, sewer and blockage related work.',
      keywords: [
        'drain',
        'blocked drain',
        'sewer',
        'clog',
        'drainage',
      ],
    ),
    SubCategory(
      id: 'pipes',
      name: 'Pipe Installation & Repair',
      icon: Icons.linear_scale,
      description: 'Installation and repair of water pipelines.',
      keywords: [
        'pipe',
        'pipeline',
        'pipe repair',
        'pipe installation',
      ],
    ),
    SubCategory(
      id: 'tank_pump',
      name: 'Water Tank & Pump',
      icon: Icons.storage,
      description: 'Water tank, pump and motor related services.',
      keywords: [
        'water tank',
        'pump',
        'motor',
        'pressure pump',
      ],
    ),
    SubCategory(
      id: 'geyser_connection',
      name: 'Geyser Installation & Connection',
      icon: Icons.hot_tub_outlined,
      description: 'Water connection and installation for geysers.',
      keywords: [
        'geyser',
        'water heater',
        'geyser installation',
        'geyser connection',
      ],
    ),
    SubCategory(
      id: 'general_plumbing',
      name: 'General Plumbing Issue',
      icon: Icons.help_outline,
      description: 'Not sure? Choose this option.',
      keywords: [
        'plumbing',
        'other',
        'unknown',
      ],
    ),
  ],
),
Category(
  id: 'appliances',
  name: 'Appliances',
  icon: Icons.kitchen_rounded,
  color: Colors.deepPurple,
  subCategories: [
    SubCategory(
      id: 'refrigerator',
      name: 'Refrigerator',
      icon: Icons.kitchen,
      description: 'Refrigerator installation, repair and servicing.',
      keywords: [
        'refrigerator',
        'fridge',
        'freezer',
        'cooling',
      ],
    ),
    SubCategory(
      id: 'washing_machine',
      name: 'Washing Machine',
      icon: Icons.local_laundry_service,
      description: 'Washing machine installation, repair and servicing.',
      keywords: [
        'washing machine',
        'washer',
        'laundry',
        'spin',
      ],
    ),
    SubCategory(
      id: 'air_conditioner',
      name: 'Air Conditioner',
      icon: Icons.ac_unit,
      description: 'AC installation, repair and servicing.',
      keywords: [
        'ac',
        'air conditioner',
        'split ac',
        'window ac',
        'cooling',
      ],
    ),
    SubCategory(
      id: 'water_purifier',
      name: 'Water Purifier (RO)',
      icon: Icons.water_drop_outlined,
      description: 'RO purifier installation, repair and maintenance.',
      keywords: [
        'ro',
        'water purifier',
        'filter',
        'uv',
      ],
    ),
    SubCategory(
      id: 'kitchen_appliances',
      name: 'Kitchen Appliances',
      icon: Icons.microwave,
      description: 'Microwave, OTG, induction cooktop, mixer, grinder, air fryer and similar appliances.',
      keywords: [
        'microwave',
        'oven',
        'otg',
        'induction',
        'cooktop',
        'mixer',
        'grinder',
        'blender',
        'air fryer',
        'rice cooker',
      ],
    ),
    SubCategory(
      id: 'chimney_hob',
      name: 'Chimney & Hob',
      icon: Icons.fireplace_outlined,
      description: 'Kitchen chimney and hob repair, servicing and installation.',
      keywords: [
        'chimney',
        'kitchen chimney',
        'hob',
        'gas hob',
      ],
    ),
    SubCategory(
      id: 'dishwasher',
      name: 'Dishwasher',
      icon: Icons.cleaning_services_outlined,
      description: 'Dishwasher installation, servicing and repair.',
      keywords: [
        'dishwasher',
        'dish washer',
      ],
    ),
    SubCategory(
      id: 'vacuum_cleaner',
      name: 'Vacuum Cleaner',
      icon: Icons.cleaning_services,
      description: 'Vacuum cleaner repair and servicing.',
      keywords: [
        'vacuum',
        'vacuum cleaner',
      ],
    ),
    SubCategory(
      id: 'general_appliance',
      name: 'General Appliance Issue',
      icon: Icons.help_outline,
      description: 'Not sure? Choose this option.',
      keywords: [
        'appliance',
        'other',
        'unknown',
      ],
    ),
  ],
),
Category(
  id: 'carpentry',
  name: 'Carpentry',
  icon: Icons.handyman,
  color: Colors.brown,
  subCategories: [
    SubCategory(
      id: 'doors',
      name: 'Doors',
      icon: Icons.door_front_door,
      description: 'Door installation, repair and adjustments.',
      keywords: [
        'door',
        'wooden door',
        'main door',
        'door repair',
        'door installation',
      ],
    ),
    SubCategory(
      id: 'windows',
      name: 'Windows',
      icon: Icons.window,
      description: 'Wooden window installation and repair.',
      keywords: [
        'window',
        'wooden window',
        'window repair',
      ],
    ),
    SubCategory(
      id: 'furniture',
      name: 'Furniture',
      icon: Icons.chair,
      description: 'Repair and assembly of wooden furniture.',
      keywords: [
        'furniture',
        'chair',
        'table',
        'bed',
        'sofa',
        'cupboard',
      ],
    ),
    SubCategory(
      id: 'wardrobes',
      name: 'Wardrobes & Cabinets',
      icon: Icons.inventory_2_outlined,
      description: 'Wardrobe, cabinet and storage unit services.',
      keywords: [
        'wardrobe',
        'cabinet',
        'closet',
        'storage',
      ],
    ),
    SubCategory(
      id: 'kitchen',
      name: 'Kitchen Woodwork',
      icon: Icons.kitchen,
      description: 'Kitchen cabinets and modular kitchen woodwork.',
      keywords: [
        'kitchen',
        'modular kitchen',
        'cabinet',
      ],
    ),
    SubCategory(
      id: 'locks',
      name: 'Locks & Hinges',
      icon: Icons.lock_outline,
      description: 'Replacement and repair of locks, handles and hinges.',
      keywords: [
        'lock',
        'hinge',
        'handle',
        'door lock',
      ],
    ),
    SubCategory(
      id: 'wood_polish',
      name: 'Wood Polish & Finishing',
      icon: Icons.format_paint,
      description: 'Polishing, varnishing and finishing of wooden surfaces.',
      keywords: [
        'polish',
        'varnish',
        'wood finish',
      ],
    ),
    SubCategory(
      id: 'general_carpentry',
      name: 'General Carpentry Issue',
      icon: Icons.help_outline,
      description: 'Not sure? Choose this option.',
      keywords: [
        'carpentry',
        'woodwork',
        'other',
        'unknown',
      ],
    ),
  ],
),
Category(
  id: 'cleaning',
  name: 'Cleaning',
  icon: Icons.cleaning_services,
  color: Colors.teal,
  // Quick Service (2026-09-01) -- see Category.isQuickService.
  isQuickService: true,
  subCategories: [
    SubCategory(id: 'home_cleaning', name: 'Home Deep Cleaning', icon: Icons.home, description: 'Complete home deep cleaning.', keywords: ['home','deep cleaning']),
    SubCategory(id: 'kitchen_cleaning', name: 'Kitchen Cleaning', icon: Icons.kitchen, description: 'Kitchen cleaning services.', keywords: ['kitchen','chimney']),
    SubCategory(id: 'bathroom_cleaning', name: 'Bathroom Cleaning', icon: Icons.bathtub_outlined, description: 'Bathroom deep cleaning.', keywords: ['bathroom','toilet']),
    SubCategory(id: 'sofa_cleaning', name: 'Sofa & Upholstery', icon: Icons.weekend, description: 'Sofa and upholstery cleaning.', keywords: ['sofa','upholstery']),
    SubCategory(id: 'carpet_cleaning', name: 'Carpet & Mattress', icon: Icons.bed_outlined, description: 'Carpet and mattress cleaning.', keywords: ['carpet','mattress']),
    SubCategory(id: 'window_cleaning', name: 'Window Cleaning', icon: Icons.window, description: 'Glass and window cleaning.', keywords: ['window','glass']),
    SubCategory(id: 'water_tank_cleaning', name: 'Water Tank Cleaning', icon: Icons.water_drop, description: 'Water tank cleaning.', keywords: ['tank']),
    // -- New 2026-09-01, from the finalized taxonomy (see the
    // habio-master-todo project doc, "Core product & UI backlog").
    // New ids only -- every id above this line is untouched, so no
    // already-onboarded professional's subcategoryIds selection breaks.
    SubCategory(id: 'chimney_cleaning', name: 'Chimney Cleaning', icon: Icons.fireplace_outlined, description: 'Kitchen chimney cleaning and degreasing.', keywords: ['chimney']),
    SubCategory(id: 'car_cleaning', name: 'Car Cleaning & Detailing', icon: Icons.local_car_wash, description: 'Doorstep car cleaning and detailing.', keywords: ['car','detailing']),
    SubCategory(id: 'office_cleaning', name: 'Office & Commercial Cleaning', icon: Icons.business, description: 'Office and commercial space cleaning.', keywords: ['office','commercial']),
    SubCategory(id: 'move_cleaning', name: 'Move-In / Move-Out Cleaning', icon: Icons.inventory_2_outlined, description: 'Deep cleaning before moving in or after moving out.', keywords: ['move in','move out','shifting']),
    SubCategory(id: 'mattress_cleaning', name: 'Mattress Cleaning', icon: Icons.bed, description: 'Mattress deep cleaning and sanitization.', keywords: ['mattress']),
    SubCategory(id: 'curtain_cleaning', name: 'Curtain Cleaning', icon: Icons.local_laundry_service, description: 'Curtain and drape cleaning.', keywords: ['curtain','drapes']),
    SubCategory(id: 'garden_cleaning', name: 'Garden & Lawn Cleaning', icon: Icons.grass, description: 'Garden and lawn clean-up.', keywords: ['garden','lawn']),
    SubCategory(id: 'post_construction_cleaning', name: 'Post-Construction Cleaning', icon: Icons.construction, description: 'Deep cleaning after construction or renovation work.', keywords: ['construction','renovation']),
    SubCategory(id: 'disinfection_service', name: 'Disinfection & Sanitization', icon: Icons.cleaning_services, description: 'Disinfection and sanitization service.', keywords: ['disinfection','sanitization']),
    SubCategory(id: 'general_cleaning', name: 'General Cleaning Service', icon: Icons.help_outline, description: 'Other cleaning services.', keywords: ['cleaning']),
  ],
),
Category(
  id: 'helper_services',
  name: 'Helper Services',
  icon: Icons.people_alt,
  color: Colors.cyan,
  // Quick Service (2026-09-01) -- see Category.isQuickService. Brand
  // new category, from the finalized taxonomy PDF. Several
  // subcategories are marked [SENSITIVE] there and will need the
  // enhanced verification path once that build item ships (see
  // "core-doc-verification" on the Build Queue) -- no gating exists
  // yet, so nothing changes here for those specifically.
  isQuickService: true,
  subCategories: [
    SubCategory(id: 'maid_fulltime', name: 'Full-Time Maid / Domestic Help', icon: Icons.home, description: 'Full-time domestic help.', keywords: ['maid','domestic help','full time']),
    SubCategory(id: 'maid_parttime', name: 'Part-Time Maid / Domestic Help', icon: Icons.cleaning_services, description: 'Part-time domestic help.', keywords: ['maid','domestic help','part time']),
    SubCategory(id: 'cook', name: 'Cook (Daily / Occasional)', icon: Icons.kitchen, description: 'Daily or occasional cooking help.', keywords: ['cook','cooking']),
    SubCategory(id: 'babysitter', name: 'Babysitter / Nanny', icon: Icons.child_care, description: 'Babysitting and nanny services.', keywords: ['babysitter','nanny','childcare']),
    SubCategory(id: 'elderly_care', name: 'Elderly / Patient Care Attendant', icon: Icons.accessible, description: 'Elderly and patient care attendance.', keywords: ['elderly care','patient care','attendant']),
    SubCategory(id: 'driver', name: 'Driver on Hire', icon: Icons.directions_car, description: 'On-hire driver services.', keywords: ['driver']),
    SubCategory(id: 'dog_walking', name: 'Dog Walking / Pet Care', icon: Icons.pets, description: 'Dog walking and pet care.', keywords: ['dog walking','pet care']),
    SubCategory(id: 'gardener', name: 'Gardener / Lawn Helper', icon: Icons.grass, description: 'Gardening and lawn help.', keywords: ['gardener','lawn']),
    SubCategory(id: 'errand_assistant', name: 'Errand Running / Personal Assistant', icon: Icons.assignment, description: 'Errands and personal assistance.', keywords: ['errand','personal assistant']),
    SubCategory(id: 'laundry_ironing', name: 'Laundry & Ironing Help', icon: Icons.local_laundry_service, description: 'Laundry and ironing help.', keywords: ['laundry','ironing']),
    SubCategory(id: 'night_caregiver', name: 'Night Nurse / Caregiver', icon: Icons.nightlight_round, description: 'Overnight nursing and caregiving.', keywords: ['night nurse','caregiver']),
    SubCategory(id: 'party_cooking', name: 'Event / Party Cooking Help', icon: Icons.restaurant, description: 'Cooking help for events and parties.', keywords: ['party cooking','event cooking']),
    SubCategory(id: 'pet_grooming', name: 'Pet Grooming', icon: Icons.content_cut, description: 'Pet grooming at home.', keywords: ['pet grooming']),
    SubCategory(id: 'plant_care', name: 'Plant Watering / Care Service', icon: Icons.local_florist, description: 'Plant watering and care.', keywords: ['plant care','watering']),
    SubCategory(id: 'general_helper', name: 'General Helper Service', icon: Icons.help_outline, description: 'Not sure? Choose this option.', keywords: ['helper','other','unknown']),
  ],
),
Category(
  id: 'painting',
  name: 'Painting',
  icon: Icons.format_paint,
  color: Colors.orange,
  subCategories: [
    SubCategory(id: 'interior', name: 'Interior Painting', icon: Icons.home, description: 'Interior wall painting.', keywords: ['interior']),
    SubCategory(id: 'exterior', name: 'Exterior Painting', icon: Icons.house_outlined, description: 'Exterior painting.', keywords: ['exterior']),
    SubCategory(id: 'texture', name: 'Texture & Designer Paint', icon: Icons.brush, description: 'Designer wall finishes.', keywords: ['texture']),
    SubCategory(id: 'waterproofing', name: 'Waterproofing', icon: Icons.water_damage_outlined, description: 'Waterproof coating.', keywords: ['waterproof']),
    SubCategory(id: 'putty', name: 'Wall Putty', icon: Icons.layers_outlined, description: 'Wall putty services.', keywords: ['putty']),
    SubCategory(id: 'wallpaper', name: 'Wallpaper', icon: Icons.wallpaper, description: 'Wallpaper installation.', keywords: ['wallpaper']),
    SubCategory(id: 'wood_finish', name: 'Wood Polish & Finish', icon: Icons.format_color_fill, description: 'Wood polishing.', keywords: ['polish']),
    SubCategory(id: 'general_painting', name: 'General Painting Service', icon: Icons.help_outline, description: 'Other painting work.', keywords: ['painting']),
  ],
),
Category(
  id: 'pest_control',
  name: 'Pest Control',
  icon: Icons.bug_report,
  color: Colors.green,
  subCategories: [
    SubCategory(id: 'cockroach', name: 'Cockroach Control', icon: Icons.pest_control, description: 'Cockroach treatment.', keywords: ['cockroach']),
    SubCategory(id: 'termite', name: 'Termite Control', icon: Icons.grass, description: 'Termite treatment.', keywords: ['termite']),
    SubCategory(id: 'rodent', name: 'Rodent Control', icon: Icons.pets, description: 'Rat & mouse control.', keywords: ['rat','mouse']),
    SubCategory(id: 'mosquito', name: 'Mosquito & Fly Control', icon: Icons.air, description: 'Flying insect treatment.', keywords: ['mosquito','fly']),
    SubCategory(id: 'bedbug', name: 'Bed Bug Treatment', icon: Icons.bed, description: 'Bed bug removal.', keywords: ['bed bug']),
    SubCategory(id: 'ants', name: 'Ant Control', icon: Icons.bug_report_outlined, description: 'Ant removal.', keywords: ['ant']),
    SubCategory(id: 'bird', name: 'Bird & Pigeon Control', icon: Icons.flutter_dash, description: 'Bird control.', keywords: ['bird','pigeon']),
    SubCategory(id: 'general_pest', name: 'General Pest Control', icon: Icons.help_outline, description: 'Other pest issues.', keywords: ['pest']),
  ],
),
Category(
  id: 'home_repair',
  name: 'Home Repair',
  icon: Icons.home_repair_service,
  color: Colors.red,
  subCategories: [
    SubCategory(id: 'glass', name: 'Glass Repair', icon: Icons.window, description: 'Glass installation & repair.', keywords: ['glass']),
    SubCategory(id: 'aluminium', name: 'Aluminium Work', icon: Icons.construction, description: 'Aluminium fabrication.', keywords: ['aluminium']),
    SubCategory(id: 'tiles', name: 'Tiles & Flooring', icon: Icons.grid_view, description: 'Tile and flooring work.', keywords: ['tiles']),
    SubCategory(id: 'ceiling', name: 'Ceiling Repair', icon: Icons.architecture, description: 'False ceiling and repairs.', keywords: ['ceiling']),
    SubCategory(id: 'masonry', name: 'Masonry & Civil Work', icon: Icons.foundation, description: 'Brick and cement work.', keywords: ['masonry']),
    SubCategory(id: 'roof', name: 'Roofing Repairs', icon: Icons.roofing, description: 'Roof repair.', keywords: ['roof']),
    SubCategory(id: 'hardware', name: 'Lock & Hardware Repair', icon: Icons.lock_outline, description: 'Door hardware repair.', keywords: ['lock']),
    SubCategory(id: 'general_home', name: 'General Home Repair', icon: Icons.help_outline, description: 'Other home repairs.', keywords: ['repair']),
  ],
),
Category(
  id: 'automobile',
  name: 'Automobile',
  icon: Icons.directions_car,
  color: Colors.indigo,
  subCategories: [
    SubCategory(id: 'car', name: 'Car Repair', icon: Icons.directions_car, description: 'Car repairs.', keywords: ['car']),
    SubCategory(id: 'bike', name: 'Bike Repair', icon: Icons.two_wheeler, description: 'Bike repairs.', keywords: ['bike']),
    SubCategory(id: 'battery', name: 'Battery Service', icon: Icons.battery_full, description: 'Battery replacement.', keywords: ['battery']),
    SubCategory(id: 'tyre', name: 'Tyre & Puncture', icon: Icons.tire_repair, description: 'Tyre repair.', keywords: ['tyre']),
    SubCategory(id: 'wash', name: 'Car Wash & Detailing', icon: Icons.local_car_wash, description: 'Vehicle cleaning.', keywords: ['wash']),
    SubCategory(id: 'oil', name: 'Oil Change', icon: Icons.opacity, description: 'Engine oil replacement.', keywords: ['oil']),
    SubCategory(id: 'inspection', name: 'Vehicle Inspection', icon: Icons.fact_check, description: 'Vehicle inspection.', keywords: ['inspection']),
    SubCategory(id: 'general_auto', name: 'General Automobile Service', icon: Icons.help_outline, description: 'Other automobile work.', keywords: ['automobile']),
  ],
),
Category(
  id: 'moving',
  name: 'Moving',
  icon: Icons.local_shipping,
  color: Colors.deepOrange,
  subCategories: [
    SubCategory(id: 'house', name: 'House Shifting', icon: Icons.home, description: 'Home relocation.', keywords: ['house']),
    SubCategory(id: 'office', name: 'Office Relocation', icon: Icons.business, description: 'Office shifting.', keywords: ['office']),
    SubCategory(id: 'packers', name: 'Packers & Movers', icon: Icons.inventory, description: 'Packing services.', keywords: ['packers']),
    SubCategory(id: 'furniture', name: 'Furniture Moving', icon: Icons.chair, description: 'Furniture shifting.', keywords: ['furniture']),
    SubCategory(id: 'appliance', name: 'Appliance Relocation', icon: Icons.kitchen, description: 'Move appliances safely.', keywords: ['appliance']),
    SubCategory(id: 'loading', name: 'Loading & Unloading', icon: Icons.move_up, description: 'Loading assistance.', keywords: ['loading']),
    SubCategory(id: 'storage', name: 'Storage Services', icon: Icons.warehouse, description: 'Temporary storage.', keywords: ['storage']),
    SubCategory(id: 'general_move', name: 'General Moving Service', icon: Icons.help_outline, description: 'Other moving services.', keywords: ['moving']),
  ],
),
Category(
  id: 'beauty',
  name: 'Beauty',
  icon: Icons.face,
  color: Colors.pink,
  subCategories: [
    SubCategory(id: 'salon', name: 'Salon at Home', icon: Icons.content_cut, description: 'Salon services.', keywords: ['salon']),
    SubCategory(id: 'hair', name: 'Hair Services', icon: Icons.face_retouching_natural, description: 'Haircut & styling.', keywords: ['hair']),
    SubCategory(id: 'makeup', name: 'Makeup', icon: Icons.brush, description: 'Professional makeup.', keywords: ['makeup']),
    SubCategory(id: 'facial', name: 'Facials & Skincare', icon: Icons.spa, description: 'Facials and skincare.', keywords: ['facial']),
    SubCategory(id: 'waxing', name: 'Waxing & Threading', icon: Icons.auto_fix_high, description: 'Waxing services.', keywords: ['waxing']),
    SubCategory(id: 'nails', name: 'Manicure & Pedicure', icon: Icons.pan_tool, description: 'Nail care.', keywords: ['manicure']),
    SubCategory(id: 'massage', name: 'Massage & Spa', icon: Icons.self_improvement, description: 'Spa and massage.', keywords: ['massage']),
    SubCategory(id: 'general_beauty', name: 'General Beauty Service', icon: Icons.help_outline, description: 'Other beauty services.', keywords: ['beauty']),
  ],
),
// ============================================================
// NEW CATEGORIES -- added 2026-09-01, from the finalized 17-category
// taxonomy PDF. Metal Fabrication, Glass Work, Fabric & Tailoring
// Services and Decoration/Event Services complete the list; Any Other
// Service is the closing catch-all. Every category below carries its
// own "General ... Issue" catch-all subcategory, same convention as
// every category above -- Harsh asked for this explicitly.
//
// Mirrored 1:1 (same ids/names) into ProfessionalServiceCategories in
// professional_onboarding_screen.dart -- see the "Category /
// subcategory taxonomy" note in the project doc for why that matters.
// ============================================================
Category(
  id: 'metal_fabrication',
  name: 'Metal Fabrication',
  icon: Icons.construction,
  color: Colors.blueGrey,
  subCategories: [
    SubCategory(id: 'grill_gate_fabrication', name: 'Grill & Gate Fabrication and Repair', icon: Icons.door_front_door, description: 'Grill and gate fabrication and repair.', keywords: ['grill', 'gate']),
    SubCategory(id: 'aluminium_window_door', name: 'Aluminium Window & Door Fabrication', icon: Icons.window, description: 'Aluminium window and door fabrication.', keywords: ['aluminium', 'window', 'door']),
    SubCategory(id: 'onsite_welding', name: 'On-Site Welding Services', icon: Icons.local_fire_department, description: 'On-site welding services.', keywords: ['welding']),
    SubCategory(id: 'staircase_railing_fabrication', name: 'Staircase & Railing Fabrication', icon: Icons.stairs, description: 'Staircase and railing fabrication.', keywords: ['staircase', 'railing']),
    SubCategory(id: 'shed_shelter_fabrication', name: 'Shed / Shelter Structure Fabrication', icon: Icons.warehouse, description: 'Shed and shelter structure fabrication.', keywords: ['shed', 'shelter']),
    SubCategory(id: 'gate_automation', name: 'Gate Automation (Motorized Gates)', icon: Icons.bolt, description: 'Motorized gate automation.', keywords: ['gate automation', 'motorized gate']),
    SubCategory(id: 'metal_furniture_fabrication', name: 'Metal Furniture Fabrication', icon: Icons.chair, description: 'Metal furniture fabrication.', keywords: ['metal furniture']),
    SubCategory(id: 'collapsible_gate_repair', name: 'Collapsible Gate Repair / Installation', icon: Icons.garage, description: 'Collapsible gate repair and installation.', keywords: ['collapsible gate']),
    SubCategory(id: 'rolling_shutter_repair', name: 'Rolling Shutter Repair / Installation', icon: Icons.window, description: 'Rolling shutter repair and installation.', keywords: ['rolling shutter']),
    SubCategory(id: 'steel_almirah_fabrication', name: 'Steel Almirah / Storage Unit Fabrication', icon: Icons.inventory_2_outlined, description: 'Steel almirah and storage unit fabrication.', keywords: ['steel almirah', 'storage unit']),
    SubCategory(id: 'stainless_steel_kitchen_fabrication', name: 'Stainless Steel Kitchen Fabrication', icon: Icons.kitchen, description: 'Stainless steel kitchen fabrication.', keywords: ['stainless steel kitchen']),
    SubCategory(id: 'security_grill_fabrication', name: 'Security Grill Design & Fabrication', icon: Icons.security, description: 'Security grill design and fabrication.', keywords: ['security grill']),
    SubCategory(id: 'gate_hinge_fitting_repair', name: 'Gate Hinge & Fitting Repair', icon: Icons.lock_outline, description: 'Gate hinge and fitting repair.', keywords: ['gate hinge', 'fitting']),
    SubCategory(id: 'industrial_rack_fabrication', name: 'Industrial / Warehouse Rack Fabrication', icon: Icons.inventory, description: 'Industrial and warehouse rack fabrication.', keywords: ['industrial rack', 'warehouse rack']),
    SubCategory(id: 'general_metal_fabrication', name: 'General Metal Fabrication Issue', icon: Icons.help_outline, description: 'Not sure? Choose this option.', keywords: ['metal fabrication', 'other', 'unknown']),
  ],
),
Category(
  id: 'glass_work',
  name: 'Glass Work',
  icon: Icons.window,
  color: Colors.lightBlueAccent,
  subCategories: [
    SubCategory(id: 'glass_door_partition', name: 'Glass Door & Partition Installation', icon: Icons.door_front_door, description: 'Glass door and partition installation.', keywords: ['glass door', 'partition']),
    SubCategory(id: 'mirror_installation', name: 'Mirror Installation & Repair', icon: Icons.crop_original, description: 'Mirror installation and repair.', keywords: ['mirror']),
    SubCategory(id: 'glass_window_installation', name: 'Glass Window Installation / Replacement', icon: Icons.window, description: 'Glass window installation and replacement.', keywords: ['glass window']),
    SubCategory(id: 'shower_cubicle_glass', name: 'Shower Cubicle / Glass Enclosure Installation', icon: Icons.bathtub_outlined, description: 'Shower cubicle and glass enclosure installation.', keywords: ['shower cubicle', 'glass enclosure']),
    SubCategory(id: 'glass_tabletop_shelf', name: 'Glass Tabletop & Shelf Installation', icon: Icons.inventory_2_outlined, description: 'Glass tabletop and shelf installation.', keywords: ['glass tabletop', 'glass shelf']),
    SubCategory(id: 'toughened_glass_installation', name: 'Toughened Glass Installation', icon: Icons.shield_outlined, description: 'Toughened glass installation.', keywords: ['toughened glass']),
    SubCategory(id: 'glass_railing_installation', name: 'Glass Railing Installation', icon: Icons.stairs, description: 'Glass railing installation.', keywords: ['glass railing']),
    SubCategory(id: 'custom_glass_cutting', name: 'Custom Glass Cutting & Fitting', icon: Icons.content_cut, description: 'Custom glass cutting and fitting.', keywords: ['glass cutting']),
    SubCategory(id: 'cracked_glass_repair', name: 'Cracked / Broken Glass Repair & Replacement', icon: Icons.broken_image_outlined, description: 'Cracked and broken glass repair and replacement.', keywords: ['cracked glass', 'broken glass']),
    SubCategory(id: 'glass_balcony_fabrication', name: 'Glass Balcony Fabrication', icon: Icons.balcony, description: 'Glass balcony fabrication.', keywords: ['glass balcony']),
    SubCategory(id: 'glass_canopy_installation', name: 'Glass Canopy Installation', icon: Icons.roofing, description: 'Glass canopy installation.', keywords: ['glass canopy']),
    SubCategory(id: 'acrylic_sheet_installation', name: 'Acrylic Sheet Installation', icon: Icons.layers_outlined, description: 'Acrylic sheet installation.', keywords: ['acrylic sheet']),
    SubCategory(id: 'glass_film_tinting', name: 'Glass Film / Tinting Application', icon: Icons.opacity, description: 'Glass film and tinting application.', keywords: ['glass film', 'tinting']),
    SubCategory(id: 'showcase_cabinet_glass_repair', name: 'Showcase / Cabinet Glass Repair', icon: Icons.inventory_2_outlined, description: 'Showcase and cabinet glass repair.', keywords: ['showcase glass', 'cabinet glass']),
    SubCategory(id: 'general_glass_work', name: 'General Glass Work Issue', icon: Icons.help_outline, description: 'Not sure? Choose this option.', keywords: ['glass work', 'other', 'unknown']),
  ],
),
Category(
  id: 'fabric_tailoring',
  name: 'Fabric & Tailoring Services',
  icon: Icons.checkroom,
  color: Colors.purple,
  subCategories: [
    SubCategory(id: 'blouse_stitching', name: 'Blouse Stitching', icon: Icons.checkroom, description: 'Blouse stitching.', keywords: ['blouse stitching']),
    SubCategory(id: 'alteration_resizing', name: 'Alteration & Resizing of Clothes', icon: Icons.straighten, description: 'Alteration and resizing of clothes.', keywords: ['alteration', 'resizing']),
    SubCategory(id: 'custom_suit_dress_stitching', name: 'Custom Suit / Dress Stitching', icon: Icons.checkroom, description: 'Custom suit and dress stitching.', keywords: ['suit stitching', 'dress stitching']),
    SubCategory(id: 'curtain_stitching', name: 'Curtain Stitching', icon: Icons.local_laundry_service, description: 'Curtain stitching.', keywords: ['curtain stitching']),
    SubCategory(id: 'sofa_cover_stitching', name: 'Sofa Cover / Cushion Cover Stitching', icon: Icons.weekend, description: 'Sofa cover and cushion cover stitching.', keywords: ['sofa cover', 'cushion cover']),
    SubCategory(id: 'embroidery_designing', name: 'Embroidery & Designing Work', icon: Icons.brush, description: 'Embroidery and designing work.', keywords: ['embroidery']),
    SubCategory(id: 'uniform_stitching', name: 'School / Corporate Uniform Stitching', icon: Icons.checkroom, description: 'School and corporate uniform stitching.', keywords: ['uniform stitching']),
    SubCategory(id: 'saree_fall_pico', name: 'Saree Fall & Pico Work', icon: Icons.content_cut, description: 'Saree fall and pico work.', keywords: ['saree fall', 'pico']),
    SubCategory(id: 'zipper_button_repair', name: 'Zipper & Button Repair', icon: Icons.build, description: 'Zipper and button repair.', keywords: ['zipper', 'button repair']),
    SubCategory(id: 'bag_leather_repair', name: 'Bag & Leather Goods Repair', icon: Icons.work_outline, description: 'Bag and leather goods repair.', keywords: ['bag repair', 'leather repair']),
    SubCategory(id: 'general_fabric_tailoring', name: 'General Tailoring Service', icon: Icons.help_outline, description: 'Not sure? Choose this option.', keywords: ['tailoring', 'other', 'unknown']),
  ],
),
Category(
  id: 'decoration_events',
  name: 'Decoration & Event Services',
  icon: Icons.celebration,
  color: Colors.purpleAccent,
  subCategories: [
    SubCategory(id: 'birthday_party_decoration', name: 'Birthday Party Decoration', icon: Icons.cake, description: 'Birthday party decoration.', keywords: ['birthday decoration']),
    SubCategory(id: 'wedding_engagement_decoration', name: 'Wedding / Engagement Decoration', icon: Icons.favorite_border, description: 'Wedding and engagement decoration.', keywords: ['wedding decoration', 'engagement decoration']),
    SubCategory(id: 'balloon_decoration', name: 'Balloon Decoration', icon: Icons.celebration, description: 'Balloon decoration.', keywords: ['balloon decoration']),
    SubCategory(id: 'flower_decoration', name: 'Flower Decoration', icon: Icons.local_florist, description: 'Flower decoration.', keywords: ['flower decoration']),
    SubCategory(id: 'corporate_event_setup', name: 'Corporate Event Setup', icon: Icons.business, description: 'Corporate event setup.', keywords: ['corporate event']),
    SubCategory(id: 'festival_pooja_decoration', name: 'Festival / Pooja Decoration', icon: Icons.celebration, description: 'Festival and pooja decoration.', keywords: ['festival decoration', 'pooja decoration']),
    SubCategory(id: 'photography_videography', name: 'Photography & Videography', icon: Icons.camera_alt, description: 'Photography and videography.', keywords: ['photography', 'videography']),
    SubCategory(id: 'catering_coordination', name: 'Catering Coordination', icon: Icons.restaurant, description: 'Catering coordination.', keywords: ['catering']),
    SubCategory(id: 'tent_canopy_setup', name: 'Tent / Canopy Setup', icon: Icons.roofing, description: 'Tent and canopy setup.', keywords: ['tent setup', 'canopy setup']),
    SubCategory(id: 'dj_sound_setup', name: 'DJ & Sound Setup', icon: Icons.music_note, description: 'DJ and sound setup.', keywords: ['dj', 'sound setup']),
    SubCategory(id: 'stage_entrance_arch_decoration', name: 'Stage & Entrance Arch Decoration', icon: Icons.theater_comedy, description: 'Stage and entrance arch decoration.', keywords: ['stage decoration', 'entrance arch']),
    SubCategory(id: 'fairy_light_installation', name: 'Fairy Light / String Light Installation', icon: Icons.lightbulb_outline, description: 'Fairy light and string light installation.', keywords: ['fairy lights', 'string lights']),
    SubCategory(id: 'drone_photography', name: 'Drone Photography', icon: Icons.flight, description: 'Drone photography.', keywords: ['drone photography']),
    SubCategory(id: 'general_decoration_events', name: 'General Decoration Service', icon: Icons.help_outline, description: 'Not sure? Choose this option.', keywords: ['decoration', 'events', 'other', 'unknown']),
  ],
),
  ];

  static Category? getCategoryById(String id) {
    try {
      return all.firstWhere((category) => category.id == id);
    } catch (_) {
      return null;
    }
  }

  static Category? getCategoryByName(String name) {
    try {
      return all.firstWhere((category) => category.name == name);
    } catch (_) {
      return null;
    }
  }
}