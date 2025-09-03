import 'package:flutter/material.dart';
import 'package:agent_infra_watch/app/feature/config/config_page.dart';
import 'package:agent_infra_watch/app/feature/home/home_page.dart';
//import 'package:agent_infra_watch/app/feature/home/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.tokem});
  final String? tokem;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InfraWatch',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 23, 150, 255),
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          surface: Colors.black,
          scrim: const Color.fromARGB(255, 15, 23, 43),
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 23, 150, 255),
        ),
      ),
      home: tokem == null ? const ConfigPage() : HomePage(),
    );
  }
}
