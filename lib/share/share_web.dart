import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

bool get shareFeatureAvailable => true;

Future<void> shareFile(String name, List<int> data, {String? mimeType}) async {
  final content = base64Encode(data);
  final anchor = AnchorElement(
      href: 'data:application/octet-stream;charset=utf-16le;base64,$content')
    ..setAttribute('download', name)
    ..click();
}
