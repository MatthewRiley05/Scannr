import 'package:flutter/material.dart';
import 'package:qr_generator/navigation_bar.dart';
import 'color_schemes.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "QR Generator",
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme, fontFamily: 'Poppins'),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme, fontFamily: 'Poppins'),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const NavigationMenu(),
    );
  }
}