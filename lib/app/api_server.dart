import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agent_infra_watch/app/machine_dao.dart';

enum TipoMonitoramento { ping, snmp }

//{"uptime_percent":100,"downtime_minutes":0,"sla_percent":0,"value":{"ram":null,"cpu":null,"disk":null,"packetLoss":0,"latency":27}}

class MaquinaMonitorada {
  final String id;
  final String nome;
  final String ip;
  final TipoMonitoramento tipoMonitoramento;
  final String tipoDispositivo;
  final String status;
  final double cpuPercent;
  final double ramPercent;
  final double diskPercent;
  final bool sync;
  final String lastCheck;
  final int uptimePercent;
  final int downtimeMinutes;
  final int slaPercent;
  final int packetLoss;
  final int latency;

  final bool? ativo;

  MaquinaMonitorada({
    required this.tipoDispositivo,
    required this.lastCheck,
    required this.uptimePercent,
    required this.downtimeMinutes,
    required this.slaPercent,
    required this.packetLoss,
    required this.latency,
    required this.id,
    this.ativo,
    required this.sync,
    required this.nome,
    required this.ip,
    required this.tipoMonitoramento,
    required this.status,
    required this.cpuPercent,
    required this.ramPercent,
    required this.diskPercent,
  });

  Machine toMachine() {
    return Machine(
      syncronized: sync,
      id: id,
      nome: nome,
      ip: ip,
      tipoMonitoramento: tipoMonitoramento,
      ativo: ativo ?? true,
      tipoDispositivo: tipoDispositivo,
    );
  }

  factory MaquinaMonitorada.fromMachine(Machine value) {
    return MaquinaMonitorada(
      sync: value.syncronized,
      ativo: value.ativo,
      id: value.id,
      nome: value.nome,
      tipoDispositivo: value.tipoDispositivo,
      ip: value.ip,
      tipoMonitoramento: value.tipoMonitoramento,
      status: '--',
      cpuPercent: -1,
      ramPercent: -1,
      diskPercent: -1,
      lastCheck: DateTime.now().toString(),
      uptimePercent: -1,
      downtimeMinutes: -1,
      slaPercent: -1,
      packetLoss: -1,
      latency: -1,
    );
  }

  factory MaquinaMonitorada.fromJson(Map<String, dynamic> json) {
    return MaquinaMonitorada(
      id: json['id'],
      nome: json['nome'],
      ip: json['ip'],
      tipoMonitoramento: json['tipoMonitoramento'] == 'PING'
          ? TipoMonitoramento.ping
          : TipoMonitoramento.snmp,
      tipoDispositivo: json['tipoDispositivo'],
      status: json['status'],
      cpuPercent: (json['cpuPercent'] ?? 0).toDouble(),
      ramPercent: (json['ramPercent'] ?? 0).toDouble(),
      diskPercent: (json['diskPercent'] ?? 0).toDouble(),
      sync: json['syncronized'],
      lastCheck: json['lastCheck'],
      uptimePercent: json['uptimePercent'],
      downtimeMinutes: json['downtimeMinutes'],
      slaPercent: json['slaPercent'],
      packetLoss: json['packetLoss'],
      latency: json['latency'],
    );
  }
}

class ApiService {
  final String baseUrl = "http://localhost:5000"; // ou IP da máquina na rede

  Future<List<MaquinaMonitorada>> fetchMetrics() async {
    final response = await http.get(Uri.parse("$baseUrl/metrics"));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList.map((e) => MaquinaMonitorada.fromJson(e)).toList();
    } else {
      throw Exception("Erro ao carregar métricas: ${response.statusCode}");
    }
  }

  Future<bool> fetchStatus() async {
    final response = await http.get(Uri.parse("$baseUrl/sendStatus"));

    if (response.statusCode == 200) {
      dynamic res = jsonDecode(response.body);
      return res;
    } else {
      throw Exception("Erro ao carregar métricas: ${response.statusCode}");
    }
  }
}
