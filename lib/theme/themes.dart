import 'package:epc_qr/theme/color_schemes.g.dart';
import 'package:flutter/material.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
).copyWith(
  toggleableActiveColor: lightColorScheme.tertiary,
);
final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorScheme,
).copyWith(
  toggleableActiveColor: darkColorScheme.tertiary,
);
