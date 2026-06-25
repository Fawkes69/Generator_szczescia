import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  String name = '';
  Mood mood = Mood.neutral;
  Color favoriteColor = Colors.blue;
  int tempo = 75;
  String imageTheme = 'abstract';
  double complexity = 0.5;

  void updateName(String newName) {
    name = newName;
    notifyListeners();
  }

  void updateMood(Mood newMood) {
    mood = newMood;
    notifyListeners();
  }

  void updateColor(Color newColor) {
    favoriteColor = newColor;
    notifyListeners();
  }

  void updateTempo(int newTempo) {
    tempo = newTempo;
    notifyListeners();
  }

  void updateTheme(String newTheme) {
    imageTheme = newTheme;
    notifyListeners();
  }

  void updateComplexity(double newComplexity) {
    complexity = newComplexity;
    notifyListeners();
  }
  Color get invertedColor => Color.fromARGB(
    (favoriteColor.a * 255.0).round().clamp(0, 255),
    ((1.0 - favoriteColor.r) * 255.0).round().clamp(0, 255),
    ((1.0 - favoriteColor.g) * 255.0).round().clamp(0, 255),
    ((1.0 - favoriteColor.b) * 255.0).round().clamp(0, 255),
  );
}

enum Mood {
  happy('Wesoły', '😊'),
  sad('Smutny', '😢'),
  energetic('Energetyczny', '⚡'),
  calm('Spokojny', '🌊'),
  neutral('Neutralny', '😐');

  final String displayName;
  final String emoji;

  const Mood(this.displayName, this.emoji);
}