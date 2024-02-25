import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rover_app/providers/bt_controller.dart';
import 'package:rover_app/l10n/l10n.dart';
import 'package:rover_app/l10n/locale_provider.dart';
import 'package:rover_app/providers/modules/demo_module_provider.dart';
import 'package:rover_app/providers/modules/matrix_module_provider.dart';
import 'package:rover_app/providers/modules/ultrasonic_module_provider.dart';
import 'package:rover_app/providers/panels.dart';
import 'package:rover_app/screens/device_list_screen.dart';
import 'package:rover_app/screens/privacy_policy_screen.dart';
import 'package:rover_app/screens/rover_control_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rover_app/themes/blue.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  /// Provideri za module (dodajte ako mislite napraviti modul)

  DemoModuleProvider demoModuleProvider = DemoModuleProvider();
  UltrasonicModuleProvider ultrasonicModuleProvider =
      UltrasonicModuleProvider();
  MatrixModuleProvider matrixModuleProvider = MatrixModuleProvider();

  /// ---------------------

  /// Provideri za panele i Bluetooth
  Panels panels = Panels();
  BtController btController =
      BtController(panels, demoModuleProvider, ultrasonicModuleProvider, matrixModuleProvider);

  /// Paljenje aplikacije i postavljane je horizontalno
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((value) {
    [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request().then((status) {
      runApp(MultiProvider(providers: [
        ChangeNotifierProvider(create: (_) => btController),
        ChangeNotifierProvider(create: (_) => panels),
        ChangeNotifierProvider(create: (_) => demoModuleProvider),
        ChangeNotifierProvider(create: (_) => ultrasonicModuleProvider),
        ChangeNotifierProvider(create: (_) => matrixModuleProvider)
      ], child: const MainApp()));
    });
  });
}

/// Svi ekrani
final GoRouter _router = GoRouter(routes: <RouteBase>[
  GoRoute(path: '/', builder: (context, state) => const DeviceListScreen()),
  GoRoute(
    path: '/controlScreen',
    builder: (context, state) => const RoverControlScreen(),
  ),
  GoRoute(
      path: '/privacyPolicy',
      builder: (context, state) => const PrivacyPolicyScreen())
]);

/// Postavljanje lokalizacije i teme aplikacije
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => LocaleProvider())],
        child: Consumer<LocaleProvider>(builder: (context, provider, snapshot) {
          return MaterialApp.router(
              theme:
                  ThemeData(useMaterial3: true, colorScheme: lightBlueScheme),
              darkTheme:
                  ThemeData(useMaterial3: true, colorScheme: darkBlueScheme),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              supportedLocales: L10n.all,
              routerConfig: _router,
              debugShowCheckedModeBanner: false,
              locale: provider.locale);
        }));
  }
}
