import 'package:flutter/material.dart';
import 'package:agent_infra_watch/app/feature/config/config_controller.dart';
import 'package:agent_infra_watch/app/inputs_widgets.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  ConfigController controller = ConfigController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.scrim,
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Image.asset('assets/image/infralogo.png'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Configurar Agente',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Por favor insira o token para autenticar no servidor',
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: CustomTextBox(
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Campo obrigatório';
                            }
                            return null;
                          },
                          controller: controller.controllerText,
                          constraints: constraints,
                          hintText: 'Token de autenticação',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: SizedBox(
                        width: double.infinity,
                        child: BT(
                          constraints: constraints,
                          label: 'Continuar',
                          onPressed: () async {
                            await controller.salvar(_formKey, context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BT extends StatefulWidget {
  const BT({
    super.key,
    required this.constraints,
    required this.label,
    this.icon,
    required this.onPressed,
    this.borderRadius,
    this.color,
    this.labelColor,
  });

  final BorderRadiusGeometry? borderRadius;
  final BoxConstraints constraints;
  final String label;
  final Icon? icon;
  final Color? color;
  final Color? labelColor;
  final Future<void> Function() onPressed;

  @override
  State<BT> createState() => _BTState();
}

class _BTState extends State<BT> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget labelWidget = Text(widget.label);

    final Widget progressIcon = const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
    );

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isLoading) ...[
          progressIcon,
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: 8),
        ],
        labelWidget,
      ],
    );

    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePress,

        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(5),
            side: BorderSide(color: Theme.of(context).primaryColor),
          ),
          elevation: 0,

          backgroundColor: Colors.transparent,
        ),
        child: content,
      ),
    );
  }
}
