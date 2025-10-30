import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_clean_app/global/bloc/simple_bloc_observer.dart';
import 'package:my_clean_app/core/di/injection_container.dart' as di;
import '../core/configs/app_env.dart';

class AppBinding {
  static Future<void> init() async {
    // Thiết lập Bloc Observer
    Bloc.observer = SimpleBlocObserver();

    // Khởi tạo locale data cho date formatting
    await initializeDateFormatting('vi_VN', null);

    // Load biến môi trường (optional, có thể fail)
    try {
      await AppEnv.init(fileName: '.env');
    } catch (e) {
      print('Warning: Could not load .env file: $e');
    }

    // Khởi tạo dependency injection (bao gồm cả Hive và SharedPreferences)
    await di.init();

    // Nếu sau này có thêm Firebase, Sentry,... thêm tại đây
    // await Firebase.initializeApp();
  }
}
