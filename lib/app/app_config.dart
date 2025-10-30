import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clean_app/core/routing/app_router.dart';
import 'package:my_clean_app/core/theme/app_theme.dart';
import 'package:my_clean_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_clean_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_clean_app/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:my_clean_app/features/category/presentation/bloc/category_bloc.dart';
import 'package:my_clean_app/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:my_clean_app/features/settings/presentation/bloc/settings_bloc.dart';
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
        BlocProvider<DashboardBloc>(
          create: (_) => di.sl<DashboardBloc>(),
        ),
        BlocProvider<TransactionBloc>(
          create: (_) => di.sl<TransactionBloc>(),
        ),
        BlocProvider<CategoryBloc>(
          create: (_) => di.sl<CategoryBloc>(),
        ),
        BlocProvider<StatisticsBloc>(
          create: (_) => di.sl<StatisticsBloc>(),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => di.sl<SettingsBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Expense Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
