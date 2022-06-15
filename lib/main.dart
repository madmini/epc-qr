import 'dart:ui';

import 'package:epc_qr/form.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  await FormBuilderLocalizations.load(PlatformDispatcher.instance.locale);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: EpcQrFormPage(),
    );
  }
}
