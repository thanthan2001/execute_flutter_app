import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_clean_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:my_clean_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:my_clean_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:my_clean_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:my_clean_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_clean_app/features/category/data/datasources/category_mock_data.dart';
import 'package:my_clean_app/features/category/data/models/category_model.dart';
import 'package:my_clean_app/features/transaction/data/models/transaction_model.dart';
import 'package:my_clean_app/features/category/data/datasources/category_local_data_source.dart';
import 'package:my_clean_app/features/category/data/datasources/category_local_data_source_impl.dart';
import 'package:my_clean_app/features/transaction/data/datasources/transaction_local_data_source.dart';
import 'package:my_clean_app/features/transaction/data/datasources/transaction_local_data_source_impl.dart';
import 'package:my_clean_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:my_clean_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:my_clean_app/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:my_clean_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_clean_app/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:my_clean_app/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:my_clean_app/features/transaction/domain/usecases/add_transaction_usecase.dart';
import 'package:my_clean_app/features/transaction/domain/usecases/delete_transaction_usecase.dart';
import 'package:my_clean_app/features/transaction/domain/usecases/get_all_categories_usecase.dart';
import 'package:my_clean_app/features/transaction/domain/usecases/get_all_transactions_usecase.dart';
import 'package:my_clean_app/features/transaction/domain/usecases/update_transaction_usecase.dart';
import 'package:my_clean_app/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:my_clean_app/features/category/data/repositories/category_management_repository_impl.dart';
import 'package:my_clean_app/features/category/domain/repositories/category_management_repository.dart';
import 'package:my_clean_app/features/category/domain/usecases/add_category_usecase.dart';
import 'package:my_clean_app/features/category/domain/usecases/delete_category_usecase.dart';
import 'package:my_clean_app/features/category/domain/usecases/get_all_categories_usecase.dart'
    as category_mgmt;
import 'package:my_clean_app/features/category/domain/usecases/update_category_usecase.dart';
import 'package:my_clean_app/features/category/presentation/bloc/category_bloc.dart';
import 'package:my_clean_app/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:my_clean_app/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:my_clean_app/features/statistics/domain/usecases/get_statistics_summary_usecase.dart';
import 'package:my_clean_app/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:my_clean_app/features/settings/domain/usecases/clear_all_transactions_usecase.dart';
import 'package:my_clean_app/features/settings/presentation/bloc/settings_bloc.dart';
import '../configs/app_env.dart';
import '../network/network_info.dart';

// Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // Nếu đã khởi tạo rồi thì không làm gì cả (tránh lỗi khi hot reload)
  if (sl.isRegistered<DashboardBloc>()) {
    return;
  }

  // Khởi tạo Hive
  await Hive.initFlutter();

  // Đăng ký Hive adapters (chỉ đăng ký nếu chưa có)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TransactionModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(CategoryModelAdapter());
  }

  // ## Data Sources - Initialize first
  // Category Data Source
  final categoryLocalDataSource = CategoryLocalDataSourceImpl();
  await categoryLocalDataSource.init();

  // Transaction Data Source
  final transactionLocalDataSource = TransactionLocalDataSourceImpl();
  await transactionLocalDataSource.init();

  // Khởi tạo categories mặc định nếu chưa có
  final categories = await categoryLocalDataSource.getAllCategories();
  print('📊 Current categories count: ${categories.length}');

  if (categories.isEmpty) {
    print('🔄 Initializing default categories...');
    await CategoryMockData.initDefaultCategories(categoryLocalDataSource);
    final newCategories = await categoryLocalDataSource.getAllCategories();
    print(
        '✅ Default categories initialized: ${newCategories.length} categories');
  } else {
    print('✅ Categories already exist: ${categories.length} categories');
  }

  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => categoryLocalDataSource,
  );

  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => transactionLocalDataSource,
  );

  // ## Features - Dashboard
  // Bloc
  sl.registerFactory(() => DashboardBloc(
        getDashboardSummaryUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetDashboardSummaryUseCase(sl()));

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      transactionRepository: sl(),
    ),
  );

  // ## Features - Category Management
  // Bloc
  sl.registerFactory(() => CategoryBloc(
        getAllCategoriesUseCase: sl(),
        addCategoryUseCase: sl(),
        updateCategoryUseCase: sl(),
        deleteCategoryUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => category_mgmt.GetAllCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));

  // Repository
  sl.registerLazySingleton<CategoryManagementRepository>(
    () => CategoryManagementRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // ## Features - Transaction
  // Bloc
  sl.registerFactory(() => TransactionBloc(
        getAllTransactionsUseCase: sl(),
        getAllCategoriesUseCase: sl(),
        addTransactionUseCase: sl(),
        updateTransactionUseCase: sl(),
        deleteTransactionUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetAllTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => GetAllCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddTransactionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTransactionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTransactionUseCase(sl()));

  // Repository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      localDataSource: sl(),
      categoryRepository: sl(),
    ),
  );

  // ## Features - Statistics
  // Bloc
  sl.registerFactory(() => StatisticsBloc(
        getStatisticsSummaryUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetStatisticsSummaryUseCase(sl()));

  // Repository
  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(
      transactionDataSource: sl(),
      categoryDataSource: sl(),
    ),
  );

  // ## Features - Settings
  // Bloc
  sl.registerFactory(() => SettingsBloc(
        clearAllTransactionsUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => ClearAllTransactionsUseCase(sl()));

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
