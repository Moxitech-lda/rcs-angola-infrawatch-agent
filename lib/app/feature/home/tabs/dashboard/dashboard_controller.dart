import 'dart:async';

import 'package:agent_infra_watch/app/api_server.dart';
import 'package:agent_infra_watch/app/machine_dao.dart';
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
bool IsRuning = false;
bool communicationServer = false;

class DashboardController extends ChangeNotifier {
  List<MaquinaMonitorada> maquinas = [];
  final dao = MachineDAO();
  final api = ApiService();
  bool bancoVazio = false;
  bool firstLoad = true;
  late Timer timer;
}
