import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// see https://pub.dev/packages/share_plus#platform-support
bool get shareFeatureAvailable => !(Platform.isWindows || Platform.isLinux);

Future<void> shareFile(String name, List<int> data, {String? mimeType}) async {
  final dir = await getTemporaryDirectory();
  final file = File(p.join(dir.path, name));
  await file.writeAsBytes(data);

  List<String>? mimeTypes;
  if (mimeType != null) mimeTypes = [mimeType];
  await Share.shareFiles([file.path], mimeTypes: mimeTypes);
}
