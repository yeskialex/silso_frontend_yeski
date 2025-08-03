import 'package:flutter/foundation.dart';

/// Immutable data model representing the virtual pet’s stats.
@immutable
class PetModel {
  final int cleanliness; // 0-100: 100 = perfectly clean
  final int happiness;  // 0-100: 100 = very happy
  final int hunger;     // 0-100: 0 = full, 100 = starving
  final int xp;         // 0-99: current experience points toward next level
  final int level;      // 1+ : pet level

  const PetModel({
    required this.cleanliness,
    required this.happiness,
    required this.hunger,
    required this.xp,
    required this.level,
  });

  /// Factory providing sensible default starting values.
  static const PetModel initial = PetModel(
    cleanliness: 80,
    happiness: 80,
    hunger: 20,
    xp: 0,
    level: 1,
  );

  /// Percentage (0-1) of XP toward next level. Useful for progress bars.
  double get xpPercent => (xp.clamp(0, 100)) / 100;

  /// Creates a copy with modified fields.
  PetModel copyWith({
    int? cleanliness,
    int? happiness,
    int? hunger,
    int? xp,
    int? level,
  }) {
    return PetModel(
      cleanliness: cleanliness ?? this.cleanliness,
      happiness: happiness ?? this.happiness,
      hunger: hunger ?? this.hunger,
      xp: xp ?? this.xp,
      level: level ?? this.level,
    );
  }

  @override
  String toString() =>
      'PetModel(cleanliness: $cleanliness, happiness: $happiness, hunger: $hunger, xp: $xp, level: $level)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetModel &&
          runtimeType == other.runtimeType &&
          cleanliness == other.cleanliness &&
          happiness == other.happiness &&
          hunger == other.hunger &&
          xp == other.xp &&
          level == other.level;

  @override
  int get hashCode => Object.hash(cleanliness, happiness, hunger, xp, level);
}
