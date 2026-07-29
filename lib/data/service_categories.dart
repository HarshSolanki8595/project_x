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