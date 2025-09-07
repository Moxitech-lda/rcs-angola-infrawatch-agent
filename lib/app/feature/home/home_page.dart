import 'package:flutter/material.dart';
import 'package:agent_infra_watch/app/feature/home/tabs/config/conifig_page.dart';
import 'package:agent_infra_watch/app/feature/home/tabs/dashboard/dashboard_page.dart';

// ignore: non_constant_identifier_names
ValueNotifier<bool> IsLoading = ValueNotifier(false);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  Widget _buildItemMenu(String title, IconData icon, int index) {
    return ListTile(
      selectedColor: theme.primaryColor,
      selectedTileColor: theme.primaryColor,
      title: Text(title),
      leading: Icon(icon),
      selected: index == this.index,
      onTap: () {
        setState(() {
          this.index = index;
        });
      },
    );
  }

  Widget _getTab() {
    return [DashboardPage(), ConifigPage()][index];
  }

  late final theme = Theme.of(context);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).hintColor.withAlpha(10),
                    ),
                  ),
                  color: theme.colorScheme.scrim,
                ),
                height: double.infinity,
                width: 250,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/image/infralogo.png',
                      width: 250,
                      fit: BoxFit.fill,
                    ),
                    _buildItemMenu('Dashboard', Icons.dashboard, 0),
                    _buildItemMenu('Configurar', Icons.settings, 1),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: IsLoading,
                  builder: (context, _) {
                    return SizedBox(height: double.infinity, child: _getTab());
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
