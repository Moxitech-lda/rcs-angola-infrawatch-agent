import 'package:agent_infra_watch/main.dart';
import 'package:flutter/material.dart';
import 'package:agent_infra_watch/app/api_server.dart';
import 'package:agent_infra_watch/app/feature/config/config_page.dart';
import 'package:agent_infra_watch/app/inputs_widgets.dart';
import 'package:agent_infra_watch/app/machine_dao.dart';
import 'package:uuid/uuid.dart';

Future<bool?> showMachineFormModal(BuildContext context, {Machine? machine}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(width: 350, child: MachineForm(machine: machine)),
    ),
  );
}

class MachineForm extends StatefulWidget {
  final Machine? machine;

  const MachineForm({super.key, this.machine});

  @override
  State<MachineForm> createState() => _MachineFormState();
}

class _MachineFormState extends State<MachineForm> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _ipController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();

  int _tipoMonitoramento = 0;
  late String _tipoDispositivo = tiposDispositivo[0].id;
  bool _ativo = true;

  final tiposMonitoramento = [
    0, // "PING",
    1, //  "SNMP"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.machine != null) {
      _nomeController.text = widget.machine!.nome;
      _ipController.text = widget.machine!.ip;
      _usuarioController.text = widget.machine!.usuario ?? "";
      _senhaController.text = widget.machine!.senha ?? "";
      _tipoMonitoramento = widget.machine!.tipoMonitoramento.index;
      _tipoDispositivo = tiposDispositivo
          .where((e) => e.id == widget.machine!.tipoDispositivo)
          .first
          .id;
      _ativo = widget.machine!.ativo;
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final dao = MachineDAO();

    if (widget.machine == null) {
      final maquina = Machine(
        syncronized: false,
        id: Uuid().v4(),
        nome: _nomeController.text,
        ip: _ipController.text,
        usuario: _usuarioController.text.isEmpty
            ? null
            : _usuarioController.text,
        senha: _senhaController.text.isEmpty ? null : _senhaController.text,
        tipoMonitoramento: TipoMonitoramento.values[_tipoMonitoramento],
        ativo: true,
        tipoDispositivo: _tipoDispositivo,
      );
      await dao.insert(maquina, context);
    } else {
      final maquina = Machine(
        id: widget.machine!.id,
        syncronized: widget.machine!.syncronized,
        nome: _nomeController.text,
        ip: _ipController.text,
        usuario: _usuarioController.text.isEmpty
            ? null
            : _usuarioController.text,
        senha: _senhaController.text.isEmpty ? null : _senhaController.text,
        tipoMonitoramento: TipoMonitoramento.values[_tipoMonitoramento],
        ativo: true,
        tipoDispositivo: _tipoDispositivo,
      );
      await dao.update(maquina, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.machine == null
                        ? "Adicionar Máquina"
                        : "Editar Máquina",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  CustomTextBox(
                    hintText: "Nome",
                    constraints: constraints,
                    controller: _nomeController,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Informe o nome" : null,
                  ),
                  CustomTextBox(
                    constraints: constraints,
                    controller: _ipController,
                    hintText: "Endereço IP",
                    validator: (v) {
                      final ipv4Regex = RegExp(
                        r'^((25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)$',
                      );
                      if (v == null || v.isEmpty) return "Informe o IP";

                      if (!ipv4Regex.hasMatch(v)) return "IP Inválido";
                      return null;
                    },
                  ),
                  CustomComboBox<int>(
                    value: _tipoMonitoramento,
                    hintText: "Tipo de Monitoramento",
                    constraints: constraints,
                    items: tiposMonitoramento
                        .map(
                          (t) => CustomComboBoxItemModel(
                            value: t,
                            label: t == 0 ? 'PING' : 'SNMP',
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _tipoMonitoramento = v!),
                  ),

                  CustomComboBox<String>(
                    value: _tipoDispositivo,
                    hintText: "Tipo de Dispositivo",
                    constraints: constraints,
                    items: tiposDispositivo
                        .map(
                          (t) => CustomComboBoxItemModel(
                            value: t.id,
                            label: t.value,
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _tipoDispositivo = v!),
                  ),
                  // SwitchListTile(
                  //   title: const Text("Ativo"),
                  //   value: _ativo,
                  //   onChanged: (v) => setState(() => _ativo = v),
                  // ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancelar"),
                      ),
                      const SizedBox(width: 8),
                      BT(
                        constraints: constraints,
                        onPressed: _salvar,
                        label: "Salvar",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
