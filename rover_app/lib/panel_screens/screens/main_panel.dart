import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rover_app/providers/bt_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rover_app/providers/panels.dart';

/// Glavni panel
///
/// Služi za izlazak iz aplikacije i ponovno skeniranje modula
class MainPanel extends StatelessWidget {
  const MainPanel({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<Panels>(context, listen: false).changeToModule(context, 16);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Gumb za izlaz
          OutlinedButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.exit_label),
                content: Text(AppLocalizations.of(context)!.exit_text),
                actions: [
                  TextButton(onPressed: () => exit(0), child: Text(AppLocalizations.of(context)!.exit_yes)),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.exit_no)),
                ],
              ),
            ),
            icon: const Icon(Icons.exit_to_app),
            label: Text(AppLocalizations.of(context)!.exit_button),
          ),
          /// Gumb za ponovno skeniranje
          Consumer<BtController>(
            builder: (context, btController, child) {
              return OutlinedButton.icon(
                onPressed: () => btController.scanForModules(),
                icon: const Icon(Icons.replay),
                label: Text(AppLocalizations.of(context)!.rescan_button),
              );
            },
          ),
        ],
      ),
    );
  }
}
