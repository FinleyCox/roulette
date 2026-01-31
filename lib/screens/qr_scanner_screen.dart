import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/language_utils.dart';

class QRScannerScreen extends StatefulWidget {
  final String currentLanguage;
  const QRScannerScreen({super.key, required this.currentLanguage});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isDetected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageUtils.getSettingsText('scanQRCode', widget.currentLanguage),
        ),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (isDetected) return;
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              isDetected = true;
              Navigator.pop(context, barcode.rawValue);
              break;
            }
          }
        },
      ),
    );
  }
}
