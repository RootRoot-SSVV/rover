import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rover_app/providers/modules/ultrasonic_module_provider.dart';
import 'package:rover_app/providers/panels.dart';

/// UI ultrasonic modula
/// Sadrži prikaz podataka senzora udaljenosti
/// Koristi [UltrasonicModuleProvider]
class UltrasonicModulePanel extends StatelessWidget {
  const UltrasonicModulePanel({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<Panels>(context, listen: false).changeToModule(context, 1);

    return Consumer<UltrasonicModuleProvider>(
      builder: (context, provider, child) {
        return Center(child: Text('${provider.distance} cm', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),));
      },
    );
  }
}
