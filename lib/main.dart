import 'package:flutter/material.dart';
import 'package:petcare/core/text_styles.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Text("Esto es un texto", style: TextStyles.bodyTextBlack,),
            ],
          ),
        ),
      ),
    );
  }
}
