import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agent_infra_watch/app/machine_dao.dart';

enum TipoMonitoramento { ping, wmi }

class MaquinaMonitorada {
  final String id;
  final bool? ativo;
  final String nome;
  final String ip;
  final TipoMonitoramento tipoMonitoramento;
  final String status;
  final double cpuPercent;
  final double ramPercent;
  final double diskPercent;
  final double perda;
  final int pingMs;
  String tipoDispositivo;

  MaquinaMonitorada({
    this.ativo,
    required this.id,
    required this.nome,
    required this.tipoDispositivo,
    required this.ip,
    required this.tipoMonitoramento,
    required this.status,
    required this.perda,
    required this.cpuPercent,
    required this.ramPercent,
    required this.diskPercent,
    required this.pingMs,
  });

  Machine toMachine() {
    return Machine(
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
      ativo: value.ativo,
      id: value.id,
      nome: value.nome,
      tipoDispositivo: value.tipoDispositivo,
      ip: value.ip,
      tipoMonitoramento: value.tipoMonitoramento,
      status: '--',
      perda: -1,
      cpuPercent: -1,
      ramPercent: -1,
      diskPercent: -1,
      pingMs: -1,
    );
  }

  factory MaquinaMonitorada.fromJson(Map<String, dynamic> json) {
    return MaquinaMonitorada(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      ip: json['ip'] ?? '',
      tipoMonitoramento: json['tipoMonitoramento'] == 'PING'
          ? TipoMonitoramento.ping
          : TipoMonitoramento.wmi,
      tipoDispositivo: json['tipoDispositivo'] ?? '',
      status: json['status'] ?? 'Desconhecido',
      perda: (json['perda'] ?? 0).toDouble(),
      cpuPercent: (json['cpuPercent'] ?? 0).toDouble(),
      ramPercent: (json['ramPercent'] ?? 0).toDouble(),
      diskPercent: (json['diskPercent'] ?? 0).toDouble(),
      pingMs: json['pingMs'] ?? 0,
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
