import 'package:flutter/material.dart';
import 'package:rover_app/panel_screens/panel.dart';
import 'package:rover_app/widgets/control_button.dart';

/// UI za kontrolu rovera
///
/// Sa lijeve i desne strane su gumbi za pomjeranje rovera.
/// U sredini je manji ekran koji se može mijenjati s obzirom koji modul
/// koristimo.
class RoverControlScreen extends StatelessWidget {
  const RoverControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          /// Gumbi s ljeve strane
          Expanded(
              flex: 2,
              child: Center(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: const [
                    ControlButton(icon: Icons.arrow_upward, value: 2),
                    ControlButton(icon: Icons.arrow_downward, value: 1)
                  ],
                ),
              )),

          /// Ekran u sredini
          const Expanded(flex: 6, child: Panel()),

          /// Gumbi s desne strane
          Expanded(
              flex: 2,
              child: Center(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: const [
                    ControlButton(icon: Icons.arrow_back, value: 4),
                    ControlButton(icon: Icons.arrow_forward, value: 8)
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
