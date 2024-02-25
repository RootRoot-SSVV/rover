import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rover_app/providers/bt_controller.dart';
import 'package:rover_app/providers/modules/demo_module_provider.dart';
import 'package:rover_app/providers/panels.dart';

/// UI demo modula
/// Sadrži tri [Switch]-a, tri [Slider]-a i jedan gumb
/// Koristi [DemoModuleProvider]
class DemoModulePanel extends StatelessWidget {
  const DemoModulePanel({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<Panels>(context, listen: false).changeToModule(context, 7);
    return Center(child:
        Consumer<DemoModuleProvider>(builder: (context, provider, child) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(children: [
              Switch(
                  value: provider.led1,
                  
                  /// Promijeni vrijednost i pošalji poruku.
                  onChanged: (bool value) => provider.led1Change(value,
                      Provider.of<BtController>(context, listen: false))),
              Switch(
                  value: provider.led2,
                  onChanged: (bool value) => provider.led2Change(value,
                      Provider.of<BtController>(context, listen: false))),
              Switch(
                  value: provider.led3,
                  onChanged: (bool value) => provider.led3Change(value,
                      Provider.of<BtController>(context, listen: false))),
              Switch(
                  value: provider.buzzer,
                  onChanged: (bool value) => provider.changeBuzzer(value,
                      Provider.of<BtController>(context, listen: false))),
            ]),
            Slider(
                value: provider.red,
                thumbColor: Colors.red,
                max: 250,
                divisions: 25,

                /// Promijeni vrijednost ali pošalji poruku samo kada se
                /// [Slider] odpusti.
                onChanged: (value) => provider.redChange(
                    value, Provider.of<BtController>(context, listen: false)),
                onChangeEnd: (value) => provider.sendMessage(
                    Provider.of<BtController>(context, listen: false))),
            Slider(
                value: provider.green,
                thumbColor: Colors.green,
                max: 250,
                divisions: 25,
                onChanged: (value) => provider.greenChange(
                    value, Provider.of<BtController>(context, listen: false)),
                onChangeEnd: (value) => provider.sendMessage(
                    Provider.of<BtController>(context, listen: false))),
            Slider(
                value: provider.blue,
                thumbColor: Colors.blue,
                max: 250,
                divisions: 25,
                onChanged: (value) => provider.blueChange(
                    value, Provider.of<BtController>(context, listen: false)),
                onChangeEnd: (value) => provider.sendMessage(
                    Provider.of<BtController>(context, listen: false)))
          ]);
    }));
  }
}
