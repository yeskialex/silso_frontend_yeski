import 'package:flutter/material.dart';

import '../models/pet_model.dart';

/// Provider that manages a [PetModel] instance.
/// Handles logic for updating status bars, gaining XP, etc.
class PetProvider extends ChangeNotifier {
  PetModel _pet = PetModel.initial;

  PetModel get pet => _pet;

  /// Example actions -------------------------------------------------------
  void clean() {
    _pet = _pet.copyWith(cleanliness: (_pet.cleanliness + 20).clamp(0, 100));
    _gainXp(5);
    notifyListeners();
  }

  void play() {
    _pet = _pet.copyWith(happiness: (_pet.happiness + 20).clamp(0, 100));
    _gainXp(5);
    notifyListeners();
  }

  void feed() {
    _pet = _pet.copyWith(hunger: (_pet.hunger - 20).clamp(0, 100));
    _gainXp(5);
    notifyListeners();
  }

  /// Internal -------------------------------------------------------------
  void _gainXp(int amount) {
    int newXp = _pet.xp + amount;
    int newLevel = _pet.level;
    if (newXp >= 100) {
      newLevel += 1;
      newXp = newXp - 100;
    }
    _pet = _pet.copyWith(level: newLevel, xp: newXp);
    notifyListeners();
  }
}
