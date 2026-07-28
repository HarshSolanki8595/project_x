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
            'chandelier',
            'lamp',
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
            'board',
            'usb socket',
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
          description: 'MCB, fuse and distribution board.',
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
          name: 'Inverters & UPS',
          icon: Icons.battery_charging_full,
          description: 'Home inverter and UPS systems.',
          keywords: [
            'inverter',
            'ups',
            'battery',
          ],
        ),

        SubCategory(
          id: 'doorbell',
          name: 'Doorbells & Intercoms',
          icon: Icons.doorbell,
          description: 'Doorbells and intercom systems.',
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
          description: 'Grounding and earthing.',
          keywords: [
            'earthing',
            'grounding',
          ],
        ),

        SubCategory(
          id: 'meter',
          name: 'Electrical Meter',
          icon: Icons.speed,
          description: 'Electrical meter related work.',
          keywords: [
            'meter',
            'electric meter',
          ],
        ),

        SubCategory(
          id: 'inspection',
          name: 'Electrical Inspection & Safety',
          icon: Icons.fact_check_outlined,
          description: 'Safety inspections and electrical audits.',
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