import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckInternet {
  static final Connectivity _connectivity = Connectivity();
  static List<ConnectivityResult> _connectionStatus = [];

  static Future<List<ConnectivityResult>> initConnectivity() async {
    List<ConnectivityResult> result = [];
    try {
      // Get all connectivity results
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      debugPrint('Connectivity check failed: ${e.toString()}');
      result = [ConnectivityResult.none];
    }
    return updateConnectionStatus(result);
  }

  static Future<List<ConnectivityResult>> updateConnectionStatus(List<ConnectivityResult> results) async {
    final List<ConnectivityResult> newStatus = [];

    for (var result in results) {
      switch (result) {
        case ConnectivityResult.wifi:
        case ConnectivityResult.mobile:
        case ConnectivityResult.ethernet:
          newStatus.add(result);
          break;
        case ConnectivityResult.none:
        default:
          newStatus.add(ConnectivityResult.none);
      }
    }

    _connectionStatus = newStatus;
    return _connectionStatus;
  }
}