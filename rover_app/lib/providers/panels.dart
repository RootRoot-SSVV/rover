// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rover_app/panel_screens/screens/demo_module.dart';
import 'package:rover_app/panel_screens/screens/main_panel.dart';
import 'package:rover_app/panel_screens/screens/matrix_module.dart';
import 'package:rover_app/panel_screens/screens/ultrasonic_module.dart';
import 'package:rover_app/providers/bt_controller.dart';

/// Provider za kontroliranje panela (ekrana modula)
class Panels extends ChangeNotifier {
  /// Informacije o trenutnom panelu i ID svih panela

  final Map<int, StatelessWidget> moduleById = {
    16: const MainPanel(),
    1: const UltrasonicModulePanel(),
    2: const MatrixModulePanel(),
    7: const DemoModulePanel()
  };

  int currentPageIndex = 0;

  List<Widget> listOfPanels = [MainPanel()];

  List<Tab> listOfTabButtons = [Tab(text: 'Start', icon: Icon(Icons.home))];

  /// Osvježi listu panela i UI
  void updateLists(List<int> message) {
    List<int> connectedModules = List.from(message.getRange(2, 2 + message[1]));

    listOfPanels.clear();
    listOfTabButtons.clear();

    listOfPanels.add(moduleById[16]!);
    listOfTabButtons.add(const Tab(text: 'Start', icon: Icon(Icons.home)));

    for (int i = 0; i < connectedModules.length; i++) {
      listOfPanels.add(moduleById[connectedModules[i]]!);
      listOfTabButtons.add(Tab(text: connectedModules[i].toString(), icon: Icon(getCustomIcon(connectedModules[i]))));
    }
    notifyListeners();
  }

  List<Widget> getPanels() {
    return listOfPanels;
  }

  /// Promjeni modul i pošalji signal za promjenu modula
  void changeToModule(BuildContext context, int mode) {
    final provider = Provider.of<BtController>(context, listen: false);
    if (provider.mode != mode) {
      Provider.of<BtController>(context, listen: false).mode = mode;
      Provider.of<BtController>(context, listen: false)
          .sendMessage(changingModule: true);
    }
  }

  /// Dohvati određenu ikonu ovisno o modulu
  IconData getCustomIcon(int id) {
    if (id == 1) return Icons.straighten;
    if (id == 2) return Icons.apps;
    return Icons.view_agenda;
  }
}
