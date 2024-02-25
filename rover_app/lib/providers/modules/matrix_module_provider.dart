import 'package:flutter/material.dart';
import 'package:rover_app/providers/bt_controller.dart';

class MatrixModuleProvider extends ChangeNotifier {
  List<List<bool>> gridState =
      List.generate(8, (index) => List.filled(8, false, growable: false));

  void changeGridState(BtController bt, int row, int col) {
    gridState[row][col] = !gridState[row][col];
    sendMessage(bt);
    notifyListeners();
  }

  /// Funckija slanja poruke u zadanom formatu
  /// Pretvara 2D listu u 1D listu s brojevima
  /// Jedan broj -> jedan red, odnosno jedan boolean -> jedan bit
  void sendMessage(BtController bt) {
    List<int> message = [];

    int currentInt = 0;
    int bitPosition = 0;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (gridState[i][j]) {
          currentInt |= (1 << bitPosition);
        }
        bitPosition++;
        if (bitPosition == 8) {
          message.add(currentInt);
          currentInt = 0;
          bitPosition = 0;
        }
      }
    }

    if (bitPosition > 0) {
      message.add(currentInt);
    }

    bt.changeDataForModule(message);
    bt.sendMessage();
  }
}
