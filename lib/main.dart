import 'package:agent_infra_watch/app/machine_dao.dart';
import 'package:flutter/material.dart';
import 'package:agent_infra_watch/app/app.dart';
import 'package:agent_infra_watch/app/config_dao.dart';
import 'package:agent_infra_watch/system.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_svg/svg.dart';

class Resource {
  String getImage(String name, {String extention = '.png'}) {
    return 'assets/image/$name$extention';
  }

  String getSvgIcon(String name) {
    return 'assets/svg/icon/$name.svg';
  }

  String getSvgImage(String name) {
    return 'assets/svg/image/$name.svg';
  }

  String getLottie(String name) {
    return 'assets/lottie/$name.json';
  }
}

class SvgRender extends StatelessWidget {
  const SvgRender(
    this.assetSource, {
    super.key,
    this.size,
    this.color,
    this.empyColor = false,
    this.fromAsset = true,
  });

  final String assetSource;
  final double? size;
  final Color? color;
  final bool empyColor;
  final bool fromAsset;
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetSource,
      width: size ?? 25,
      colorFilter: empyColor
          ? null
          : ColorFilter.mode(
              color ?? Theme.of(context).hintColor,
              BlendMode.srcIn,
            ),
    );
  }
}

List<Types> tiposDispositivo = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InfraWatchFileSystem.ensureStructure();
  databaseFactory = databaseFactoryFfi;
  sqfliteFfiInit();
 final tokem = await ConfigDAO().getConfig('token');
 tiposDispositivo = await TypesDAO().getAll();

  runApp(MyApp(tokem: tokem));
}
