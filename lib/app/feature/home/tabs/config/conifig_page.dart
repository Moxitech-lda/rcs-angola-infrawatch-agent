import 'package:flutter/material.dart';
import 'package:agent_infra_watch/app/feature/config/config_page.dart';
import 'package:agent_infra_watch/app/feature/home/tabs/config/config_tab_controller.dart';
import 'package:agent_infra_watch/app/inputs_widgets.dart';

class ConifigPage extends StatefulWidget {
  const ConifigPage({super.key});

  @override
  State<ConifigPage> createState() => _ConifigPageState();
}

class _ConifigPageState extends State<ConifigPage> {
  final controller = ConfigTabController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller.intit();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.scrim.withAlpha(200),

          appBar: AppBar(
            forceMaterialTransparency: true,

            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 250,
              child: Form(
                key: _formKey,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          width: .1,
                          color: Theme.of(context).primaryColor.withAlpha(200),
                        ),
                        color: Colors.white.withAlpha(20),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 20,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              child: Text(
                                'Configurar',
                                style: TextStyle(fontSize: 40),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              child: Text('Token'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              child: SizedBox(
                                child: CustomTextBox(
                                  readOnly: true,
                                  keyboardType: TextInputType.number,
                                  controller: controller.controller1,
                                  constraints: constraints,
                                  hintText: 'Token',
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              child: Text('Código do agente'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              child: SizedBox(
                                child: CustomTextBox(
                                  readOnly: true,
                                  keyboardType: TextInputType.number,
                                  controller: controller.controller2,
                                  constraints: constraints,
                                  hintText: 'Código do agente',
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              child: Text('ID da companinha'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              child: SizedBox(
                                child: CustomTextBox(
                                  readOnly: true,
                                  keyboardType: TextInputType.number,
                                  controller: controller.controller3,
                                  constraints: constraints,
                                  hintText: 'Código do agente',
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              child: Text(
                                'Por favor insira tempo para checagem periódica dos hosts em segundos. Insirá apenas caracteres numéricos',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              child: SizedBox(
                                width: 80,

                                child: CustomTextBox(
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Campo obrigatório';
                                    }
                                    final ipv4Regex = RegExp(r'^\d+$');
                                    if (!ipv4Regex.hasMatch(v)) {
                                      return "Inválido.";
                                    }

                                    if (int.parse(v) < 5) {
                                      return "Inválido.";
                                    }

                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  controller: controller.controller4,
                                  constraints: constraints,
                                  hintText: 'Tempo',
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 10,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: BT(
                                  constraints: constraints,
                                  label: 'Salvar',
                                  onPressed: () async {
                                    await controller.salvar(context, _formKey);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
