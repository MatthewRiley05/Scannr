import "dart:async";
import "package:flutter/material.dart";
import "package:mobile_scanner/mobile_scanner.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:awesome_snackbar_content/awesome_snackbar_content.dart";
import "package:url_launcher/url_launcher.dart";

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with WidgetsBindingObserver{
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    returnImage: true,
    useNewCameraSelector: true,
  );
  StreamSubscription<BarcodeCapture?>? _subscription;

  void _handleBarcode(BarcodeCapture? barcode) {
    if (barcode != null) {
      debugPrint("Barcode: ${barcode.barcodes.first.rawValue}");

      controller.stop();

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Container(
                  width: 30,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Data:",
                    style: TextStyle(fontSize: 20),
                  )
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await launchUrl(Uri.parse(barcode.barcodes.first.rawValue ?? ""));
                    } catch (e) {
                      debugPrint('Could not launch ${barcode.barcodes.first.rawValue}: $e');
                    }
                  },
                  child: Text(
                    "${barcode.barcodes.first.rawValue}",
                    style: const TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                ),
              ]
            )
          );
        }
      ).then((value) {
        controller.start();
      });
    }
    else {
      final error = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Oh snap!',
          message: 'An error occurred while scanning the QR code. Please try again.',
          contentType: ContentType.failure,
        )
      );
      ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(error);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = controller.barcodes.listen(_handleBarcode);

        unawaited(controller.start());
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = controller.barcodes.listen(_handleBarcode);
    unawaited(controller.start());
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    await controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.onSecondary,
      appBar: AppBar(
        title: const Text("Scanner").animate().fade(),
        foregroundColor: colorScheme.inverseSurface,
        backgroundColor: colorScheme.onSecondary,
        ),
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: MobileScanner(
                  fit: BoxFit.cover,
                  controller: controller,
                ),
          )
        ),
      ),
    );
  }
}