import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:rover_app/providers/modules/demo_module_provider.dart';
import 'package:rover_app/providers/modules/matrix_module_provider.dart';
import 'package:rover_app/providers/modules/ultrasonic_module_provider.dart';

import 'dart:developer' as dev;

import 'package:rover_app/providers/panels.dart';

/// Provider za Bluetooth. Sadrži svu logiku za slanje i primanje
///
/// Šalje se i prima niz brojeva. Prva tri polja su važna jer određuju što se
/// kontrolira.
/// Pravila komunikacije:
///
/// Niz koji se šalje:
/// [254][ID moda][smjer pokretanja][ostali podaci] ... [ostali podaci]
///
/// [254]               ->  Početno polje
/// [ID moda]           ->  Id koji služi za kontrolu modula ili drugu
///                         specijalnu akciju
/// [smjer pokretanja]  ->  U binarnom obliku sprema koji je motor upaljen
/// [ostali podaci]     ->  Podaci koji su potrebni za modul
///
/// ID moda:
///   1 - 15  ->  moduli
///   16      ->  nema posebne akcije
///   17      ->  ponovno skeniraj module
///   19      ->  promjeni modul
class BtController extends ChangeNotifier {
  /// Provideri za module

  final DemoModuleProvider demoModuleProvider;
  final UltrasonicModuleProvider ultrasonicModuleProvider;
  final MatrixModuleProvider matrixModuleProvider;

  ///

  /// Provider za panele
  final Panels _panelsProvider;

  /// Podaci koji se šalju i primaju putem Bluetooth-a
  List<int> inputBuffer = List<int>.empty(growable: true);
  int motorControl = 0;
  List<int> dataForModule = List.filled(62, 0);
  List<int> connectedModules = List<int>.empty(growable: true);
  int mode = 16;

  bool sending = false;

  /// Vrijednosti koje služe za spajanje i održavanje povezanosti s roverom
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  bool bluetoothIsOn = true;
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;
  Timer? _discoverableTimeoutTimer;
  BluetoothConnection? connection;

  /// Konstruktor za [BtController] zahtjeva Provider za panele i module.
  /// Pri svakom stvaranju modula dodati argument
  BtController(
    this._panelsProvider,
    this.demoModuleProvider,
    this.ultrasonicModuleProvider,
    this.matrixModuleProvider,
  ) {
    services();

    FlutterBluetoothSerial.instance.state
        .then((state) => _bluetoothState = state);

    notifyListeners();

    Future.doWhile(() async {
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {});

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      _bluetoothState = state;
      _discoverableTimeoutTimer = null;
    });
  }

  void services() {
    ultrasonicModuleProvider.startUltrasonicService(this);
  }

  /// Kreni prikupljanje podataka.
  /// Kada se prikupi dovoljno podataka izvrši akciju (60 bitova).
  /// Nakon obrade izbriši podatke iz [inputBuffer].
  BtController.fromCollection(
      this.connection,
      this._panelsProvider,
      this.demoModuleProvider,
      this.ultrasonicModuleProvider,
      this.matrixModuleProvider) {
    connection?.input!.listen((data) {
      inputBuffer += data;

      while (true) {
        int index = inputBuffer.indexOf(254);
        if (index >= 0 && inputBuffer.length - index >= 60) {
          List<int> dataReceivedList =
              List.from(inputBuffer.getRange(index + 1, index + 60));
          messageReaction(dataReceivedList);
          inputBuffer.removeRange(0, index + 60);
        } else {
          break;
        }
      }
      notifyListeners();
    }).onDone(() {
      dev.log('Disconnected');
    });
  }

  /// Spoji se s Bluetooth uređajem s zadanom adresom
  Future<BtController> connectWith(String address) async {
    _streamSubscription?.cancel();
    connection = await BluetoothConnection.toAddress(address);
    return BtController.fromCollection(connection, _panelsProvider,
        demoModuleProvider, ultrasonicModuleProvider, matrixModuleProvider);
  }

  /// Započni traženje uređaja
  ///
  /// Pri svakom nađenom uređaju osvježi zaslon
  void startDiscovery() {
    if (_bluetoothState == BluetoothState.ERROR ||
        _bluetoothState == BluetoothState.STATE_OFF ||
        _bluetoothState == BluetoothState.UNKNOWN) {
      bluetoothIsOn = false;
      return;
    }

    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      final existingIndex = results
          .indexWhere((element) => element.device.address == r.device.address);
      if (existingIndex >= 0) {
        results[existingIndex] = r;
      } else {
        results.add(r);
      }
      notifyListeners();
    });
    _streamSubscription!.onDone(() {
      isDiscovering = false;
      notifyListeners();
    });
  }

  /// Izbriši rezultate i ponovno skeniraj
  void restartDiscovery() {
    results.clear();
    isDiscovering = true;

    startDiscovery();
  }

  /// Odspoji se od uređaja
  @override
  void dispose() {
    super.dispose();
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
  }

  /// Pridruži funkcije zadanom ID-u i modulu
  ///
  /// Na osnovu prvog polja biti će drugačija reakcija
  /// Reakcija se dodaje samo modulima koji imaju povratnu poruku roveru
  void messageReaction(List<int> message) {
    switch (message[0]) {
      case 1:
        /// Ultrasonic modul
        ultrasonicModuleProvider.getDistance(message);
        break;
      case 2:
        /// Matrix modul
        /// Nema povratnu informaciju
        break;
      case 3:
        /// ID je neiskorišten
        break;
      case 4:
        /// ID je neiskorišten
        break;
      case 5:
        /// ID je neiskorišten
        break;
      case 6:
        /// ID je neiskorišten
        break;
      case 7:
        /// Demo modul
        /// Nema povratnu informaciju
        break;
      case 17:
        /// Ponovno skeniranje
        _panelsProvider.updateLists(message);
        break;
      default:
        dev.log('no case');
        break;
    }
    notifyListeners();
  }

  /// Promjeni [dataForModule]
  ///
  /// Promjeni samo dio koji se ondosi na podatke za modul
  void changeDataForModule(List<int> list) {
    for (int i = 0; i < list.length; i++) {
      dataForModule[i] = list[i];
    }
  }

  /// Pošalji poruku roveru
  void sendMessage({bool changingModule = false}) async {
    sending = true;
    Uint8List message;
    if (!changingModule) {
      message = Uint8List.fromList([254, mode, motorControl] + dataForModule);
    } else {
      message = Uint8List.fromList(
          [254, 19, motorControl, mode] + List.filled(61, 0));
    }

    dev.log('$message');

    try {
      connection!.output.add(message);
      await connection!.output.allSent;
    } catch (e) {
      dev.log('Catch in: void sendMessage()');
    }
    sending = false;
  }

  /// Šalje signal za skeniranje modula
  ///
  /// Mijenja mod na skeniranje (18), šalje poruku i vraća na neutralno (16)
  void scanForModules() async {
    mode = 18;
    sendMessage();
    mode = 16;
    notifyListeners();
  }
}
