import 'dart:ui';

import 'package:epc_qr/screens/form.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FormBuilderLocalizations.load(PlatformDispatcher.instance.locale);
  GetIt.I.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const EpcQrFormPage(),
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(),
    );
  }
}
