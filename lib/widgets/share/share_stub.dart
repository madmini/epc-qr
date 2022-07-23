bool get shareFeatureAvailable {
  return false;
}

Future<void> shareFile(String name, List<int> data, {String? mimeType}) {
  throw UnimplementedError('Sharing files is not supported on this platform.');
}
