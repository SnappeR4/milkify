import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  final bool sale;
  final bool toggle;
  const QrScannerScreen({super.key, required this.sale, required this.toggle});

  @override
  QrScannerScreenState createState() => QrScannerScreenState();
}

class QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isFlashOn = false;
  late bool isToggleOn;
  @override
  void initState() {
    super.initState();
    isToggleOn = widget.toggle;
  }
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildQrView(context),
          _buildControlOverlay(),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = MediaQuery.of(context).size.width * 0.7; // 70% of screen width for the scan area

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.greenAccent,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, permission) => _onPermissionSet(context, ctrl, permission),
    );
  }

  Widget _buildControlOverlay() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              IconButton(
                icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
                onPressed: _toggleFlash,
              ),
            ],
          ),
        ),
        const Spacer(),
        widget.sale ?
        Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Continue Collection', style: TextStyle(color: Colors.white)),
              Switch(
                value: isToggleOn,
                onChanged: (bool value) {
                  setState(() {
                    isToggleOn = value;
                  });
                },
              ),
            ],
          ),
        ):Container(),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        controller.pauseCamera();
        Get.back(result: {'code': scanData.code, 'toggle': isToggleOn}); // Pass both code and toggle status
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool permissionGranted) {
    if (!permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required to scan QR codes.')),
      );
    }
  }

  void _toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      setState(() {
        isFlashOn = !isFlashOn;
      });
    }
  }
}
