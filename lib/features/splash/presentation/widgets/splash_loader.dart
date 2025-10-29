// lib/features/splash/presentation/widgets/splash_loader.dart
import 'package:flutter/material.dart';

class SplashLoader extends StatelessWidget {
  const SplashLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: CircularProgressIndicator(),
    );
  }
}
