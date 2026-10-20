import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/subcategory.dart';
import 'icon_registry.dart';

class ServiceCategories {
  static const List<Category> _hardcoded = [
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
    // -- Added 2026-09-16, from the finalized taxonomy PDF
    // (habio_categories_subcategories_final.pdf). New ids only --
    // every id above this line is untouched, so no already-
    // onboarded professional's subcategoryIds selection breaks.
    SubCategory(id: 'generator_repair', name: 'Generator Repair', icon: Icons.power, description: 'Generator repair and servicing.', keywords: ['generator']),
    SubCategory(id: 'appliance_electrical_fault', name: 'Appliance Electrical Fault Diagnosis', icon: Icons.build_circle_outlined, description: 'Diagnosing electrical faults in home appliances.', keywords: ['appliance fault', 'electrical diagnosis']),
    SubCategory(id: 'cctv_installation', name: 'CCTV Camera Installation', icon: Icons.videocam_outlined, description: 'CCTV camera installation and setup.', keywords: ['cctv', 'camera', 'security camera']),
    SubCategory(id: 'smart_switch_automation', name: 'Smart Switch / Home Automation Setup', icon: Icons.home_max_outlined, description: 'Smart switch and home automation setup.', keywords: ['smart switch', 'home automation', 'smart home']),
    SubCategory(id: 'solar_panel_installation', name: 'Solar Panel Installation & Wiring', icon: Icons.solar_power_outlined, description: 'Solar panel installation and wiring.', keywords: ['solar panel', 'solar']),
    SubCategory(id: 'ac_electrical_point', name: 'AC Electrical Point Installation', icon: Icons.ac_unit, description: 'Dedicated electrical point installation for AC units.', keywords: ['ac point', 'ac electrical']),
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
    // -- Geyser Installation & Connection (id 'geyser_connection')
    // removed 2026-10-01 -- duplicate-work cleanup. Geyser work is
    // now one listing under Appliances' 'geyser_repair' subcategory
    // (renamed to Geyser Installation & Repair, keywords merged in
    // from this entry), with Plumbing tagged as a related category
    // there so a Plumbing professional can still pick it up as a
    // skill.
    // -- Added 2026-09-16, from the finalized taxonomy PDF
    // (habio_categories_subcategories_final.pdf). New ids only --
    // every id above this line is untouched, so no already-
    // onboarded professional's subcategoryIds selection breaks.
    SubCategory(id: 'water_purifier_plumbing_connection', name: 'Water Purifier Plumbing Connection', icon: Icons.water_drop_outlined, description: 'Plumbing connection for water purifiers/RO systems.', keywords: ['water purifier connection', 'ro connection']),
    SubCategory(id: 'water_softener_installation', name: 'Water Softener Installation', icon: Icons.opacity, description: 'Water softener installation.', keywords: ['water softener']),
    SubCategory(id: 'new_construction_pipeline_fitting', name: 'New Construction Pipeline Fitting', icon: Icons.plumbing, description: 'Pipeline fitting for new construction projects.', keywords: ['new construction', 'pipeline fitting']),
    SubCategory(id: 'borewell_pump_repair', name: 'Borewell Pump Repair', icon: Icons.water, description: 'Borewell pump repair and servicing.', keywords: ['borewell', 'borewell pump']),
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
      matchGroup: 'cooling',
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
      matchGroup: 'washing',
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
      matchGroup: 'cooling',
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
      matchGroup: 'water_heating',
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
      matchGroup: 'kitchen',
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
      matchGroup: 'kitchen',
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
      matchGroup: 'washing',
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
      matchGroup: 'electronics',
    ),
    // -- Added 2026-09-16, from the finalized taxonomy PDF
    // (habio_categories_subcategories_final.pdf). New ids only --
    // every id above this line is untouched, so no already-
    // onboarded professional's subcategoryIds selection breaks.
    SubCategory(id: 'tv_repair', name: 'TV Repair', icon: Icons.tv, description: 'Television repair and servicing.', keywords: ['tv', 'television'], matchGroup: 'electronics'),
    SubCategory(id: 'geyser_repair', name: 'Geyser Installation & Repair', icon: Icons.hot_tub_outlined, description: 'Geyser/water heater installation, connection and repair.', keywords: ['geyser repair', 'water heater repair', 'geyser', 'water heater', 'geyser installation', 'geyser connection'], relatedCategories: ['plumbing'], matchGroup: 'water_heating'),
    SubCategory(id: 'air_purifier_repair', name: 'Air Purifier Repair', icon: Icons.air, description: 'Air purifier repair and servicing.', keywords: ['air purifier'], matchGroup: 'electronics'),
    SubCategory(id: 'iron_press_repair', name: 'Iron / Press Repair', icon: Icons.iron, description: 'Iron and press repair.', keywords: ['iron', 'press'], matchGroup: 'washing'),
    SubCategory(id: 'water_cooler_repair', name: 'Water Cooler Repair', icon: Icons.local_drink, description: 'Water cooler repair and servicing.', keywords: ['water cooler'], matchGroup: 'cooling'),
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
      // No matchGroup -- "not sure" should keep falling back to the
      // whole category, same as before this change.
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
    // -- Locks & Hinges (id 'locks') and Wood Polish & Finishing (id
    // 'wood_polish') removed 2026-10-01 -- duplicate-work cleanup.
    // Locks/hardware work is now one listing under Home Repair's
    // 'hardware' subcategory (Carpentry tagged as a related category
    // there, so a Carpentry professional can still pick it up as a
    // skill); wood polish/finishing is now one listing under
    // Painting's 'wood_finish' subcategory, same treatment. Neither
    // id is reused elsewhere -- removing them here does not affect
    // any other subcategory's id.
    // -- Added 2026-09-16, from the finalized taxonomy PDF
    // (habio_categories_subcategories_final.pdf). New ids only --
    // every id above this line is untouched, so no already-
    // onboarded professional's subcategoryIds selection breaks.
    SubCategory(id: 'false_ceiling_carpentry', name: 'False Ceiling Carpentry Repair', icon: Icons.architecture, description: 'False ceiling carpentry work and repair.', keywords: ['false ceiling carpentry']),
    SubCategory(id: 'wooden_flooring_installation', name: 'Wooden Flooring Installation', icon: Icons.grid_view, description: 'Wooden flooring installation.', keywords: ['wooden flooring', 'flooring']),
    SubCategory(id: 'partition_wall_carpentry', name: 'Partition Wall Carpentry', icon: Icons.view_column_outlined, description: 'Partition wall carpentry work.', keywords: ['partition wall']),
    SubCategory(id: 'wooden_gate_door_making', name: 'Wooden Gate / Door Making', icon: Icons.door_sliding_outlined, description: 'Custom wooden gate and door making.', keywords: ['wooden gate', 'door making']),
    SubCategory(id: 'staircase_woodwork', name: 'Staircase Woodwork', icon: Icons.stairs, description: 'Staircase woodwork.', keywords: ['staircase woodwork', 'staircase']),
    SubCategory(id: 'wardrobe_interior_fitting', name: 'Wardrobe Interior Fitting', icon: Icons.inventory_2_outlined, description: 'Wardrobe interior fitting and organizers.', keywords: ['wardrobe interior', 'wardrobe fitting']),
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
  // REVISED 2026-09-30: home_cleaning, bathroom_cleaning,
  // kitchen_cleaning, office_cleaning, clothes_cleaning and
  // clothes_washing removed from here -- they're the "Day-to-Day
  // Services" Coming Soon preview now (see
  // core/widgets/day_to_day_coming_soon_section.dart), not live yet,
  // so they can't also be live and bookable under Cleaning at the
  // same time. That was the only reason Cleaning was a Quick Service
  // (isQuickService) -- with those subcategories gone, everything
  // left here is a normal, bid-based service, same as
  // Electrical/Plumbing/etc, so isQuickService is removed too.
  subCategories: [
    SubCategory(id: 'sofa_cleaning', name: 'Sofa & Upholstery', icon: Icons.weekend, description: 'Sofa and upholstery cleaning.', keywords: ['sofa','upholstery']),
    SubCategory(id: 'carpet_cleaning', name: 'Carpet & Mattress', icon: Icons.bed_outlined, description: 'Carpet and mattress cleaning.', keywords: ['carpet','mattress']),
    SubCategory(id: 'window_cleaning', name: 'Window Cleaning', icon: Icons.window, description: 'Glass and window cleaning.', keywords: ['window','glass']),
    SubCategory(id: 'water_tank_cleaning', name: 'Water Tank Cleaning', icon: Icons.water_drop, description: 'Water tank cleaning.', keywords: ['tank']),
    SubCategory(id: 'chimney_cleaning', name: 'Chimney Cleaning', icon: Icons.fireplace_outlined, description: 'Kitchen chimney cleaning and degreasing.', keywords: ['chimney']),
    SubCategory(id: 'car_cleaning', name: 'Car Cleaning & Detailing', icon: Icons.local_car_wash, description: 'Doorstep car cleaning and detailing.', keywords: ['car','detailing']),
    SubCategory(id: 'move_cleaning', name: 'Move-In / Move-Out Cleaning', icon: Icons.inventory_2_outlined, description: 'Deep cleaning before moving in or after moving out.', keywords: ['move in','move out','shifting']),
    SubCategory(id: 'curtain_cleaning', name: 'Curtain Cleaning', icon: Icons.local_laundry_service, description: 'Curtain and drape cleaning.', keywords: ['curtain','drapes']),
    // -- Garden & Lawn Cleaning (id 'garden_cleaning') removed
    // 2026-10-01 -- duplicate-work cleanup, merged into Helper
    // Services' 'gardener' subcategory (renamed Gardener / Lawn
    // Care), which tags Cleaning as a related category.
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
  // REVISED 2026-09-30: maid_fulltime, maid_parttime, cook, driver,
  // dog_walking and night_caregiver removed from here -- they're the
  // "Day-to-Day Services" Coming Soon preview now (see
  // core/widgets/day_to_day_coming_soon_section.dart), not live yet,
  // so they can't also be live and bookable under Helper Services at
  // the same time. That was the only reason Helper Services was a
  // Quick Service (isQuickService) -- with those subcategories gone,
  // everything left here is a normal, bid-based service, same as
  // Electrical/Plumbing/etc, so isQuickService is removed too.
  // babysitter and elderly_care stay removed from the app entirely,
  // per Harsh's earlier instruction.
  subCategories: [
    SubCategory(id: 'gardener', name: 'Gardener / Lawn Care', icon: Icons.grass, description: 'Gardening, lawn care and garden clean-up help.', keywords: ['gardener', 'lawn', 'garden', 'lawn cleaning', 'garden cleaning'], relatedCategories: ['cleaning']),
    SubCategory(id: 'errand_assistant', name: 'Errand Running / Personal Assistant', icon: Icons.assignment, description: 'Errands and personal assistance.', keywords: ['errand','personal assistant']),
    SubCategory(id: 'laundry_ironing', name: 'Laundry & Ironing Help', icon: Icons.local_laundry_service, description: 'Laundry and ironing help.', keywords: ['laundry','ironing']),
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
    SubCategory(id: 'wood_finish', name: 'Wood Polish & Finish', icon: Icons.format_color_fill, description: 'Polishing, varnishing and finishing of wooden surfaces.', keywords: ['polish', 'varnish', 'wood finish', 'wood polish'], relatedCategories: ['carpentry']),
    // -- Added 2026-09-16, from the finalized taxonomy PDF
    // (habio_categories_subcategories_final.pdf). New ids only --
    // every id above this line is untouched, so no already-
    // onboarded professional's subcategoryIds selection breaks.
    SubCategory(id: 'grill_metal_painting', name: 'Grill & Metal Painting', icon: Icons.brush, description: 'Grill and metal painting.', keywords: ['grill painting', 'metal painting']),
    SubCategory(id: 'false_ceiling_pop_painting', name: 'False Ceiling / POP Painting', icon: Icons.architecture, description: 'False ceiling and POP painting.', keywords: ['false ceiling painting', 'pop painting']),
    SubCategory(id: 'stencil_mural_painting', name: 'Stencil / Mural Painting', icon: Icons.palette_outlined, description: 'Stencil and mural painting.', keywords: ['stencil', 'mural']),
    SubCategory(id: 'pu_polish_enamel_painting', name: 'PU Polish & Enamel Painting', icon: Icons.format_paint, description: 'PU polish and enamel painting.', keywords: ['pu polish', 'enamel painting']),
    SubCategory(id: 'metal_roof_painting', name: 'Metal Roof Painting', icon: Icons.roofing, description: 'Metal roof painting.', keywords: ['metal roof painting', 'roof painting']),
    SubCategory(id: 'spray_painting', name: 'Spray Painting', icon: Icons.colorize, description: 'Spray painting.', keywords: ['spray painting']),
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
    // -- Added 2026-09-16, from the finalized taxonomy PDF
    // (habio_categories_subcategories_final.pdf). New ids only --
    // every id above this line is untouched, so no already-
    // onboarded professional's subcategoryIds selection breaks.
    SubCategory(id: 'wood_borer_treatment', name: 'Wood Borer Treatment', icon: Icons.forest_outlined, description: 'Wood borer treatment.', keywords: ['wood borer']),
    SubCategory(id: 'garden_lawn_pest_control', name: 'Garden / Lawn Pest Control', icon: Icons.grass, description: 'Garden and lawn pest control.', keywords: ['garden pest', 'lawn pest']),
    SubCategory(id: 'lizard_snake_repellent', name: 'Lizard / Snake Repellent Treatment', icon: Icons.pest_control_outlined, description: 'Lizard and snake repellent treatment.', keywords: ['lizard', 'snake repellent']),
    SubCategory(id: 'full_property_fumigation', name: 'Full-Property Fumigation Service', icon: Icons.cleaning_services, description: 'Full-property fumigation service.', keywords: ['fumigation']),
    SubCategory(id: 'pre_construction_anti_termite', name: 'Pre-Construction Anti-Termite Treatment', icon: Icons.construction, description: 'Pre-construction anti-termite treatment.', keywords: ['pre construction termite', 'anti termite']),
    SubCategory(id: 'general_pest', name: 'General Pest Control', icon: Icons.help_outline, description: 'Other pest issues.', keywords: ['pest']),
  ],
),
Category(
  id: 'home_repair',
  name: 'Home Repair',
  icon: Icons.home_repair_service,
  color: Colors.red,
  subCategories: [
    // -- Glass Repair (id 'glass') removed 2026-10-01 -- duplicate-
    // work cleanup. This generic entry overlapped the whole Glass
    // Work category; Home Repair is now tagged as a related category
    // on Glass Work's 'glass_window_installation' and
    // 'cracked_glass_repair' subcategories (installation + repair,
    // matching this entry's old "Glass installation & repair" scope)
    // instead of keeping a separate generic listing here.
    // -- Aluminium Work (id 'aluminium') removed 2026-10-01 --
    // duplicate-work cleanup, merged into Metal Fabrication's
    // 'aluminium_window_door' subcategory, which tags Home Repair as
    // a related category.
    SubCategory(id: 'tiles', name: 'Tiles & Flooring', icon: Icons.grid_view, description: 'Tile and flooring work.', keywords: ['tiles']),
    SubCategory(id: 'ceiling', name: 'Ceiling Repair', icon: Icons.architecture, description: 'False ceiling and repairs.', keywords: ['ceiling']),
    SubCategory(id: 'masonry', name: 'Masonry & Civil Work', icon: Icons.foundation, description: 'Brick and cement work.', keywords: ['masonry']),
    SubCategory(id: 'roof', name: 'Roofing Repairs', icon: Icons.roofing, description: 'Roof repair.', keywords: ['roof']),
    SubCategory(id: 'hardware', name: 'Lock & Hardware Repair', icon: Icons.lock_outline, description: 'Replacement and repair of locks, handles and hinges.', keywords: ['lock', 'hardware', 'hinge', 'handle', 'door lock'], relatedCategories: ['carpentry']),
    // -- Added 2026-09-16, from the finalized taxonomy PDF
    // (habio_categories_subcategories_final.pdf). New ids only --
    // every id above this line is untouched, so no already-
    // onboarded professional's subcategoryIds selection breaks.
    SubCategory(id: 'general_handyman_multi_fix', name: 'General Handyman / Multi-Fix Visit', icon: Icons.build, description: 'A handyman visit to fix multiple small things at once.', keywords: ['handyman', 'multi fix']),
    SubCategory(id: 'curtain_rod_blind_installation', name: 'Curtain Rod & Blind Installation', icon: Icons.curtains_closed_outlined, description: 'Curtain rod and blind installation.', keywords: ['curtain rod', 'blind installation']),
    SubCategory(id: 'wall_mount_tv_mounting', name: 'Wall Mount / TV Mounting', icon: Icons.tv, description: 'Wall mount and TV mounting.', keywords: ['tv mounting', 'wall mount']),
    SubCategory(id: 'small_appliance_mounting', name: 'Small Appliance Mounting', icon: Icons.handyman, description: 'Mounting of small appliances.', keywords: ['appliance mounting']),
    SubCategory(id: 'furniture_assembly_flatpack', name: 'Furniture Assembly (Flat-Pack)', icon: Icons.chair_alt_outlined, description: 'Flat-pack furniture assembly.', keywords: ['furniture assembly', 'flat pack']),
    SubCategory(id: 'clock_mirror_picture_hanging', name: 'Clock / Mirror / Picture Frame Hanging', icon: Icons.crop_original, description: 'Hanging clocks, mirrors and picture frames.', keywords: ['picture hanging', 'mirror hanging']),
    SubCategory(id: 'doormat_threshold_fixing', name: 'Doormat & Threshold Fixing', icon: Icons.door_front_door, description: 'Doormat and threshold fixing.', keywords: ['doormat', 'threshold']),
    SubCategory(id: 'cabinet_hinge_adjustment', name: 'Cabinet Hinge Adjustment', icon: Icons.build_circle_outlined, description: 'Cabinet hinge adjustment.', keywords: ['cabinet hinge']),
    SubCategory(id: 'general_home_inspection_visit', name: 'General Home Inspection Visit', icon: Icons.fact_check_outlined, description: 'A general home inspection visit.', keywords: ['home inspection']),
    SubCategory(id: 'general_home', name: 'General Home Repair', icon: Icons.help_outline, description: 'Other home repairs.', keywords: ['repair']),
  ],
),
Category(
  id: 'automobile',
  name: 'Automobile',
  icon: Icons.directions_car,
  color: Colors.indigo,
  subCategories: [
    SubCategory(id: 'car', name: 'Car Repair', icon: Icons.directions_car, description: 'Car repairs.', keywords: ['car'], matchGroup: 'car'),
    SubCategory(id: 'bike', name: 'Bike Repair', icon: Icons.two_wheeler, description: 'Bike repairs.', keywords: ['bike'], matchGroup: 'bike'),
    SubCategory(id: 'battery', name: 'Battery Service', icon: Icons.battery_full, description: 'Battery replacement.', keywords: ['battery'], matchGroup: 'both'),
    SubCategory(id: 'tyre', name: 'Tyre & Puncture', icon: Icons.tire_repair, description: 'Tyre repair.', keywords: ['tyre'], matchGroup: 'both'),
    SubCategory(id: 'wash', name: 'Car Wash & Detailing', icon: Icons.local_car_wash, description: 'Vehicle cleaning.', keywords: ['wash'], matchGroup: 'car'),
    SubCategory(id: 'oil', name: 'Oil Change', icon: Icons.opacity, description: 'Engine oil replacement.', keywords: ['oil'], matchGroup: 'both'),
    // id changed 2026-10-01 from 'inspection' to 'vehicle_inspection' -- fixes
    // an accidental id collision with Electrical's own 'inspection' entry
    // above (both previously used the same id).
    SubCategory(id: 'vehicle_inspection', name: 'Vehicle Inspection', icon: Icons.fact_check, description: 'Vehicle inspection.', keywords: ['inspection'], matchGroup: 'both'),
    // -- Added 2026-09-16, from the finalized taxonomy PDF
    // (habio_categories_subcategories_final.pdf). New ids only --
    // every id above this line is untouched, so no already-
    // onboarded professional's subcategoryIds selection breaks.
    SubCategory(id: 'car_ac_repair', name: 'Car AC Repair', icon: Icons.ac_unit, description: 'Car AC repair and servicing.', keywords: ['car ac'], matchGroup: 'car'),
    SubCategory(id: 'car_denting_painting', name: 'Car Denting & Painting', icon: Icons.format_paint, description: 'Car denting and painting.', keywords: ['denting', 'car painting'], matchGroup: 'car'),
    SubCategory(id: 'car_electrical_repair', name: 'Car Electrical Repair', icon: Icons.electrical_services, description: 'Car electrical repair.', keywords: ['car electrical'], matchGroup: 'car'),
    SubCategory(id: 'roadside_breakdown_assistance', name: 'Roadside Breakdown Assistance', icon: Icons.car_repair, description: 'Roadside breakdown assistance.', keywords: ['roadside assistance', 'breakdown'], matchGroup: 'both'),
    SubCategory(id: 'wheel_alignment_balancing', name: 'Wheel Alignment & Balancing', icon: Icons.album_outlined, description: 'Wheel alignment and balancing.', keywords: ['wheel alignment', 'balancing'], matchGroup: 'car'),
    SubCategory(id: 'car_scratch_dent_removal', name: 'Car Scratch & Dent Removal', icon: Icons.brush, description: 'Car scratch and dent removal.', keywords: ['scratch removal', 'dent removal'], matchGroup: 'car'),
    SubCategory(id: 'ev_charging_point_installation', name: 'EV Charging Point Installation', icon: Icons.ev_station, description: 'EV charging point installation.', keywords: ['ev charging', 'electric vehicle'], matchGroup: 'both'),
    SubCategory(id: 'general_auto', name: 'General Automobile Service', icon: Icons.help_outline, description: 'Other automobile work.', keywords: ['automobile'], matchGroup: 'both'),
    // -- Added 2026-10-02: bike-specific depth, matching what car
    // already had (previously "Bike Repair" was the ONLY dedicated
    // bike subcategory -- see the Automobile vehicle-type split
    // discussion in the project to-do). New ids only.
    SubCategory(id: 'bike_electrical_repair', name: 'Bike Electrical Repair', icon: Icons.electrical_services, description: 'Bike wiring, lighting, horn and starter motor repair.', keywords: ['bike electrical', 'two wheeler electrical'], matchGroup: 'bike'),
    SubCategory(id: 'bike_denting_painting', name: 'Bike Denting & Painting', icon: Icons.format_paint, description: 'Bike body panel and tank denting and painting.', keywords: ['bike denting', 'bike painting'], matchGroup: 'bike'),
    SubCategory(id: 'bike_engine_clutch_service', name: 'Bike Engine & Clutch Service', icon: Icons.settings, description: 'Bike engine overhaul, clutch plate replacement and tuning.', keywords: ['bike engine', 'bike clutch', 'engine tuning'], matchGroup: 'bike'),
    SubCategory(id: 'bike_chain_brake_service', name: 'Bike Chain, Sprocket & Brake Service', icon: Icons.settings_input_component, description: 'Bike drivetrain (chain, sprocket) and brake servicing.', keywords: ['bike chain', 'sprocket', 'bike brake'], matchGroup: 'bike'),
    SubCategory(id: 'scooter_transmission_service', name: 'Scooter / Automatic Transmission Service', icon: Icons.two_wheeler, description: 'Scooter CVT/variator and automatic transmission service.', keywords: ['scooter service', 'cvt', 'variator'], matchGroup: 'bike'),
    SubCategory(id: 'bike_suspension_fork_repair', name: 'Bike Suspension & Fork Repair', icon: Icons.build_circle_outlined, description: 'Bike front fork and suspension repair.', keywords: ['bike suspension', 'fork repair'], matchGroup: 'bike'),
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
    // id changed 2026-10-01 from 'furniture' to 'furniture_moving' -- fixes an
    // accidental id collision with Carpentry's own 'furniture' subcategory
    // (both previously used the same id).
    SubCategory(id: 'furniture_moving', name: 'Furniture Moving', icon: Icons.chair, description: 'Furniture shifting.', keywords: ['furniture']),
    SubCategory(id: 'appliance', name: 'Appliance Relocation', icon: Icons.kitchen, description: 'Move appliances safely.', keywords: ['appliance']),
    SubCategory(id: 'loading', name: 'Loading & Unloading', icon: Icons.move_up, description: 'Loading assistance.', keywords: ['loading']),
    SubCategory(id: 'storage', name: 'Storage Services', icon: Icons.warehouse, description: 'Temporary storage.', keywords: ['storage']),
    // -- Added 2026-09-16, from the finalized taxonomy PDF
    // (habio_categories_subcategories_final.pdf). New ids only --
    // every id above this line is untouched, so no already-
    // onboarded professional's subcategoryIds selection breaks.
    SubCategory(id: 'intercity_relocation', name: 'Intercity Relocation', icon: Icons.local_shipping, description: 'Intercity home relocation.', keywords: ['intercity relocation']),
    SubCategory(id: 'vehicle_transportation', name: 'Vehicle Transportation', icon: Icons.directions_car, description: 'Vehicle transportation services.', keywords: ['vehicle transportation']),
    SubCategory(id: 'pet_relocation', name: 'Pet Relocation', icon: Icons.pets, description: 'Pet relocation services.', keywords: ['pet relocation']),
    SubCategory(id: 'fragile_specialty_item_packing', name: 'Fragile / Specialty Item Packing', icon: Icons.inventory_2_outlined, description: 'Packing for fragile and specialty items.', keywords: ['fragile packing', 'specialty item']),
    SubCategory(id: 'two_wheeler_vehicle_trailer_shifting', name: 'Two-Wheeler / Vehicle Trailer Shifting', icon: Icons.local_shipping, description: 'Two-wheeler and vehicle trailer shifting.', keywords: ['two wheeler shifting', 'trailer shifting']),
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
    // -- Added 2026-09-16, from the finalized taxonomy PDF
    // (habio_categories_subcategories_final.pdf). New ids only --
    // every id above this line is untouched, so no already-
    // onboarded professional's subcategoryIds selection breaks.
    SubCategory(id: 'mens_grooming', name: 'Men\'s Grooming', icon: Icons.face_retouching_natural, description: 'Men\'s grooming (haircut, shave).', keywords: ['mens grooming', 'shave']),
    SubCategory(id: 'bridal_makeup', name: 'Bridal Makeup', icon: Icons.brush, description: 'Bridal makeup services.', keywords: ['bridal makeup', 'bridal']),
    SubCategory(id: 'mehendi_henna_services', name: 'Mehendi / Henna Services', icon: Icons.back_hand_outlined, description: 'Mehendi and henna services.', keywords: ['mehendi', 'henna']),
    SubCategory(id: 'hair_coloring', name: 'Hair Coloring', icon: Icons.color_lens_outlined, description: 'Hair coloring services.', keywords: ['hair color', 'hair coloring']),
    SubCategory(id: 'kids_grooming_services', name: 'Kids\' Grooming Services', icon: Icons.child_care, description: 'Kids\' grooming services.', keywords: ['kids grooming']),
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
    SubCategory(id: 'aluminium_window_door', name: 'Aluminium Window & Door Fabrication', icon: Icons.window, description: 'Aluminium window, door and general aluminium fabrication work.', keywords: ['aluminium', 'window', 'door', 'aluminium work', 'aluminium fabrication'], relatedCategories: ['home_repair']),
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
    SubCategory(id: 'glass_window_installation', name: 'Glass Window Installation / Replacement', icon: Icons.window, description: 'Glass window installation and replacement.', keywords: ['glass window'], relatedCategories: ['home_repair']),
    SubCategory(id: 'shower_cubicle_glass', name: 'Shower Cubicle / Glass Enclosure Installation', icon: Icons.bathtub_outlined, description: 'Shower cubicle and glass enclosure installation.', keywords: ['shower cubicle', 'glass enclosure']),
    SubCategory(id: 'glass_tabletop_shelf', name: 'Glass Tabletop & Shelf Installation', icon: Icons.inventory_2_outlined, description: 'Glass tabletop and shelf installation.', keywords: ['glass tabletop', 'glass shelf']),
    SubCategory(id: 'toughened_glass_installation', name: 'Toughened Glass Installation', icon: Icons.shield_outlined, description: 'Toughened glass installation.', keywords: ['toughened glass']),
    SubCategory(id: 'glass_railing_installation', name: 'Glass Railing Installation', icon: Icons.stairs, description: 'Glass railing installation.', keywords: ['glass railing']),
    SubCategory(id: 'custom_glass_cutting', name: 'Custom Glass Cutting & Fitting', icon: Icons.content_cut, description: 'Custom glass cutting and fitting.', keywords: ['glass cutting']),
    SubCategory(id: 'cracked_glass_repair', name: 'Cracked / Broken Glass Repair & Replacement', icon: Icons.broken_image_outlined, description: 'Cracked and broken glass repair and replacement.', keywords: ['cracked glass', 'broken glass'], relatedCategories: ['home_repair']),
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
    SubCategory(id: 'birthday_party_decoration', name: 'Birthday Party Decoration', icon: Icons.cake, description: 'Birthday party decoration.', keywords: ['birthday decoration'], matchGroup: 'decoration_setup'),
    SubCategory(id: 'wedding_engagement_decoration', name: 'Wedding / Engagement Decoration', icon: Icons.favorite_border, description: 'Wedding and engagement decoration.', keywords: ['wedding decoration', 'engagement decoration'], matchGroup: 'decoration_setup'),
    SubCategory(id: 'balloon_decoration', name: 'Balloon Decoration', icon: Icons.celebration, description: 'Balloon decoration.', keywords: ['balloon decoration'], matchGroup: 'decoration_setup'),
    SubCategory(id: 'flower_decoration', name: 'Flower Decoration', icon: Icons.local_florist, description: 'Flower decoration.', keywords: ['flower decoration'], matchGroup: 'decoration_setup'),
    SubCategory(id: 'corporate_event_setup', name: 'Corporate Event Setup', icon: Icons.business, description: 'Corporate event setup.', keywords: ['corporate event'], matchGroup: 'decoration_setup'),
    SubCategory(id: 'festival_pooja_decoration', name: 'Festival / Pooja Decoration', icon: Icons.celebration, description: 'Festival and pooja decoration.', keywords: ['festival decoration', 'pooja decoration'], matchGroup: 'decoration_setup'),
    SubCategory(id: 'photography_videography', name: 'Photography & Videography', icon: Icons.camera_alt, description: 'Photography and videography.', keywords: ['photography', 'videography'], matchGroup: 'photo_video'),
    SubCategory(id: 'catering_coordination', name: 'Catering Coordination', icon: Icons.restaurant, description: 'Catering coordination.', keywords: ['catering'], matchGroup: 'catering'),
    SubCategory(id: 'tent_canopy_setup', name: 'Tent / Canopy Setup', icon: Icons.roofing, description: 'Tent and canopy setup.', keywords: ['tent setup', 'canopy setup'], matchGroup: 'decoration_setup'),
    SubCategory(id: 'dj_sound_setup', name: 'DJ & Sound Setup', icon: Icons.music_note, description: 'DJ and sound setup.', keywords: ['dj', 'sound setup'], matchGroup: 'sound_music'),
    SubCategory(id: 'stage_entrance_arch_decoration', name: 'Stage & Entrance Arch Decoration', icon: Icons.theater_comedy, description: 'Stage and entrance arch decoration.', keywords: ['stage decoration', 'entrance arch'], matchGroup: 'decoration_setup'),
    SubCategory(id: 'fairy_light_installation', name: 'Fairy Light / String Light Installation', icon: Icons.lightbulb_outline, description: 'Fairy light and string light installation.', keywords: ['fairy lights', 'string lights'], matchGroup: 'decoration_setup'),
    SubCategory(id: 'drone_photography', name: 'Drone Photography', icon: Icons.flight, description: 'Drone photography.', keywords: ['drone photography'], matchGroup: 'photo_video'),
    SubCategory(id: 'general_decoration_events', name: 'General Decoration Service', icon: Icons.help_outline, description: 'Not sure? Choose this option.', keywords: ['decoration', 'events', 'other', 'unknown']),
  ],
),
  ];

  // ============================================================
  // FIRESTORE OVERRIDE (NEW — 2026-09-16)
  // ============================================================
  //
  // `all` used to be the const list itself; it's now a getter that
  // prefers a Firestore-loaded override when one has been fetched,
  // and otherwise falls back to the exact same hardcoded list as
  // before. Every existing call site (ServiceCategories.all) keeps
  // working completely unchanged -- Dart doesn't distinguish a
  // static getter from a static const field at the call site.
  //
  // This means the admin panel's Category & Pricing Management
  // screen can add/edit/reorder/retire categories in Firestore and
  // have BOTH apps pick it up on next launch, with zero risk to the
  // app if Firestore is unreachable, empty, or a document is
  // malformed -- loadFromFirestore() only ever replaces
  // _firestoreOverride on a fully successful parse, wrapped in its
  // own try/catch, and is called once at splash (see
  // splash_screen.dart) as a best-effort cache warm, never awaited
  // in a way that could block app launch.
  //

  static List<Category>? _firestoreOverride;

  static List<Category> get all => _firestoreOverride ?? _hardcoded;

  /// True once a Firestore override has been successfully loaded
  /// (even if a later reload fails -- the last good override stays
  /// in place, same "keep serving stale over serving nothing"
  /// pattern used elsewhere in this app for offline resilience).
  static bool get isUsingFirestoreOverride => _firestoreOverride != null;

  static Future<void> loadFromFirestore() async {
    try {
      final categoriesSnap = await FirebaseFirestore.instance
          .collection('categories')
          .orderBy('order')
          .get();

      if (categoriesSnap.docs.isEmpty) {
        // Collection not seeded yet -- keep using the hardcoded
        // catalog, don't overwrite a good state with an empty one.
        return;
      }

      final List<Category> loaded = [];

      for (final categoryDoc in categoriesSnap.docs) {
        final data = categoryDoc.data();
        if (data['isActive'] == false) continue;

        final subSnap = await categoryDoc.reference
            .collection('subcategories')
            .orderBy('order')
            .get();

        final subCategories = <SubCategory>[
          for (final subDoc in subSnap.docs)
            if (subDoc.data()['isActive'] != false)
              SubCategory(
                id: subDoc.data()['id'] as String? ?? subDoc.id,
                name: subDoc.data()['name'] as String? ?? '',
                icon: IconRegistry.resolve(
                  subDoc.data()['iconName'] as String?,
                ),
                description:
                    subDoc.data()['description'] as String? ?? '',
                keywords: List<String>.from(
                  subDoc.data()['keywords'] ?? const [],
                ),
                // Skill-group tags must survive the Firestore round-trip
                // (kept 2026-10-07) or the skill-group lock, the car/bike
                // gate and the narrowed fallback silently switch off.
                relatedCategories: List<String>.from(
                  subDoc.data()['relatedCategories'] ?? const [],
                ),
                matchGroup: subDoc.data()['matchGroup'] as String?,
              ),
        ];

        // A category with no active subcategories left is dropped
        // rather than shown empty -- shouldn't happen in practice,
        // but keeps the browse grid sane if it ever does.
        if (subCategories.isEmpty) continue;

        loaded.add(
          Category(
            id: data['id'] as String? ?? categoryDoc.id,
            name: data['name'] as String? ?? '',
            icon: IconRegistry.resolve(data['iconName'] as String?),
            color: _colorFromHex(data['colorHex'] as String?) ??
                Colors.blueGrey,
            subCategories: subCategories,
            isQuickService: data['isQuickService'] as bool? ?? false,
          ),
        );
      }

      if (loaded.isNotEmpty) {
        _firestoreOverride = loaded;
      }
    } catch (e, st) {
      // Best-effort only -- any failure (offline, permission,
      // malformed doc) just leaves the hardcoded catalog in place.
      debugPrint('ServiceCategories.loadFromFirestore failed: $e\n$st');
    }
  }

  static Color? _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    var normalized = hex.replaceFirst('#', '');
    if (normalized.length == 6) normalized = 'FF$normalized';
    final value = int.tryParse(normalized, radix: 16);
    return value == null ? null : Color(value);
  }

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