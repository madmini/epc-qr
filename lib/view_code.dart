import 'package:epc_qr/qr_data.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final img = QrPainter.withQr(qr: qrCode).toImageData(200);
            },
          ),
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
