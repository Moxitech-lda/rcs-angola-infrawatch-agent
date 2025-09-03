import 'dart:io';

class InfraWatchFileSystem {
  static const basePath = r"C:\AgentInfraWatch";
  static const logsPath = r"C:\AgentInfraWatch\Logs";
  static const agentVersion = "1.0.0"; // ajusta se mudares a versão

  /// Garante que as pastas existem e cria o README.txt se não existir
  static Future<void> ensureStructure() async {
    try {
      // Criar diretórios base e logs
      final baseDir = Directory(basePath);
      if (!await baseDir.exists()) {
        await baseDir.create(recursive: true);
      }

      final logsDir = Directory(logsPath);
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      // Criar README.txt dinâmico
      final readmeFile = File("$basePath/README.txt");
      if (!await readmeFile.exists()) {
        final now = DateTime.now();
        final machineName = Platform.localHostname;

        final content =
            '''
Agent InfraWatch - Diretório de Dados
Criado em: ${now.toIso8601String()}
Máquina: $machineName
Versão do Agente: $agentVersion

Descrição:
Esta pasta é usada pelo agente de monitoramento InfraWatch para armazenar:
- Logs de execução (subpasta Logs)
- Banco de dados local (SQLite) usado pelo sistema

⚠️ Não modifique nem apague arquivos manualmente, pois isso pode comprometer o funcionamento do sistema.
''';

        await readmeFile.writeAsString(content);
      }
    } catch (e) {}
  }
}
