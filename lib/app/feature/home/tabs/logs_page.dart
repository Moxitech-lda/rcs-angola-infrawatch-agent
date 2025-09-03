import 'package:flutter/material.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  int r = 0;
  List<String> logs = [
    '[2025-08-27 18:47:51] Maquina 1 192.168.19.1 | CPU: 5,00% RAM: 90,19% DISCO: 0,00%',
    '[2025-08-27 18:47:58] Maquina 1 192.168.19.1 | CPU: 16,00% RAM: 91,67% DISCO: 0,00%',
    '[2025-08-27 18:48:04] Maquina 1 192.168.19.1 | CPU: 4,00% RAM: 90,70% DISCO: 0,00%',
    '[2025-08-27 18:48:10] Maquina 1 192.168.19.1 | CPU: 4,00% RAM: 90,93% DISCO: 0,00%',
    '[2025-08-27 18:48:17] Maquina 1 192.168.19.1 | CPU: 4,00% RAM: 90,03% DISCO: 0,00%',
    '[2025-08-27 18:48:23] Maquina 1 192.168.19.1 | CPU: 2,00% RAM: 90,54% DISCO: 0,00%',
    '[2025-08-27 18:48:30] Maquina 1 192.168.19.1 | CPU: 6,00% RAM: 90,14% DISCO: 0,00%',
    '[2025-08-27 18:48:36] Maquina 1 192.168.19.1 | CPU: 1,00% RAM: 90,19% DISCO: 7,00%',
    '[2025-08-27 18:48:42] Maquina 1 192.168.19.1 | CPU: 2,00% RAM: 90,19% DISCO: 0,00%',
    '[2025-08-27 18:48:49] Maquina 1 192.168.19.1 | CPU: 2,00% RAM: 90,21% DISCO: 0,00%',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Logs'),
        actions: [
          IconButton(
            tooltip: 'Limpar logs',
            icon: Icon(Icons.delete_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 250,
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: logs
                  .asMap()
                  .entries
                  .map((e) => Text('${++r} - ${e.value}'))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
