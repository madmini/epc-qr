import 'dart:io';
import 'dart:typed_data';

import 'package:epc_qr/qr_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ViewCodePage extends StatelessWidget {
  ViewCodePage({Key? key, required this.qrData}) : super(key: key);

  final EpcQrData qrData;
  // late QrCode qrCode;

  @override
  Widget build(BuildContext context) {
    final qrCode = QrCode.fromData(
      data: qrData.qrDataString,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    )..make();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Information'),
        actions: [
          Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                final ByteData? img =
                    await QrPainter.withQr(qr: qrCode).toImageData(200);
                if (img == null) return;
                final List<int> imgData = img.buffer
                    .asUint8List(img.offsetInBytes, img.lengthInBytes);

                if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Saving is not yet supported for this platform.'),
                    ),
                  );
                } else {
                  final dir = await getTemporaryDirectory();
                  final file = File('$dir/payment-info.png');
                  await file.writeAsBytes(imgData);

                  await Share.shareFiles([file.path], mimeTypes: ['image/png']);
                }
              },
            );
          }),
        ],
      ),
      body: ListView(
        children: [
          QrImage.withQr(qr: qrCode),
        ],
      ),
    );
  }
}
