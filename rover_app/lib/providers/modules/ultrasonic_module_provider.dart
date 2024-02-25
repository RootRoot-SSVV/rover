import 'package:flutter/material.dart';
import 'package:rover_app/providers/bt_controller.dart';

import 'dart:developer' as dev;

/// Demo modul provider
///
/// Sadrži jedan ultrasonic modul
/// Šalje i prima podatke
/// Šalje u formatu
///   [trig]
/// Prima u formatu
///   [prvi broj][drugi broj]
///   udaljenost = prvi broj + drugi broj
class UltrasonicModuleProvider extends ChangeNotifier {
  int distance = 0;

  void getDistance(List<int> inputBuffer) {
    distance = inputBuffer[1] + inputBuffer[2];
    notifyListeners();
  }

  /// Pokreće funkciju koje je aktivna u pozadini cijelo vrijeme
  /// Svake pola sekunde pošalji ping za osvježavanje udaljenosti ako je 
  /// odabran taj modul
  void startUltrasonicService(BtController bt) async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 2500), () {
        if (bt.mode == 1) {
          dev.log('us sent');
          bt.sendMessage();
        }
      });
    }
  }
}
