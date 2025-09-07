import 'package:flutter/material.dart';
import 'package:agent_infra_watch/app/config_dao.dart';

class ConfigTabController {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();
  void intit() async {
    controller1.text = (await ConfigDAO().getConfig('token')) ?? '';
    controller2.text = (await ConfigDAO().getConfig('code_agent')) ?? '';
    controller3.text = (await ConfigDAO().getConfig('id_company')) ?? '';
    controller4.text = (await ConfigDAO().getConfig('frequence')) ?? '5';
  }

  Future<void> salvar(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    if (!formKey.currentState!.validate()) return;

    await ConfigDAO().setConfig('frequence', controller4.text.trim());
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 800),
          content: Text('Sucesso'),
        ),
      );
    }
  }
}
