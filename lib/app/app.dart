import 'package:flutter/material.dart';
import 'package:my_clean_app/app/app_binding.dart';
import 'package:my_clean_app/app/app_config.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AppBinding.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Init error: ${snapshot.error}'),
              ),
            ),
          );
        }

        return const AppConfig();
      },
    );
  }
}
