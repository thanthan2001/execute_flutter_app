// lib/features/splash/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_clean_app/global/widgets/base_scaffold.dart';
import '../../../../core/storage/user_pref.dart';
import '../widgets/splash_logo.dart';
import '../widgets/splash_title.dart';
import '../widgets/splash_loader.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (UserPref.isLoggedIn()) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      showAppBar: false,
      bodyPadding: EdgeInsets.zero,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SplashLogo(),
            SizedBox(height: 20),
            SplashTitle(),
            SizedBox(height: 10),
            SplashLoader(),
          ],
        ),
      ),
    );
  }
}
