import 'dart:typed_data';

import 'package:epc_qr/qr_data.dart';
import 'package:epc_qr/share/share_stub.dart'
    if (dart.library.html) 'package:epc_qr/share/share_web.dart'
    if (dart.library.io) 'package:epc_qr/share/share_io.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ViewCodePage extends StatelessWidget {
  const ViewCodePage({Key? key, required this.qrData}) : super(key: key);

  final EpcQrData qrData;

  @override
  Widget build(BuildContext context) {
    final qrCode = QrCode.fromData(
      data: qrData.qrDataString,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Information'),
        actions: [
          Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                if (!shareFeatureAvailable) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Saving is not yet supported for this platform.'),
                    ),
                  );
                  return;
                }

                final ByteData? img =
                    await QrPainter.withQr(qr: qrCode).toImageData(200);
                if (img == null) return;
                final List<int> imgData = img.buffer
                    .asUint8List(img.offsetInBytes, img.lengthInBytes);

                shareFile('payment-info.png', imgData, mimeType: 'image/png');
              },
            );
          }),
        ],
      ),
      body: ListView(
        children: [
          QrImageView.withQr(qr: qrCode),
        ],
      ),
    );
  }
}
