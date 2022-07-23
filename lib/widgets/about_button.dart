import 'package:epc_qr/widgets/linkify_on_open.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

const kGitUrl = String.fromEnvironment('GIT_URL');
const kGitRef = String.fromEnvironment('GIT_REF');
const kCommitHash = String.fromEnvironment('COMMIT_HASH');
const kCiProvider = String.fromEnvironment('CI_PROVIDER');
const kVersionTag = String.fromEnvironment('VERSION_TAG');

class AboutButton extends StatelessWidget {
  const AboutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info),
      onPressed: () => showAboutDialog(
        context: context,
        applicationName: 'EPC-QR Generator',
        applicationVersion: kVersionTag != '' ? kVersionTag : null,
        children: kGitUrl != '' ? const [AboutSourceText()] : null,
      ),
    );
  }
}

class AboutSourceText extends StatelessWidget {
  const AboutSourceText({Key? key}) : super(key: key);

  TextStyle _codeStyle(BuildContext context) => TextStyle(
        fontFamily: 'RobotoMono',
        color: Theme.of(context).textTheme.headline4?.color,
        fontWeight: Theme.of(context).brightness == Brightness.light
            ? FontWeight.bold
            : null,
      );

  TextStyle _linkStyle(BuildContext context) => TextStyle(
        fontFamily: 'RobotoMono',
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF9BCAFF)
            : const Color(0xFF0062A0),
      );

  @override
  Widget build(BuildContext context) {
    if (kGitUrl == '') return const SizedBox();

    return SelectableText.rich(
      TextSpan(children: [
        const TextSpan(
          text: 'Built${kCiProvider != '' ? ' by $kCiProvider' : ''} from ',
        ),
        LinkifySpan(
          text: kGitUrl,
          linkStyle: _linkStyle(context),
          onOpen: onOpenLaunchUrl,
        ),
        if (kCommitHash != '')
          TextSpan(children: [
            const TextSpan(text: ' at '),
            TextSpan(text: kCommitHash, style: _codeStyle(context)),
          ]),
        if (kGitRef != '')
          TextSpan(children: [
            const TextSpan(text: ' ('),
            TextSpan(text: kGitRef, style: _codeStyle(context)),
            const TextSpan(text: ')'),
          ]),
        const TextSpan(text: '.'),
      ]),
    );
  }
}
