import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  _GeneratorPageState createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final TextEditingController textController = TextEditingController();
  String data = 'https://matthewriley05.github.io/';
  bool isRound= false;
  double isOne = 0.0;

  void updateText(val) {
    setState(() {
      data = val;
    });
  }

  void deleteText() {
    setState(() {
      data = '';
    });
    textController.clear();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final qrShape = prefs.getBool('qrShape') ?? false;
    final qrRound = (prefs.getDouble('qrRound') ?? 0.0) == 0.0 ? 0.0 : 1.0;

    setState(() {
      isRound = qrShape;
      isOne = qrRound;
    });
  }

  Future<Uint8List> _generateQrCode() async {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.L,
    );
    final qrImage = QrImage(qrCode);
    final byteData = await qrImage.toImageAsBytes(
      size: 512,
      decoration: PrettyQrDecoration(
        shape: isRound == false
            ? PrettyQrSmoothSymbol(roundFactor: isOne)
            : const PrettyQrRoundedSymbol(),
        background: Colors.white,
      ),
    );

    return byteData?.buffer.asUint8List() ?? Uint8List(0);
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.onSecondary,
      appBar: AppBar(
        title: const Text('Generator').animate().fade(),
        foregroundColor: colorScheme.inverseSurface,
        backgroundColor: colorScheme.onSecondary),
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: PrettyQrView.data(
                            data: data,
                            errorCorrectLevel: QrErrorCorrectLevel.L,
                            decoration: PrettyQrDecoration(
                              shape: isRound == false
                                ? PrettyQrSmoothSymbol(roundFactor: isOne) 
                                : const PrettyQrRoundedSymbol(),
                                )
                            )
                          ),
                  const Gap(100),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: TextFormField(
                      controller: textController,
                      onChanged: (val){
                        updateText(val);
                      },
                      decoration: InputDecoration(
                      labelText: "Enter data",
                      prefixIcon: const Icon(Icons.qr_code),
                      suffixIcon: IconButton(onPressed: deleteText, icon: const Icon(Icons.cancel)), 
                      border: const OutlineInputBorder(),
                    ),
                  )
                  ),
                  const Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                      child: const Text("Share"),
                        onPressed: () async {
                          final pngBytes = await _generateQrCode();
                            final xFile = XFile.fromData(pngBytes.buffer.asUint8List(), name: 'qr.png', mimeType: 'image/png');
                            final result = await Share.shareXFiles([xFile], subject: "QR Code");
                            if (result.status == ShareResultStatus.success) {
                              Fluttertoast.showToast(
                                msg: "Image shared!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                              );
                            }
                        },
                      ),
                      const Gap(20),
                      ElevatedButton(
                      child: const Text("Save to gallery"),
                        onPressed: () async {
                          final pngBytes = await _generateQrCode();
                          await Gal.putImageBytes(pngBytes);
                          Fluttertoast.showToast(
                            msg: "Image saved!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                          );
                        },
                      ),
                   ]
                  )
              ],
            ).animate().fade()
          )
        )
      );
    }
}