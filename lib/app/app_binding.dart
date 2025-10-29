import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clean_app/global/bloc/simple_bloc_observer.dart';
import 'package:my_clean_app/core/di/injection_container.dart' as di;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/configs/app_env.dart';
import '../core/di/injection_container.dart' as PrefManager;

class AppBinding {
  static Future<void> init() async {
    // Thiết lập Bloc Observer
    Bloc.observer = SimpleBlocObserver();
    // Khởi tạo dependency injection
    await di.init();

    // Load biến môi trường
    await AppEnv.init(fileName: '.env');

    // Khởi tạo SharedPreferences
    await PrefManager.init();
    // Nếu sau này có thêm Firebase, dotenv, Sentry,... thêm tại đây
    // await Firebase.initializeApp();
    // await dotenv.load();
  }
}
