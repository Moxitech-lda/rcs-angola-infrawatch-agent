import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:agent_infra_watch/app/feature/home/home_page.dart';

class AgentController {
  static Future<void> showAgentResultDialog(
    BuildContext context,
    String message,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Erro"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Fechar"),
            ),
          ],
        );
      },
    );
  }

  static Future<void> startAgent(BuildContext context) async {
    IsLoading.value = true;
    try {
      final exePath =
          // r'D:/projects/rcs_angola/iwa_server/bin/Debug/net9.0/iwa_server.exe';
          path.join(Directory.current.path, 'iwa_server.exe');

      // if (!File(exePath).existsSync()) {
      //   throw "Arquivo iwa-server.exe não encontrado em ${Directory.current.path}";
      // }

      await Process.start('start', ['', exePath], runInShell: true);
    } catch (e) {
      if (context.mounted) {
        await showAgentResultDialog(context, "Erro ao iniciar agente: $e");
      }
    } finally {
      await Future.delayed(const Duration(seconds: 1));
      IsLoading.value = false;
    }
  }

  static Future<void> stopAgent(BuildContext context) async {
    IsLoading.value = true;
    try {
      await Process.run("taskkill", [
        "/IM",
        "iwa_server.exe",
        "/F",
      ], runInShell: true);
    } catch (e) {
      if (context.mounted) {
        await showAgentResultDialog(context, "Erro ao parar agente: $e");
      }
    } finally {
      IsLoading.value = false;
    }
  }
}
