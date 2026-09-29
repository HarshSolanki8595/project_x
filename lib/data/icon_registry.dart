import 'package:flutter/material.dart';

// ================================================================
// ICON REGISTRY -- added 2026-09-16, for the Firestore-backed
// category/pricing override system
// ================================================================
//
// Category/SubCategory objects hold a real IconData, but Firestore
// can only store a plain string -- so the admin panel writes an icon
// NAME (e.g. 'electrical_services_rounded') to each category/
// subcategory document, and this registry maps that name back to the
// actual Icons.<name> constant on the way in
// (ServiceCategories.loadFromFirestore()).
//
// Pre-populated with every icon already used by the hardcoded catalog
// below, so every EXISTING category/subcategory renders identically
// whether it's coming from the hardcoded fallback or a synced
// Firestore override. The admin panel's category editor only offers
// icons FROM this registry (it doesn't accept arbitrary icon names),
// so a new category/subcategory added there is always resolvable too.
// Add an entry here (and mirror it in the professional app's copy of
// this file) before offering a new icon in the admin panel.
//
// An iconName that isn't registered (e.g. hand-edited bad data)
// resolves to [IconRegistry.kFallbackIcon] instead of crashing.
//

class IconRegistry {
  IconRegistry._();

  static const IconData kFallbackIcon = Icons.miscellaneous_services;

  static IconData resolve(String? name) {
    if (name == null) return kFallbackIcon;
    return _byName[name] ?? kFallbackIcon;
  }

  /// Reverse lookup, used by the admin panel to prefill the icon
  /// picker when editing an existing category/subcategory that only
  /// has an IconData (e.g. seeded from the hardcoded catalog), not
  /// yet a stored name.
  static String? nameOf(IconData icon) {
    for (final entry in _byName.entries) {
      if (entry.value.codePoint == icon.codePoint &&
          entry.value.fontFamily == icon.fontFamily) {
        return entry.key;
      }
    }
    return null;
  }

  static List<String> get allNames => _byName.keys.toList(growable: false);

  static const Map<String, IconData> _byName = {
    'ac_unit': Icons.ac_unit,
    'accessible': Icons.accessible,
    'air': Icons.air,
    'album_outlined': Icons.album_outlined,
    'architecture': Icons.architecture,
    'assignment': Icons.assignment,
    'auto_fix_high': Icons.auto_fix_high,
    'back_hand_outlined': Icons.back_hand_outlined,
    'balcony': Icons.balcony,
    'bathtub_outlined': Icons.bathtub_outlined,
    'battery_charging_full': Icons.battery_charging_full,
    'battery_full': Icons.battery_full,
    'bed': Icons.bed,
    'bed_outlined': Icons.bed_outlined,
    'bolt': Icons.bolt,
    'broken_image_outlined': Icons.broken_image_outlined,
    'brush': Icons.brush,
    'bug_report': Icons.bug_report,
    'bug_report_outlined': Icons.bug_report_outlined,
    'build': Icons.build,
    'build_circle_outlined': Icons.build_circle_outlined,
    'business': Icons.business,
    'cable': Icons.cable,
    'cake': Icons.cake,
    'camera_alt': Icons.camera_alt,
    'car_repair': Icons.car_repair,
    'celebration': Icons.celebration,
    'chair': Icons.chair,
    'chair_alt_outlined': Icons.chair_alt_outlined,
    'checkroom': Icons.checkroom,
    'child_care': Icons.child_care,
    'cleaning_services': Icons.cleaning_services,
    'cleaning_services_outlined': Icons.cleaning_services_outlined,
    'color_lens_outlined': Icons.color_lens_outlined,
    'colorize': Icons.colorize,
    'construction': Icons.construction,
    'content_cut': Icons.content_cut,
    'crop_original': Icons.crop_original,
    'curtains_closed_outlined': Icons.curtains_closed_outlined,
    'directions_car': Icons.directions_car,
    'door_front_door': Icons.door_front_door,
    'door_sliding_outlined': Icons.door_sliding_outlined,
    'doorbell': Icons.doorbell,
    'electrical_services': Icons.electrical_services,
    'electrical_services_rounded': Icons.electrical_services_rounded,
    'ev_station': Icons.ev_station,
    'face': Icons.face,
    'face_retouching_natural': Icons.face_retouching_natural,
    'fact_check': Icons.fact_check,
    'fact_check_outlined': Icons.fact_check_outlined,
    'favorite_border': Icons.favorite_border,
    'fireplace_outlined': Icons.fireplace_outlined,
    'flight': Icons.flight,
    'flutter_dash': Icons.flutter_dash,
    'forest_outlined': Icons.forest_outlined,
    'format_color_fill': Icons.format_color_fill,
    'format_paint': Icons.format_paint,
    'foundation': Icons.foundation,
    'garage': Icons.garage,
    'grass': Icons.grass,
    'grid_view': Icons.grid_view,
    'handyman': Icons.handyman,
    'help_outline': Icons.help_outline,
    'home': Icons.home,
    'home_max_outlined': Icons.home_max_outlined,
    'home_repair_service': Icons.home_repair_service,
    'hot_tub_outlined': Icons.hot_tub_outlined,
    'house_outlined': Icons.house_outlined,
    'inventory': Icons.inventory,
    'inventory_2_outlined': Icons.inventory_2_outlined,
    'iron': Icons.iron,
    'kitchen': Icons.kitchen,
    'kitchen_rounded': Icons.kitchen_rounded,
    'layers_outlined': Icons.layers_outlined,
    'lightbulb_outline': Icons.lightbulb_outline,
    'linear_scale': Icons.linear_scale,
    'local_car_wash': Icons.local_car_wash,
    'local_drink': Icons.local_drink,
    'local_fire_department': Icons.local_fire_department,
    'local_florist': Icons.local_florist,
    'local_laundry_service': Icons.local_laundry_service,
    'local_shipping': Icons.local_shipping,
    'lock_outline': Icons.lock_outline,
    'microwave': Icons.microwave,
    'mode_fan_off_rounded': Icons.mode_fan_off_rounded,
    'move_up': Icons.move_up,
    'music_note': Icons.music_note,
    'nightlight_round': Icons.nightlight_round,
    'opacity': Icons.opacity,
    'palette_outlined': Icons.palette_outlined,
    'pan_tool': Icons.pan_tool,
    'people_alt': Icons.people_alt,
    'pest_control': Icons.pest_control,
    'pest_control_outlined': Icons.pest_control_outlined,
    'pets': Icons.pets,
    'plumbing': Icons.plumbing,
    'power': Icons.power,
    'restaurant': Icons.restaurant,
    'roofing': Icons.roofing,
    'security': Icons.security,
    'self_improvement': Icons.self_improvement,
    'shield_outlined': Icons.shield_outlined,
    'solar_power_outlined': Icons.solar_power_outlined,
    'spa': Icons.spa,
    'speed': Icons.speed,
    'stairs': Icons.stairs,
    'storage': Icons.storage,
    'straighten': Icons.straighten,
    'theater_comedy': Icons.theater_comedy,
    'tire_repair': Icons.tire_repair,
    'toggle_on_outlined': Icons.toggle_on_outlined,
    'travel_explore': Icons.travel_explore,
    'tv': Icons.tv,
    'two_wheeler': Icons.two_wheeler,
    'videocam_outlined': Icons.videocam_outlined,
    'view_column_outlined': Icons.view_column_outlined,
    'wallpaper': Icons.wallpaper,
    'warehouse': Icons.warehouse,
    'water': Icons.water,
    'water_damage_outlined': Icons.water_damage_outlined,
    'water_drop': Icons.water_drop,
    'water_drop_outlined': Icons.water_drop_outlined,
    'weekend': Icons.weekend,
    'window': Icons.window,
    'work_outline': Icons.work_outline,
  };
}
