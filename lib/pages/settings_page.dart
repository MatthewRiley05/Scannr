import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isRound = false;
  bool isOne = false;

  @override
  void initState() {
    super.initState();
    _loadQrShapeSetting();
    _loadQrRoundSetting();
  }

  _loadQrShapeSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isRound = prefs.getBool('qrShape') ?? false;
    });
  }

  _saveQrShapeSetting() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('qrShape', isRound);
  }

  _loadQrRoundSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isOne = (prefs.getDouble('qrRound') ?? 0.0) == 1.0;
    });
  }

  _saveQrRoundSetting() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('qrRound', isOne ? 1.0 : 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.onSecondary,
      appBar: AppBar(
        title: const Text("Settings").animate().fade(),
        foregroundColor: colorScheme.inverseSurface,
        backgroundColor: colorScheme.onSecondary,
        ),
        body: SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    SwitchListTile(
                      title: const Text('Circular Data Pattern'),
                      value: isRound,
                      onChanged: (bool value) {
                        setState(() {
                          isRound = value;
                          _saveQrShapeSetting();
                        });
                      },
                      secondary: const Icon(Icons.radio_button_checked),
                    ),
                    SwitchListTile(
                      title: const Text('Rounded Edges'),
                      value: isOne,
                      onChanged: (bool value) {
                        setState(() {
                          isOne = value;
                          _saveQrRoundSetting();
                        });
                      },
                      secondary: const Icon(Icons.rounded_corner),
                    ),
                    const Gap(470),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 2 * 10,
                      child: const Card(
                        child: Center(
                          child: Text("Made by Matthew Raymundo with ❤️", style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
                        )
                      )
                    )
                  ],
                ),
              )
          ).animate().fade()
        )
      )
    );
  }
}