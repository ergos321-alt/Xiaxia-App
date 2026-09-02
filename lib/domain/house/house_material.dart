import 'package:flutter/material.dart';

enum HouseKind { diary, reading, watch, reality, browser, moments, hand, call }

/// The small House-specific layer over the shared Xiaxia design system.
class HouseMaterial {
  const HouseMaterial({
    required this.kind,
    required this.surfaceTint,
    required this.dividerTint,
  });

  final HouseKind kind;
  final Color surfaceTint;
  final Color dividerTint;
}

abstract final class HouseMaterials {
  static const reading = HouseMaterial(
    kind: HouseKind.reading,
    surfaceTint: Color(0xFFF2EDE2),
    dividerTint: Color(0xFFC8BCA6),
  );
  static const diary = HouseMaterial(
    kind: HouseKind.diary,
    surfaceTint: Color(0xFFF4EAE4),
    dividerTint: Color(0xFFD4BFB4),
  );
  static const watch = HouseMaterial(
    kind: HouseKind.watch,
    surfaceTint: Color(0xFF252724),
    dividerTint: Color(0xFF4B4F49),
  );
  static const reality = HouseMaterial(
    kind: HouseKind.reality,
    surfaceTint: Color(0xFFEDEDE7),
    dividerTint: Color(0xFFBFC2B9),
  );
  static const browser = HouseMaterial(
    kind: HouseKind.browser,
    surfaceTint: Color(0xFFEDE9DF),
    dividerTint: Color(0xFFC7BDAC),
  );
}
