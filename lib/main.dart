import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clean_app/core/routing/app_router.dart';
import 'package:my_clean_app/core/theme/app_theme.dart';
import 'package:my_clean_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_clean_app/global/bloc/simple_bloc_observer.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  // Đảm bảo Flutter binding đã được khởi tạo.
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Dependency Injection
  await di.init();

  // Thiết lập BlocObserver để log
  Bloc.observer = SimpleBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cung cấp AuthBloc cho toàn bộ cây widget.
    // Bất kỳ widget con nào cũng có thể truy cập AuthBloc thông qua BlocProvider.of(context)
    // hoặc context.read<AuthBloc>()
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>(),
      child: MaterialApp.router(
        title: 'Flutter Clean Architecture',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
