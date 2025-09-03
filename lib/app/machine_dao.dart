import 'dart:convert';

import 'package:agent_infra_watch/app/api_server.dart';
import 'package:agent_infra_watch/app/config_dao.dart';
import 'package:agent_infra_watch/app/feature/home/tabs/agent_controller.dart';
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
  String tipoDispositivo;

  Machine({
    required this.id,
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
  String chackInterval;
  String dataTime;
  String target;
  String idAgent;

  MachineToServer({
    required this.id,
    required this.nome,
    required this.idType,
    required this.conectionType,
    required this.status,
    required this.chackInterval,
    required this.dataTime,
    required this.target,
    required this.idAgent,
  });

  Map<String, dynamic> toMap() => {
    "id": id,
    "nome": nome,
    "idType": idType,
    "conectionType": conectionType,
    "status": status,
    "chackInterval": chackInterval,
    "dataTime": dataTime,
    "target": target,
    "idAgent": idAgent,
  };
}

class MachineDAO {
  Future<bool> sendPostRequest(
    BuildContext context,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          "https://infrawatch-backend.onrender.com/api/integrations/agents",
        ),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },

        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] == 'OK';
      } else {
        final data = jsonDecode(response.body);
        if (context.mounted) {
          AgentController.showAgentResultDialog(context, '${data['error']}');
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        AgentController.showAgentResultDialog(
          context,
          'Falha ao tentar comunicar com a internet.',
        );
      }
      return false;
    }
  }

  Future<int> insert(Machine m, BuildContext context) async {
    final chackInterval =
        (await ConfigDAO().getConfig('frequence')) ?? 'unknow';
    final idAgent = (await ConfigDAO().getConfig('code_agent')) ?? 'unknow';

    final serverData = MachineToServer(
      id: m.id,
      nome: m.nome,
      idType: m.tipoDispositivo,
      conectionType: m.tipoMonitoramento == TipoMonitoramento.wmi
          ? 'wmi'
          : 'ping',
      status: m.ativo ? 'up' : 'down',
      chackInterval: chackInterval,
      dataTime: DateTime.now().toString(),
      target: m.ip,
      idAgent: idAgent,
    );

    // if (context.mounted) {
    //   final res = await sendPostRequest(context, serverData.toMap());

    //   if (!res) return -1;
    // }

    final db = await DBHelper.instance.database;
    return await db.insert("Machines", m.toMap());
  }

  Future<List<Machine>> getAll() async {
    final db = await DBHelper.instance.database;
    final result = await db.query("Machines");
    return result.map((e) => Machine.fromMap(e)).toList();
  }

  Future<int> update(Machine m) async {
    final db = await DBHelper.instance.database;
    return await db.update(
      "Machines",
      m.toMap(),
      where: "Id = ?",
      whereArgs: [m.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await DBHelper.instance.database;
    return await db.delete("Machines", where: "Id = ?", whereArgs: [id]);
  }
}
