import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:agent_infra_watch/app/config_dao.dart';
import 'package:agent_infra_watch/app/feature/geo_location_service.dart';
import 'package:agent_infra_watch/app/feature/home/home_page.dart';
import 'package:agent_infra_watch/app/feature/home/tabs/agent_controller.dart';
import 'package:uuid/uuid.dart';

class ConfigController {
  TextEditingController controllerText = TextEditingController();

  Future<void> salvar(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) async {
    if (!formKey.currentState!.validate()) return;

    final res = await conigureAgent(context);

    if (res == null) {
      return;
    }

    await ConfigDAO().setConfig('token', controllerText.text.trim());
    await ConfigDAO().setConfig('code_agent', res);

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HomePage(),
      ),
    );
  }

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
          if (data['error'] == null) {
            AgentController.showAgentResultDialog(context, 'Token inválido.');
          } else {
            AgentController.showAgentResultDialog(context, '${data['error']}');
          }
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

  Future<String?> conigureAgent(BuildContext context) async {
    try {
      final geo = await GeoLocationService().getLocation();
      var uuid = 'Agent-${Uuid().v4().substring(0, 8)}';

      final body = {
        'token': controllerText.text.trim(),
        'code_agent': uuid,
        ...geo.toJson(),
        'dateTime': DateTime.now().toString(),
      };

      if (!context.mounted) return null;

      final res = await sendPostRequest(context, body);
      if (!res) return null;

      return uuid;
    } catch (e) {
      if (context.mounted) {
        AgentController.showAgentResultDialog(
          context,
          'Falha ao tentar comunicar com a internet.',
        );
      }
      return null;
    }
  }
}
//INFRA202003
//INFRA202001