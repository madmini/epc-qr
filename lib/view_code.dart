import 'dart:typed_data';

import 'package:epc_qr/qr_data.dart';
import 'package:epc_qr/share/share_stub.dart'
    if (dart.library.html) 'package:epc_qr/share/share_web.dart'
    if (dart.library.io) 'package:epc_qr/share/share_io.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ViewCodePage extends StatelessWidget {
  ViewCodePage({Key? key, required this.qrData})
      : qrCode = QrCode.fromData(
          data: qrData.qrDataString,
          errorCorrectLevel: QrErrorCorrectLevel.M,
        ),
        super(key: key);

  final EpcQrData qrData;

  final QrCode qrCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Information'),
        // actions: [
        //   Builder(builder: (context) {
        //     return IconButton(
        //       icon: const Icon(Icons.save),
        //       onPressed: () => _shareQrCodeImage(context),
        //     );
        //   }),
        // ],
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          child: const Icon(Icons.save),
          onPressed: () => _shareQrCodeImage(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            QrImageView.withQr(qr: qrCode),
            const SizedBox(height: 24),
            Text(qrData.name, textScaleFactor: 2.5),
            Text('(${qrData.iban})', textScaleFactor: 1.25),
            if (qrData.amount != 0)
              Text(
                '€${qrData.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            if (qrData.reference.isNotEmpty)
              Text(qrData.reference)
            else if (qrData.referenceText.isNotEmpty)
              Text(qrData.referenceText),
          ],
        ),
      ),
    );
  }

  Future<void> _shareQrCodeImage(BuildContext context) async {
    if (!shareFeatureAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saving is not yet supported for this platform.'),
        ),
      );
      return;
    }

    final ByteData? img = await QrPainter.withQr(qr: qrCode).toImageData(200);
    if (img == null) return;
    final List<int> imgData =
        img.buffer.asUint8List(img.offsetInBytes, img.lengthInBytes);

    shareFile('payment-info.png', imgData, mimeType: 'image/png');
  }
}
