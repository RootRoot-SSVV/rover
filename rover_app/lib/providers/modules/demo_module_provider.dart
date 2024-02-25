import 'package:flutter/material.dart';
import 'package:rover_app/providers/bt_controller.dart';

/// Demo modul provider
///
/// Sadrži 3 LED diode, zujalicu i jednu RGB diodu.
/// Modul NE prima podatke.
/// Šalje podatke u formatu:
///   [led1][led2][led3][red][green][blue][zujalica]
class DemoModuleProvider extends ChangeNotifier {
  bool led1 = false, led2 = false, led3 = false, buzzer = false;
  double red = 0, green = 0, blue = 0;

  /// Iduće tri funkcije mijenjaju vrijednost i šalju poruku
  void led1Change(bool value, BtController bt) {
    led1 = value;
    sendMessage(bt);
    notifyListeners();
  }

  void led2Change(bool value, BtController bt) {
    led2 = value;
    sendMessage(bt);
    notifyListeners();
  }

  void led3Change(bool value, BtController bt) {
    led3 = value;
    sendMessage(bt);
    notifyListeners();
  }

  /// Iduće funkcije mijenjaju RGB vrijednosti
  void redChange(double value, BtController bt) {
    red = value;
    notifyListeners();
  }

  void greenChange(double value, BtController bt) {
    green = value;
    notifyListeners();
  }

  void blueChange(double value, BtController bt) {
    blue = value;
    notifyListeners();
  }

  void changeBuzzer(bool value, BtController bt) {
    buzzer = value;
    sendMessage(bt);
    notifyListeners();
  }

  /// Funckija slanja poruke u zadanom formatu
  void sendMessage(BtController bt) {
    List<int> message = [
      led1 ? 1 : 0,
      led2 ? 1 : 0,
      led3 ? 1 : 0,
      red.floor(),
      green.floor(),
      blue.floor(),
      buzzer ? 1 : 0
    ];
    bt.changeDataForModule(message);
    bt.sendMessage();
  }
}
