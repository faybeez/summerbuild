import 'package:flutter/material.dart';

class ClothingTag {
  final int id;
  final String tagType;
  final String tagValue;
  final String tagDisplayName;

  const ClothingTag({
    required this.id,
    required this.tagType,
    required this.tagValue,
    required this.tagDisplayName,
  });

  factory ClothingTag.fromJson(Map json) {
    return ClothingTag(
      id: (json['id'] as num).toInt(),
      tagType: (json['tag_type'] as String?) ?? '',
      tagValue: (json['tag_value'] as String?) ?? '',
      tagDisplayName:
          (json['tag_display_name'] as String?) ??
          (json['tag_value'] as String?) ??
          '',
    );
  }

  /// True when this tag represents a color.
  bool get isColorTag => tagType.toUpperCase().contains('COLOR');

  /// Parses [tagValue] as a hex color string.
  /// Supports: '#RRGGBB', '#AARRGGBB', 'RRGGBB', 'AARRGGBB'.
  /// Returns null if [tagValue] is not a valid hex color.
  Color? get color {
    final named = _namedColors[tagValue.trim().toUpperCase()];
    if (named != null) return named;

    final raw = tagValue.trim().replaceFirst('#', '');
    final hex = switch (raw.length) {
      6 => int.tryParse('FF$raw', radix: 16),
      8 => int.tryParse(raw, radix: 16),
      _ => null,
    };
    return hex != null ? Color(hex) : null;
  }

  /// Resolves the icon for this tag using a three-level priority:
  ///   1. Per-value icon (most specific — e.g. 'SUNNY' → sun icon)
  ///   2. Per-type icon  (group fallback  — e.g. any WEATHER tag)
  ///   3. Generic label icon (final fallback)
  ///
  /// COLOR tags should use [tagWidget] / [colorSwatch] instead of this getter.
  IconData get icon {
    final valueIcon = _tagValueIcons[tagValue.trim().toUpperCase()];
    if (valueIcon != null) return valueIcon;

    final typeIcon = _tagTypeIcons[tagType.trim().toUpperCase()];
    if (typeIcon != null) return typeIcon;

    return Icons.label_outline;
  }

  static const Map<String, Color> _namedColors = {
    'BLACK': Colors.black,
    'WHITE': Colors.white,
    'GRAY': Color.fromARGB(255, 124, 124, 130),
    'RED': Color.fromARGB(255, 170, 31, 31),
    'BLUE': Color.fromARGB(255, 32, 106, 190),
    'GREEN': Color.fromARGB(255, 39, 115, 43),
    'YELLOW': Color.fromARGB(255, 255, 226, 99),
    'ORANGE': Color.fromARGB(255, 222, 126, 48),
    'PURPLE': Color.fromARGB(255, 130, 67, 170),
    'PINK': Color.fromARGB(255, 245, 105, 182),
    'BROWN': Color.fromARGB(255, 85, 57, 48),
    'BEIGE': Color.fromARGB(255, 209, 191, 159),
    'CREAM': Color.fromARGB(255, 255, 238, 197),
    'NAVY': Color.fromARGB(255, 15, 27, 57),
    'GOLD': Color(0xFFD4A017),
    'SILVER': Color(0xFFB0BEC5),
  };

  // icon mapping
  static const Map<String, IconData> _tagValueIcons = {
    'SUNNY': Icons.wb_sunny_outlined,
    'CLEAR': Icons.wb_sunny_outlined,
    'HOT': Icons.thermostat,
    'WARM': Icons.wb_sunny,
    'MILD': Icons.wb_cloudy_outlined,
    'CLOUDY': Icons.cloud_outlined,
    'OVERCAST': Icons.cloud,
    'WINDY': Icons.air,
    'RAINY': Icons.umbrella_outlined,
    'RAIN': Icons.umbrella_outlined,
    'STORMY': Icons.thunderstorm_outlined,
    'THUNDER': Icons.thunderstorm_outlined,
    'SNOWY': Icons.ac_unit,
    'SNOW': Icons.ac_unit,
    'COLD': Icons.severe_cold_outlined,
    'FREEZING': Icons.severe_cold,
    'FOGGY': Icons.foggy,

    'CASUAL': Icons.weekend_outlined,
    'EVERYDAY': Icons.today_outlined,
    'WORK': Icons.work_outline,
    'OFFICE': Icons.business_center_outlined,
    'FORMAL': Icons.style_outlined,
    'BUSINESS': Icons.business_outlined,
    'PARTY': Icons.celebration_outlined,
    'NIGHT_OUT': Icons.nightlife_outlined,
    'DATE': Icons.favorite_outline,
    'WEDDING': Icons.church_outlined,
    'SPORT': Icons.sports_outlined,
    'GYM': Icons.fitness_center_outlined,
    'OUTDOOR': Icons.park_outlined,
    'BEACH': Icons.beach_access_outlined,
    'TRAVEL': Icons.luggage_outlined,
    'LOUNGE': Icons.king_bed_outlined,

    'TOP': Icons.checkroom,
    'SHIRT': Icons.checkroom,
    'TSHIRT': Icons.checkroom,
    'BLOUSE': Icons.checkroom,
    'SWEATER': Icons.checkroom,
    'HOODIE': Icons.checkroom,
    'JACKET': Icons.dry_cleaning_outlined,
    'COAT': Icons.dry_cleaning_outlined,
    'BLAZER': Icons.dry_cleaning_outlined,
    'PANTS': Icons.straighten_outlined,
    'JEANS': Icons.straighten_outlined,
    'SHORTS': Icons.straighten_outlined,
    'SKIRT': Icons.straighten_outlined,
    'DRESS': Icons.accessibility_outlined,
    'JUMPSUIT': Icons.accessibility_outlined,
    'SHOES': Icons.do_not_step_outlined,
    'SNEAKERS': Icons.do_not_step_outlined,
    'BOOTS': Icons.do_not_step_outlined,
    'HEELS': Icons.do_not_step_outlined,
    'SANDALS': Icons.do_not_step_outlined,
    'BAG': Icons.shopping_bag_outlined,
    'HANDBAG': Icons.shopping_bag_outlined,
    'BACKPACK': Icons.backpack_outlined,
    'HAT': Icons.face_outlined,
    'CAP': Icons.face_outlined,
    'SCARF': Icons.face_outlined,
    'BELT': Icons.linear_scale_outlined,
    'WATCH': Icons.watch_outlined,
    'JEWELLERY': Icons.diamond_outlined,
    'JEWELRY': Icons.diamond_outlined,
    'SUNGLASSES': Icons.wb_sunny_outlined,
    'SOCKS': Icons.straighten_outlined,
    'UNDERWEAR': Icons.straighten_outlined,
    'ACTIVEWEAR': Icons.sports_gymnastics_outlined,
    'SWIMWEAR': Icons.pool_outlined,
    'SUIT': Icons.business_center_outlined,
  };

  // fallback
  static const Map<String, IconData> _tagTypeIcons = {
    'WEATHER': Icons.wb_sunny_outlined,
    'OCCASION': Icons.event_outlined,
    'CATEGORY': Icons.category_outlined,
    'COLOR': Icons.circle,
  };

  /// Returns a widget representing this tag:
  /// - COLOR tags → filled circle swatch (or palette icon on parse failure).
  /// - All others → [Icon] resolved via the three-level icon chain.
  ///
  /// [size] controls both circle diameter and icon size (default 20).
  Widget tagWidget({
    double size = 20,
    Color? iconColor,
    bool haveBorderColor = false,
    Color? borderColor,
  }) {
    if (isColorTag)
      return colorSwatch(
        size: size,
        haveBorderColor: haveBorderColor,
        borderColor: borderColor,
      );
    return Icon(icon, size: size, color: iconColor);
  }

  /// Filled circle in this tag's hex color.
  /// Falls back to [Icons.palette_outlined] if [color] cannot be parsed.
  Widget colorSwatch({
    double size = 20,
    bool haveBorderColor = true,
    Color? borderColor,
  }) {
    final c = color;
    if (c == null) {
      return Icon(Icons.palette_outlined, size: size);
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        border: haveBorderColor
            ? Border.all(
                color:
                    borderColor ??
                    (c.computeLuminance() < 0.5 ? Colors.white : Colors.black),
                width: 1,
              )
            : null,
      ),
    );
  }

  @override
  String toString() {
    return 'ClothingTag(id: $id, tagType: $tagType, tagValue: $tagValue, tagDisplayName: $tagDisplayName)';
  }
}
