import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launches the given URL.
void onOpenLaunchUrl(LinkableElement link) async {
  final uri = Uri.parse(link.url);
  await launchUrl(uri);
}
