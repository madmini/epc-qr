import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:epc_qr/data/qr_data.dart';
import 'package:epc_qr/widgets/share/share_stub.dart'
    if (dart.library.html) 'package:epc_qr/widgets/share/share_web.dart'
    if (dart.library.io) 'package:epc_qr/widgets/share/share_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  final GlobalKey _qrBoundaryKey = GlobalKey(debugLabel: 'PaymentInfoQrView');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Information')),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          child: const Icon(Icons.save),
          onPressed: () => _shareQrCodeImage(context),
        ),
      ),
      body: Center(
        // two centers, otherwise the scrollbar is weirdly placed
        child: SingleChildScrollView(
          child: Center(
            child: RepaintBoundary(
              key: _qrBoundaryKey,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QrImageView.withQr(
                      qr: qrCode,
                      backgroundColor:
                          ThemeData.light().scaffoldBackgroundColor,
                      foregroundColor: Colors.black,
                    ),
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
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

    final boundary = _qrBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final imgData = await _imageToBytes(image);
    if (imgData == null) return;
    shareFile('payment-info.png', imgData, mimeType: 'image/png');
  }

  Future<List<int>?> _imageToBytes(ui.Image image) async {
    ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
