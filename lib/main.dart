import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animations/flutter_design_challenges/logIn_concept/login_concept.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      isToolbarVisible: false,
      builder: (context) => const MyApp(), // Wrap your app
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Animations',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0e7cfe),
        primarySwatch: Colors.blue,
        // textTheme: GoogleFonts.rubikTextTheme(Theme.of(context).textTheme),
      ),
      builder: DevicePreview.appBuilder,
      home: const LogInScreen(),
    );
  }
}

class ShaderStripesDemo extends StatelessWidget {
  const ShaderStripesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
