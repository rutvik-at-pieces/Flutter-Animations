import 'package:flutter/material.dart';
import 'package:flutter_animations/flutter_rive/bouncing_ball.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
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
          textTheme: GoogleFonts.gothicA1TextTheme(
            Theme.of(context).textTheme,
          )),
      home: const BouncingBall(),
    );
  }
}
