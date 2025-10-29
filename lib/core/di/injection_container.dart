import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:my_clean_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:my_clean_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:my_clean_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:my_clean_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:my_clean_app/features/auth/presentation/bloc/auth_bloc.dart';
import '../configs/app_env.dart';
import '../network/network_info.dart';

// Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // ## Features - Auth
  // Bloc
  // Đăng ký factory, vì mỗi lần cần AuthBloc, ta muốn có một instance mới.
  sl.registerFactory(() => AuthBloc(loginUsecase: sl()));

  // Use cases
  // Đăng ký lazy singleton, chỉ được khởi tạo khi được gọi lần đầu tiên.
  sl.registerLazySingleton(() => LoginUsecase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
// Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // ## Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ## External
  // Đăng ký các thư viện bên ngoài.
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ));

    // Bạn có thể thêm interceptor nếu muốn log
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
    ));

    return dio;
  });
  sl.registerLazySingleton(() => Connectivity());
}
