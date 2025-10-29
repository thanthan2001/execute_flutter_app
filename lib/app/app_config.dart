import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clean_app/core/routing/app_router.dart';
import 'package:my_clean_app/core/theme/app_theme.dart';
import 'package:my_clean_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_clean_app/core/di/injection_container.dart' as di;

class AppConfig extends StatelessWidget {
  const AppConfig({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Flutter Clean Architecture',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
