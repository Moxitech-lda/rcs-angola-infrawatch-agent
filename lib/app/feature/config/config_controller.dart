import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:agent_infra_watch/app/config_dao.dart';
import 'package:agent_infra_watch/app/feature/geo_location_service.dart';
import 'package:agent_infra_watch/app/feature/home/home_page.dart';
import 'package:agent_infra_watch/app/feature/home/tabs/agent_controller.dart';
import 'package:uuid/uuid.dart';

class SendPostRequest {
  bool status;
  String? idCompany;
  String? uuid;

  SendPostRequest({required this.status, this.idCompany, this.uuid});
}

class ConfigController {
  TextEditingController controllerText = TextEditingController();

  Future<void> salvar(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) async {
    if (!formKey.currentState!.validate()) return;

    final res = await conigureAgent(context);

    if (!res.status) return;

    await ConfigDAO().setConfig('token', controllerText.text.trim());
    await ConfigDAO().setConfig('code_agent', res.uuid!);
    await ConfigDAO().setConfig('id_company', res.idCompany!);

    if (!context.mounted) return;

    final resp = await sendPostRequestFromTypes(
      context,
      controllerText.text.trim(),
    );

    for (var e in resp) {
      await TypesDAO().setType(e.id, e.value);
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HomePage(),
      ),
    );
  }

  Future<SendPostRequest> sendPostRequest(
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

        return SendPostRequest(
          status: data['result'] == 'OK',
          idCompany: data['system']['id_company'] ?? 'unknow',
        );
      } else {
        final data = jsonDecode(response.body);

        if (context.mounted) {
          AgentController.showAgentResultDialog(context, '${data['error']}');
        }
        return SendPostRequest(status: false);
      }
    } catch (e) {
      if (context.mounted) {
        AgentController.showAgentResultDialog(
          context,
          'Falha ao tentar comunicar com a internet.',
        );
      }
      return SendPostRequest(status: false);
    }
  }

  Future<List<Types>> sendPostRequestFromTypes(
    BuildContext context,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://infrawatch-backend.onrender.com/api/integrations/agents/$token/systems/types",
        ),
      );

      if (response.statusCode == 200) {
        final data = (jsonDecode(response.body)['data'] as List<dynamic>);
        return data.map((e) => Types(id: e['id'], value: e['name'])).toList();
      } else {
        final data = jsonDecode(response.body);
        if (context.mounted) {
          AgentController.showAgentResultDialog(context, '${data['error']}');
        }
        return [];
      }
    } catch (e) {
      if (context.mounted) {
        AgentController.showAgentResultDialog(
          context,
          'Falha ao tentar comunicar com a internet.',
        );
      }
      return [];
    }
  }

  Future<SendPostRequest> conigureAgent(BuildContext context) async {
    try {
      final geo = await GeoLocationService().getLocation();
      var uuid = 'Agent-${Uuid().v4().substring(0, 8)}';

      final body = {
        'token': controllerText.text.trim(),
        'code_agent': uuid,
        ...geo.toJson(),
        'dateTime': DateTime.now().toString(),
      };

      if (!context.mounted) return SendPostRequest(status: false);
      final res = await sendPostRequest(context, body);

      if (!res.status) {
        if (context.mounted) {
          AgentController.showAgentResultDialog(context, 'Token inválido.');
        }
      }

      if (!res.status) return res;
      res.uuid = uuid;
      return res;
    } catch (e) {
      if (context.mounted) {
        AgentController.showAgentResultDialog(
          context,
          'Falha ao tentar comunicar com a internet.',
        );
      }
      return SendPostRequest(status: false);
    }
  }
}

//INFRA202003
//INFRA202001
