import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rover_app/assets/icons/my_icons.dart';
import 'package:rover_app/providers/bt_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rover_app/l10n/l10n.dart';
import 'package:rover_app/l10n/locale_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Prikazuje popis dostupnih uređaja
///
/// Sadrži mogućnost mijenjanja jezika, pretraživanja uređaja i spajanja na rover.
/// Osim toga prikazuje informacije o aplikaciji.
class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({super.key});

  /// Funkcija koja otvara repozitoriji repozitoriji projekta ili dokumentaciju
  void launchURL(String urlString) async {
    Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(builder: (context, provider, snapshot) {
      /// Određuje jezik, jezik uređaja ili odabrani jezik
      var lang = provider.locale ?? Localizations.localeOf(context);

      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.discover_devices),
          actions: <Widget>[
            /// Stvara [DropdownButton] s popisom jezika
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 0.0),
              child: DropdownButton(
                selectedItemBuilder: (_) {
                  return L10n.all
                      .map((e) => Container(
                          alignment: Alignment.center,
                          child: Text(getLanguageName(e))))
                      .toList();
                },
                value: lang,
                items: L10n.all
                    .map((e) => DropdownMenuItem(
                        value: e, child: Text(provider.getLanguageName(e))))
                    .toList(),
                onChanged: (Locale? val) {
                  provider.setLocale(val!);
                },
              ),
            ),

            /// Stvara [IconButton] za informacije, može se pristupiti
            /// dokumentaciji i licencama
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
              child: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                      String appName = packageInfo.appName;
                      String version = packageInfo.version;
                      showAboutDialog(
                          context: context,
                          applicationName: appName,
                          applicationVersion: version,
                          children: <Widget>[
                            /// Popis stvari u [showAboutDialog]-u
                            ListTile(
                                dense: true,
                                leading: const Icon(MyIcons.github),
                                title: const Text('GitHub'),
                                onTap: () async {
                                  Uri url = Uri.parse(
                                      'https://github.com/RootRoot-SSVV/rover_app');
                                  if (!await launchUrl(url)) {
                                    throw Exception('Could not launch $url');
                                  }
                                }),
                            ListTile(
                                dense: true,
                                leading: const Icon(Icons.article_outlined),
                                title: Text(AppLocalizations.of(context)!.docs),
                                onTap: () async {
                                  Uri url = Uri.parse('https://google.com');
                                  if (!await launchUrl(url)) {
                                    throw Exception('Could not launch $url');
                                  }
                                }),
                            ListTile(
                                dense: true,
                                leading: const Icon(Icons.privacy_tip_outlined),
                                title: Text(AppLocalizations.of(context)!
                                    .privacy_policy),
                                onTap: () => context.go('/privacyPolicy'))
                          ]);
                    });
                  }),
            )
          ],
        ),

        /// Sadržava popis svih skeniranih uređaja i njihove mac adrese.
        /// Pitiskom na uređaj se započinje spajanje i prebaci na kontrole.
        body: Consumer<BtController>(builder: (context, value, child) {
          return ListView.builder(
            itemCount: value.results.length,
            itemBuilder: (context, index) {
              BluetoothDiscoveryResult result = value.results[index];
              final device = result.device;
              final address = result.device.address;

              return ListTile(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                leading: const Icon(Icons.bluetooth),
                title:
                    Text(device.name ?? AppLocalizations.of(context)!.no_name),
                subtitle: Text(address),
                onTap: () {
                  value.connectWith(address);
                  context.go('/controlScreen');
                },
              );
            },
          );
        }),

        /// [FloatingActionButton] koji služi za ponovno skeniranje.
        ///
        /// Dok [isDiscovering] je `true` animiraj učitavanje.
        /// Ako je Bluetooth isključen upozori i izađi iz aplikacije.
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Provider.of<BtController>(context).isDiscovering
              ? FittedBox(
                  child: Container(
                      margin: const EdgeInsets.all(16.0),
                      child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white))))
              : IconButton(
                  onPressed: () {
                    Provider.of<BtController>(context, listen: false)
                        .restartDiscovery();
                    if (!Provider.of<BtController>(context, listen: false)
                        .bluetoothIsOn) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: Text(AppLocalizations.of(context)!.bluetooth_error_label),
                                content: Text(
                                    AppLocalizations.of(context)!.bluetooth_error),
                                actions: [
                                  TextButton(
                                      onPressed: () => exit(0),
                                      child: Text(AppLocalizations.of(context)!.ok))
                                ],
                              ));
                    }
                  },
                  icon: const Icon(Icons.replay)),
        ),
      );
    });
  }
}
