import 'dart:async';
import 'dart:io';

import 'package:agent_infra_watch/app/app.dart';
import 'package:agent_infra_watch/app/feature/home/tabs/dashboard/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:agent_infra_watch/app/api_server.dart';
import 'package:agent_infra_watch/app/feature/home/home_page.dart';
import 'package:agent_infra_watch/app/feature/home/tabs/agent_controller.dart';
import 'package:agent_infra_watch/app/feature/home/tabs/machine_form.dart';
import 'package:agent_infra_watch/app/feature/usefull.dart';
import 'package:agent_infra_watch/app/machine_dao.dart';
import 'package:agent_infra_watch/main.dart';
import 'package:agent_infra_watch/system.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final controller = DashboardController();

  Widget _getIcon(String value) {
    final icons = {
      'cbe721b2-2ae1-4213-b175-7237abf05143': SvgRender(
        Resource().getSvgIcon('icons8_smartphone_tablet'),
      ),
      '9592b85d-e855-44cb-936c-46310e2e4ce7': SvgRender(
        Resource().getSvgIcon('icons8_computer'),
      ),
      '875d1196-1055-4fd0-861c-0dfaf85182f5': SvgRender(
        Resource().getSvgIcon('icons8_switch'),
      ),
      'e667a298-50ed-414c-b7bc-7e38c7363630': SvgRender(
        Resource().getSvgIcon('icons8_pointer'),
      ),
      'f59c56e3-dd7d-4adb-a237-a5096d16a61d': SvgRender(
        Resource().getSvgIcon('icons8_wi-fi_router'),
      ),
      '53dde644-6e3e-4b29-9662-bf86cd825617': SvgRender(
        Resource().getSvgIcon('icons8_print'),
      ),
      '7dca9692-479f-49ad-af8d-d4dbd43ed0c9': SvgRender(
        Resource().getSvgIcon('icons8_server'),
      ),
      'da87b9ce-43bf-4283-9431-3b9a58d31c41': Icon(Icons.apps),
    };
    return icons[value]!;
  }

  Widget _insidView(
    String label,
    String value, [
    String? symbl,
    bool max = true,
  ]) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: .1, color: Colors.white.withAlpha(50)),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: max ? 20 : 13),
                  ),
                ),
                if (symbl != null)
                  Text(
                    symbl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPingSNMP(MaquinaMonitorada value) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          width: .1,
          color: Theme.of(context).primaryColor.withAlpha(200),
        ),
        color: Colors.white.withAlpha(20),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Row(
                spacing: 10,
                children: [
                  _getIcon(value.tipoDispositivo),
                  Expanded(
                    child: Text(
                      value.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  PopupMenuButton<int>(
                    tooltip: 'Mais opções',
                    icon: Icon(Icons.more_vert_outlined),
                    onSelected: (op) {
                      if (op == 0) {
                        showMachineFormModal(
                          context,
                          machine: value.toMachine(),
                        );
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
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<int>>[
                          const PopupMenuItem<int>(
                            value: 0,
                            child: Text('Editar'),
                          ),
                          const PopupMenuItem<int>(
                            value: 1,
                            child: Text('Eliminar'),
                          ),
                        ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Text(
                          'Target',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Expanded(
                          child: Text(
                            value.ip,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        BlinkingCircle(
                          active: IsRuning,
                          syncr: value.sync,
                          size: 8,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    Row(
                      spacing: 5,
                      children: [
                        Text(
                          value.tipoMonitoramento == TipoMonitoramento.ping
                              ? 'PING'
                              : 'SNMP',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Expanded(
                          child: Text(
                            value.status.toUpperCase(),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: !IsRuning
                                  ? null
                                  : value.status == 'up'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),

                    Row(
                      spacing: 6,
                      children: [
                        _insidView(
                          'CPU',
                          '${value.cpuPercent.toInt() < 0 ? '--' : value.cpuPercent.toInt()}',
                          '%',
                        ),
                        _insidView(
                          'RAM',
                          value.ramPercent.toInt() < 0
                              ? '--'
                              : value.ramPercent.toStringAsFixed(1),
                          '%',
                        ),
                        // _insidView(
                        //   'DISK',
                        //   '${value.diskPercent.toInt() < 0 ? '--' : value.diskPercent.toInt()}',
                        //   '%',
                        // ),
                      ],
                    ),

                    Row(
                      spacing: 6,
                      children: [
                        _insidView(
                          'Up Time',
                          '${value.uptimePercent.toInt() < 0 ? '--' : value.uptimePercent.toInt()}',
                          '%',
                        ),
                        _insidView(
                          'Down Time',
                          '${value.downtimeMinutes.toInt() < 0 ? '--' : value.downtimeMinutes.toInt()}',
                          'min',
                        ),
                      ],
                    ),
                    Row(
                      spacing: 6,
                      children: [
                        _insidView(
                          'Última checagem',
                          formatarDataRelativa(DateTime.parse(value.lastCheck)),
                          'segundos',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPingPing(MaquinaMonitorada value) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          width: .1,
          color: Theme.of(context).primaryColor.withAlpha(200),
        ),
        color: Colors.white.withAlpha(20),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Row(
                spacing: 10,
                children: [
                  _getIcon(value.tipoDispositivo),
                  Expanded(
                    child: Text(
                      value.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  PopupMenuButton<int>(
                    tooltip: 'Mais opções',
                    icon: Icon(Icons.more_vert_outlined),
                    onSelected: (op) {
                      if (op == 0) {
                        showMachineFormModal(
                          context,
                          machine: value.toMachine(),
                        );
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
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<int>>[
                          const PopupMenuItem<int>(
                            value: 0,
                            child: Text('Editar'),
                          ),
                          const PopupMenuItem<int>(
                            value: 1,
                            child: Text('Eliminar'),
                          ),
                        ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Text(
                          'Target',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Expanded(
                          child: Text(
                            value.ip,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        BlinkingCircle(
                          active: IsRuning,
                          syncr: value.sync,
                          size: 8,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      spacing: 5,
                      children: [
                        Text(
                          value.tipoMonitoramento == TipoMonitoramento.ping
                              ? 'PING'
                              : 'SNMP',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Expanded(
                          child: Text(
                            value.status.toUpperCase(),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: !IsRuning
                                  ? null
                                  : value.status == 'up'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),

                    Row(
                      spacing: 6,
                      children: [
                        _insidView(
                          'Latência',
                          '${value.latency.toInt() < 0 ? '--' : value.latency.toInt()}',
                          'ms',
                        ),
                        _insidView(
                          'P. Perdidos',
                          '${value.packetLoss.toInt() < 0 ? '--' : value.packetLoss.toInt()}',
                        ),
                      ],
                    ),

                    Row(
                      spacing: 6,
                      children: [
                        _insidView(
                          'Up Time',
                          '${value.uptimePercent.toInt() < 0 ? '--' : value.uptimePercent.toInt()}',
                          '%',
                        ),
                        _insidView(
                          'Down Time',
                          '${value.downtimeMinutes.toInt() < 0 ? '--' : value.downtimeMinutes.toInt()}',
                          'min',
                        ),
                      ],
                    ),
                    Row(
                      spacing: 6,
                      children: [
                        _insidView(
                          'Última checagem',
                          formatarDataRelativa(DateTime.parse(value.lastCheck)),
                          'segundos',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatarDataRelativa(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inSeconds < 60) {
      return '${diferenca.inSeconds}';
    } else if (diferenca.inMinutes < 60) {
      return 'há ${diferenca.inMinutes} minitos';
    } else if (diferenca.inHours < 24 && data.day == agora.day) {
      return 'há ${diferenca.inHours} h';
    } else if (diferenca.inDays == 1) {
      return 'ontem';
    } else if (diferenca.inDays == 2) {
      return 'antemontem';
    } else if (diferenca.inDays < 7) {
      return 'há ${diferenca.inDays} dias';
    } else if (diferenca.inDays < 30) {
      final semanas = (diferenca.inDays / 7).floor();
      return 'há $semanas semana${semanas > 1 ? 's' : ''}';
    } else if (diferenca.inDays < 365) {
      final meses = (diferenca.inDays / 30).floor();
      return 'há $meses mês${meses > 1 ? 'es' : ''}';
    } else {
      final anos = (diferenca.inDays / 365).floor();
      return 'há $anos ano${anos > 1 ? 's' : ''}';
    }
  }

  @override
  void initState() {
    super.initState();
    loadMetrics(true);

    controller.timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) => loadMetrics(false),
    );
  }

  @override
  void dispose() {
    controller.timer.cancel();
    super.dispose();
  }

  void loadMetrics(bool firstLoad) async {
    controller.firstLoad = firstLoad;
    try {
      final data = await controller.api.fetchMetrics();
      communicationServer = await controller.api.fetchStatus();

      IsRuning = true;
      controller.bancoVazio = false;
      if (mounted) {
        setState(() {
          controller.maquinas = data;
        });
      }
    } catch (e) {
      IsRuning = false;
      final data = await controller.dao.getAll();
      controller.bancoVazio = data.isEmpty;
      if (mounted) {
        setState(() {
          controller.maquinas = data
              .map((e) => MaquinaMonitorada.fromMachine(e))
              .toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return controller.firstLoad
        ? Container(
            color: Theme.of(context).colorScheme.scrim.withAlpha(200),

            child: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.scrim.withAlpha(200),

            appBar: AppBar(
              forceMaterialTransparency: true,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              title: Text('Hosts'),
              actions: [
                if (syncManager.isSyncRunning)
                  Blinking(
                    child: Row(
                      spacing: 10,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('sincronizando', style: TextStyle(fontSize: 12)),
                        Icon(Icons.sync),
                      ],
                    ),
                  ),
                IconButton(
                  tooltip: 'Comunicação com servidor',
                  onPressed: () {},
                  icon: BlinkingCircle1(
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
                if (!controller.bancoVazio)
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

            body: controller.bancoVazio
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
                : SizedBox(
                    width: MediaQuery.of(context).size.width - 250,
                    child: GridView.builder(
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300, // largura máxima de cada item
                        crossAxisSpacing: 10, // espaço horizontal
                        mainAxisSpacing: 10, // espaço vertical
                        childAspectRatio: .85, // proporção largura/altura
                      ),
                      itemCount: controller.maquinas.length,
                      itemBuilder: (context, index) {
                        return controller.maquinas[index].tipoMonitoramento ==
                                TipoMonitoramento.ping
                            ? _buildPingPing(controller.maquinas[index])
                            : _buildPingSNMP(controller.maquinas[index]);
                      },
                    ),
                  ),
          );
  }
}

//------------------------------------------------------------------------------

class BlinkingCircle extends StatefulWidget {
  const BlinkingCircle({
    super.key,
    required this.active,
    this.size,
    required this.syncr,
  });
  final bool active;
  final bool syncr;
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
      child: widget.active
          ? AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Opacity(opacity: _animation.value, child: child);
              },
              child: Container(
                width: widget.size ?? 8,
                height: widget.size ?? 8,
                decoration: BoxDecoration(
                  color: widget.syncr ? Colors.green : Colors.yellow,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : Container(
              width: widget.size ?? 8,
              height: widget.size ?? 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
    );
  }
}

//------------------------------------------------------------------------------
class Blinking extends StatefulWidget {
  const Blinking({super.key, required this.child});
  final Widget child;
  @override
  State<Blinking> createState() => _BlinkingState();
}

class _BlinkingState extends State<Blinking>
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
      begin: 0.1,
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
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(opacity: _animation.value, child: child);
        },
        child: widget.child,
      ),
    );
  }
}
//------------------------------------------------------------------------------

class BlinkingCircle1 extends StatefulWidget {
  const BlinkingCircle1({
    super.key,
    required this.active,
    this.size,
    this.cintila = true,
  });
  final bool active;
  final bool cintila;
  final double? size;
  @override
  State<BlinkingCircle1> createState() => _Blinking1CircleState();
}

class _Blinking1CircleState extends State<BlinkingCircle1>
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
