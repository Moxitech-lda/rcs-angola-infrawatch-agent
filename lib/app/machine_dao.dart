import 'dart:convert';

import 'package:agent_infra_watch/app/api_server.dart';
import 'package:agent_infra_watch/app/config_dao.dart';
import 'package:agent_infra_watch/app/feature/geo_location_service.dart';
import 'package:agent_infra_watch/app/feature/home/tabs/agent_controller.dart';
import 'package:agent_infra_watch/app/feature/home/tabs/dashboard/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'db_helper.dart';

class Machine {
  String id;
  String nome;
  String ip;
  String? usuario;
  String? senha;
  TipoMonitoramento tipoMonitoramento;
  bool ativo;
  bool syncronized;
  String tipoDispositivo;

  Machine({
    required this.id,
    required this.syncronized,
    required this.nome,
    required this.ip,
    this.usuario,
    this.senha,
    required this.tipoMonitoramento,
    required this.ativo,
    required this.tipoDispositivo,
  });

  Map<String, dynamic> toMap() => {
    "Id": id,
    "Syncronized": syncronized ? 1 : 0,
    "Nome": nome,
    "IP": ip,
    "Usuario": usuario,
    "Senha": senha,
    "TipoMonitoramento": tipoMonitoramento.index,
    "Ativo": ativo ? 1 : 0,
    "TipoDispositivo": tipoDispositivo,
  };

  factory Machine.fromMap(Map<String, dynamic> map) {
    return Machine(
      id: map["Id"],
      syncronized: map["Syncronized"] == 1,
      nome: map["Nome"],
      ip: map["IP"],
      usuario: map["Usuario"],
      senha: map["Senha"],
      tipoMonitoramento: TipoMonitoramento.values[map["TipoMonitoramento"]],
      ativo: map["Ativo"] == 1,
      tipoDispositivo: map["TipoDispositivo"],
    );
  }
}

class MachineToServer {
  String id;
  String nome;
  String idType;
  String conectionType;
  String status;
  int checkInterval;
  String dataTime;
  String target;
  String idAgent;
  String idCompany;
  double lat;
  double lng;

  MachineToServer({
    required this.id,
    required this.idCompany,
    required this.lat,
    required this.lng,
    required this.nome,
    required this.idType,
    required this.conectionType,
    required this.status,
    required this.checkInterval,
    required this.dataTime,
    required this.target,
    required this.idAgent,
  });

  Map<String, dynamic> toMap() => {
    "id": id,
    "company_id": idCompany,
    "nome": nome,
    "lat": lat,
    "lng": lng,
    "idType": idType,
    "conectionType": conectionType,
    "status": status,
    "checkInterval": checkInterval,
    "dataTime": dataTime,
    "target": target,
    "idAgent": idAgent,
  };
}

//
// https://infrawatch-backend.onrender.com/api/integrations/agents/systems/met

class MachineDAO {
  Future<bool> _sendPostRequest(
    BuildContext context,
    Map<String, dynamic> body,
  ) async {
    final tokem = (await ConfigDAO().getConfig('token')) ?? 'unknow';
    try {
      final response = await http.post(
        Uri.parse(
          "https://infrawatch-backend.onrender.com/api/integrations/agents/$tokem/systems",
        ),

        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },

        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        if (context.mounted) {
          AgentController.showAgentResultDialog(context, '${data['error']}');
        }
        return false;
      }
    } catch (e) {
      // if (context.mounted) {
      //   AgentController.showAgentResultDialog(
      //     context,
      //     'Falha ao tentar comunicar com a internet.',
      //   );
      // }
      return false;
    }
  }

  Future<bool> syncronizeMachine(Machine m, BuildContext context) async {
    try {
      final geo = await GeoLocationService().getLocation();

      final checkInterval = (await ConfigDAO().getConfig('frequence')) ?? '5';

      final idAgent = (await ConfigDAO().getConfig('code_agent')) ?? 'unknow';

      final idCompany = (await ConfigDAO().getConfig('id_company')) ?? '';

      final serverData = MachineToServer(
        lat: geo.latitude,
        lng: geo.longitude,
        idCompany: idCompany,
        id: m.id,
        nome: m.nome,
        idType: m.tipoDispositivo,
        conectionType: m.tipoMonitoramento == TipoMonitoramento.snmp
            ? 'snmp'
            : 'ping',
        status: IsRuning ? 'up' : 'down',
        checkInterval: int.parse(checkInterval),
        dataTime: DateTime.now().toString(),
        target: m.ip,
        idAgent: idAgent,
      );

      return await _sendPostRequest(context, serverData.toMap());
    } catch (e) {
      return false;
    }
  }

  Future<int> insert(Machine m, BuildContext context, [bool pop = true]) async {
    m.syncronized = await syncronizeMachine(m, context);
    final db = await DBHelper.instance.database;
    final res = await db.insert("Machines", m.toMap());
    if (context.mounted && pop) Navigator.pop(context);
    return res;
  }

  Future<List<Machine>> getAll() async {
    final db = await DBHelper.instance.database;
    final result = await db.query("Machines");
    return result.map((e) => Machine.fromMap(e)).toList();
  }

  Future<int> update(Machine m, BuildContext context, [bool pop = true]) async {
    final db = await DBHelper.instance.database;
    final res = await db.update(
      "Machines",
      m.toMap(),
      where: "Id = ?",
      whereArgs: [m.id],
    );

    if (context.mounted && pop) Navigator.pop(context);
    return res;
  }

  Future<int> delete(String id) async {
    final db = await DBHelper.instance.database;
    return await db.delete("Machines", where: "Id = ?", whereArgs: [id]);
  }
}

Future<bool> sendMetric(BuildContext context) async {
  final tokem = '32d667f0-8879-48a1-9087-8bf7e79bbc09';
  try {
    final response = await http.patch(
      Uri.parse(
        "https://infrawatch-backend.onrender.com/api/integrations/agents/$tokem/metrics",
      ),

      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },

      body: jsonEncode({
        'system_id': '32d667f0-8879-48a1-9087-8bf7e79bbc09',
        'status': 'up',
        'uptime_percent': 100,
        'downtime_minutes': 100,
        'sla_percent': 0,
        'value': {
          'ram': null,
          'cpu': null,
          'disk': null,
          'packetLoss': 0,
          'latency': 0,
        },
        'last_check': DateTime.now().toString(),
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 201) {
      return true;
    } else {
      final data = jsonDecode(response.body);
      print(data);

      if (context.mounted) {
        print(data);
        AgentController.showAgentResultDialog(context, '${data['error']}');
      }
      return false;
    }
  } catch (e) {
    print(e);
    // if (context.mounted) {
    //   AgentController.showAgentResultDialog(
    //     context,
    //     'Falha ao tentar comunicar com a internet.',
    //   );
    // }
    return false;
  }
}
