import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Barcodescanner extends StatefulWidget {
  const Barcodescanner({super.key});

  @override
  State<Barcodescanner> createState() => _BarcodescannerState();
}

class _BarcodescannerState extends State<Barcodescanner> {
  String scannedCode = 'Scan a barcode or QR code';

  void _barcode(Barcode barcode) {
    setState(() {
      scannedCode = barcode.rawValue ?? 'No data found!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Scanner')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: MobileScannerController(
                facing: CameraFacing.back,
                torchEnabled: false,
              ),
              onDetect: (result) {
                _barcode(Barcode as Barcode);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              scannedCode,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
