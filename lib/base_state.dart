import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:access_settings_menu/access_settings_menu.dart';



/// a base class for any statful widget for checking internet connectivity
abstract class BaseState<T extends StatefulWidget> extends State<T> {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  /// the internet connectivity status
  bool isOnline = true;

  /// initialize connectivity checking
  /// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    await updateConnectionStatus().then((bool isConnected) =>
        setState(() {
          isOnline = isConnected;
        }));
  }


  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      await updateConnectionStatus().then((bool isConnected) =>
          setState(() {
            isOnline = isConnected;
            print('Connected: ' + isOnline.toString());
            if (!isOnline) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => _connectionDialog(context),
              );


//          Toast.show('You do not have internet connection', context,
//              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
////        showToast('Hello FilledStacks', position: ToastPosition.bottom);
            }
          }
          ));
    });
  }


  _connectionDialog(context) {
    return AlertDialog(
      title: Center(
        child: Text('Internet interruption'),
      ),
      content: Text('No internet. Please check your internet connection.'),
      actions: <Widget>[
        FlatButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Network setting'),
          onPressed: () {
            openSettingsMenu('ACTION_WIFI_SETTINGS');
            Navigator.pop(context, true);
          },
        )
      ],
    );
  }

  openSettingsMenu(settingsName) async {
    var resultSettingsOpening = false;

    try {
      resultSettingsOpening =
      await AccessSettingsMenu.openSettings(settingsType: settingsName);
    } catch (e) {
      resultSettingsOpening = false;
    }
  }


  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  void deactivate() {
    _connectivitySubscription.pause();
    super.deactivate();
  }



  Future<bool> updateConnectionStatus() async {
    bool isConnected;
    try {
      final List<InternetAddress> result =
      await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
      return false;
    }
    return isConnected;
  }
}