import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Barcodescanner extends StatefulWidget {
  const Barcodescanner({super.key});

  @override
  State<Barcodescanner> createState() => _BarcodescannerState();
}

class _BarcodescannerState extends State<Barcodescanner> {
  String scannedData = "Scan a barcode or QR code";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Barcode Scanner")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(scannedData, style: TextStyle(fontSize: 18)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
           final result=await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OpenScanner()),
            );
             if (result != null && result is String) {
              print("Scanned Data: $result");
                setState(() {
                  scannedData = result!.toString();
                });
              }
            },
        child: Icon(Icons.barcode_reader, size: 30),
        tooltip: "Reset Scanner",
      ),
    );
  }
}


class OpenScanner extends StatefulWidget {
  const OpenScanner({super.key});

  @override
  State<OpenScanner> createState() => _OpenScannerState();
}

class _OpenScannerState extends State<OpenScanner> {
  String scannedData = "Scan a barcode or QR code";

  void onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      scannedData = barcode.rawValue ?? "No data";
      // Scan ပြီးလျှင် Result ပြန်ပို့ပေးမည်
      Navigator.pop(context, scannedData);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Open Scanner")),
      body: Center(
        child:  Expanded(
            child: MobileScanner(
              controller: MobileScannerController(),
              onDetect: onDetect,
            ),
          ),
      ),
    );
  }
}
