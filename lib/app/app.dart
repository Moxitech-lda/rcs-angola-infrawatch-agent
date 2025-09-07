import 'dart:async';

import 'package:agent_infra_watch/app/machine_dao.dart';
import 'package:flutter/material.dart';
import 'package:agent_infra_watch/app/feature/config/config_page.dart';
import 'package:agent_infra_watch/app/feature/home/home_page.dart';

//import 'package:agent_infra_watch/app/feature/home/home_page.dart';
late SyncManager syncManager;

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.tokem});
  final String? tokem;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Timer timer;
  @override
  void initState() {
    super.initState();
    syncManager = SyncManager();
    syncManager.syncronize(context);
    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      syncManager.syncronize(context);
    });
  }

  @override
  void dispose() {
    timer.cancel();
    syncManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InfraWatch',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 23, 150, 255),
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          surface: Colors.black,
          scrim: const Color.fromARGB(255, 15, 23, 43),
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 23, 150, 255),
        ),
      ),
      home: widget.tokem == null ? const ConfigPage() : HomePage(),
    );
  }
}

class SyncManager {
  final dao = MachineDAO();

  bool isSyncRunning = false;
  bool _isSyncRunning = false;
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(seconds: 5);
  static const _batchSize = 5;
  static const _syncDelay = Duration(milliseconds: 500);

  void syncronize(BuildContext context) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (!_isSyncRunning) {
        _resolveSyncronization(context);
      }
    });
  }

  Future<void> _resolveSyncronization(BuildContext context) async {
    if (_isSyncRunning) return;
    _isSyncRunning = true;

    try {
      final noSincronized = (await dao.getAll())
          .where((e) => !e.syncronized)
          .toList();

      int syncronizads = 0;

      for (var i = 0; i < noSincronized.length; i += _batchSize) {
        final batch = noSincronized.skip(i).take(_batchSize).toList();

        for (var m in batch) {
          try {
            final res = await dao.syncronizeMachine(m, context);
            if (res) {
              isSyncRunning = true;
              m.syncronized = true;
              await dao.update(m, context, false);
              syncronizads++;
            } else {}
            await Future.delayed(_syncDelay);
          } catch (e) {}
        }
        isSyncRunning = false;
      }

      if (syncronizads > 0) {
        isSyncRunning = false;
      }
    } catch (e) {
    } finally {
      isSyncRunning = false;
      _isSyncRunning = false;
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}
