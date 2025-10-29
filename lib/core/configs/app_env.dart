import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static Future<void> init({String fileName = '.env'}) async {
    await dotenv.load(fileName: fileName);
  }

  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static int get timeout =>
      int.tryParse(dotenv.env['TIMEOUT'] ?? '3000') ?? 3000;
}
