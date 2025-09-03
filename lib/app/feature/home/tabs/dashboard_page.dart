import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:agent_infra_watch/app/api_server.dart';
import 'package:agent_infra_watch/app/feature/home/home_page.dart';
import 'package:agent_infra_watch/app/feature/home/tabs/agent_controller.dart';
import 'package:agent_infra_watch/app/feature/home/tabs/machine_form.dart';
import 'package:agent_infra_watch/app/feature/usefull.dart';
import 'package:agent_infra_watch/app/machine_dao.dart';
import 'package:agent_infra_watch/main.dart';
import 'package:agent_infra_watch/system.dart';

// ignore: non_constant_identifier_names
bool IsRuning = false;
bool communicationServer = false;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

final tiposDispositivo = [
  "PC",
  "Switch",
  "AccessPoint",
  "Router",
  "Impressora",
  "Servidor",
  "Smartphone/Tablet",
];

class _DashboardPageState extends State<DashboardPage> {
  Widget _getIcon(String value) {
    final icons = [
      SvgRender(Resource().getSvgIcon('icons8_computer')),
      SvgRender(Resource().getSvgIcon('icons8_switch')),
      SvgRender(Resource().getSvgIcon('icons8_pointer')),
      SvgRender(Resource().getSvgIcon('icons8_wi-fi_router')),
      SvgRender(Resource().getSvgIcon('icons8_print')),
      SvgRender(Resource().getSvgIcon('icons8_server')),
      SvgRender(Resource().getSvgIcon('icons8_smartphone_tablet')),
    ];
    return icons[tiposDispositivo.indexOf(value)];
  }

  Widget _buildPingWmi(MaquinaMonitorada value, bool first, bool last) {
    return Row(
      spacing: 10,
      children: [
        value.ativo == null
            ? BlinkingCircle(active: IsRuning)
            : BlinkingCircle(active: value.ativo!, cintila: false),

        _getIcon(value.tipoDispositivo),
        Expanded(
          child: Text(value.nome, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Expanded(child: Text(value.ip, overflow: TextOverflow.ellipsis)),
        Expanded(
          child: Text(
            value.tipoMonitoramento == TipoMonitoramento.ping ? 'PING' : 'WMI',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Text(
            value.cpuPercent < 0 || value.status != 'Online'
                ? 'CPU: --'
                : 'CPU: ${value.cpuPercent.toStringAsFixed(1)}%',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Text(
            value.ramPercent < 0 || value.status != 'Online'
                ? 'RAM: --'
                : 'RAM: ${value.ramPercent.toStringAsFixed(1)}%',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Text(
            value.diskPercent < 0 || value.status != 'Online'
                ? 'DSK: --'
                : 'DSK: ${value.diskPercent.toStringAsFixed(1)}%',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        Text(
          value.status,
          textAlign: TextAlign.right,
          maxLines: 1,
          style: TextStyle(
            color: !IsRuning
                ? null
                : value.status == 'Online'
                ? Colors.green
                : Colors.red,
          ),
        ),
        PopupMenuButton<int>(
          tooltip: 'Mais opções',
          icon: Icon(Icons.more_vert_outlined),
          onSelected: (op) {
            if (op == 0) {
              showMachineFormModal(context, machine: value.toMachine());
            }
            if (op == 1) {
              showConfirmationDialog(
                context: context,
                message: 'Eliminar o host: ${value.nome}',
                onConfirm: () {
                  MachineDAO().delete(value.id);
                },
              );
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            const PopupMenuItem<int>(value: 0, child: Text('Editar')),
            const PopupMenuItem<int>(value: 1, child: Text('Eliminar')),
          ],
        ),
      ],
    );
  }

  Widget _buildPingPing(MaquinaMonitorada value, bool first, bool last) {
    return Row(
      spacing: 10,
      children: [
        value.ativo == null
            ? BlinkingCircle(active: IsRuning)
            : BlinkingCircle(active: value.ativo!, cintila: false),
        _getIcon(value.tipoDispositivo),
        Expanded(child: Text(value.nome, maxLines: 1)),
        Expanded(child: Text(value.ip, overflow: TextOverflow.ellipsis)),
        Expanded(
          child: Text(
            value.tipoMonitoramento == TipoMonitoramento.ping ? 'PING' : 'WMI',

            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Text(
            value.status != 'Online' ? 'LAT: --' : 'LAT: ${value.pingMs} ms',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Text(
            value.status != 'Online'
                ? 'PRD: --'
                : 'PRD: ${value.perda.toInt()}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(child: Text('', maxLines: 1, overflow: TextOverflow.ellipsis)),
        Text(
          value.status,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: !IsRuning
                ? null
                : value.status == 'Online'
                ? Colors.green
                : Colors.red,
          ),
        ),

        PopupMenuButton<int>(
          tooltip: 'Mais opções',
          icon: Icon(Icons.more_vert_outlined),
          onSelected: (op) {
            if (op == 0) {
              showMachineFormModal(context, machine: value.toMachine());
            }
            if (op == 1) {
              showConfirmationDialog(
                context: context,
                message: 'Eliminar o host: ${value.nome}',
                onConfirm: () {
                  MachineDAO().delete(value.id);
                },
              );
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            const PopupMenuItem<int>(value: 0, child: Text('Editar')),
            const PopupMenuItem<int>(value: 1, child: Text('Eliminar')),
          ],
        ),
      ],
    );
  }

  final api = ApiService();
  final dao = MachineDAO();
  bool bancoVazio = false;
  bool firstLoad = true;

  late Timer _timer;
  List<MaquinaMonitorada> maquinas = [];

  @override
  void initState() {
    super.initState();
    _loadMetrics(true);
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) => _loadMetrics(false),
    );
  }

  void _loadMetrics(bool firstLoad) async {
    this.firstLoad = firstLoad;
    try {
      final data = await api.fetchMetrics();
      communicationServer = await api.fetchStatus();
      IsRuning = true;
      bancoVazio = false;
      if (mounted) {
        setState(() {
          maquinas = data;
        });
      }
    } catch (e) {
      IsRuning = false;
      final data = await dao.getAll();
      bancoVazio = data.isEmpty;
      if (mounted) {
        setState(() {
          maquinas = data.map((e) => MaquinaMonitorada.fromMachine(e)).toList();
        });
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return firstLoad
        ? Container(
            color: Theme.of(context).colorScheme.scrim.withAlpha(200),

            child: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.scrim.withAlpha(200),

            appBar: AppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              title: Text('Hosts'),
              actions: [
                IconButton(
                  tooltip: 'Comunicação com servidor',
                  onPressed: () {},
                  icon: BlinkingCircle(
                    active: communicationServer && IsRuning,
                    size: 15,
                  ),
                ),

                AsyncIconButton(
                  tooltip: 'Abrir logs',
                  icon: Icon(Icons.article_outlined),
                  onPressed: () async {
                    await Process.run("explorer", [
                      InfraWatchFileSystem.logsPath,
                    ]);
                  },
                ),
                IconButton(
                  tooltip: 'Nova máquina',
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    final salvou = await showMachineFormModal(context);
                    if (salvou == true) {
                      setState(() {});
                    }
                  },
                ),
                if (!bancoVazio)
                  IsRuning
                      ? AsyncIconButton(
                          tooltip: 'Parar monitoramento',
                          icon: Icon(Icons.stop, color: Colors.red),
                          onPressed: () async {
                            await AgentController.stopAgent(context);
                            setState(() {
                              IsRuning = false;
                            });
                          },
                        )
                      : AsyncIconButton(
                          tooltip: 'Iniciar monitoramento',
                          icon: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            await AgentController.startAgent(context);
                            setState(() {
                              IsRuning = true;
                            });
                          },
                        ),
                SizedBox(width: 10),
              ],
            ),

            body: bancoVazio
                ? Center(
                    child: Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.clear, size: 100),
                        Text('Você ainda não cadastrou nenhum host'),
                      ],
                    ),
                  )
                : IsLoading.value
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 250,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              width: .1,
                              color: Theme.of(
                                context,
                              ).primaryColor.withAlpha(200),
                            ),
                            color: Colors.white.withAlpha(20),
                          ),
                          child: Column(
                            spacing: 10,
                            children: maquinas
                                .asMap()
                                .entries
                                .map(
                                  (e) =>
                                      e.value.tipoMonitoramento ==
                                          TipoMonitoramento.ping
                                      ? _buildPingPing(
                                          e.value,
                                          e.key == 0,
                                          e.key == maquinas.length,
                                        )
                                      : _buildPingWmi(
                                          e.value,
                                          e.key == 0,
                                          e.key == maquinas.length,
                                        ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
          );
  }
}

class BlinkingCircle extends StatefulWidget {
  const BlinkingCircle({
    super.key,
    required this.active,
    this.size,
    this.cintila = true,
  });
  final bool active;
  final bool cintila;
  final double? size;
  @override
  State<BlinkingCircle> createState() => _BlinkingCircleState();
}

class _BlinkingCircleState extends State<BlinkingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: !widget.cintila
          ? Container(
              width: widget.size ?? 8,
              height: widget.size ?? 8,
              decoration: BoxDecoration(
                color: widget.active ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            )
          : widget.active
          ? AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Opacity(opacity: _animation.value, child: child);
              },
              child: Container(
                width: widget.size ?? 8,
                height: widget.size ?? 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : Container(
              width: widget.size ?? 8,
              height: widget.size ?? 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
    );
  }
}
