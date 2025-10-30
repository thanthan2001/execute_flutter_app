import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/transaction/presentation/pages/transaction_list_page.dart';
import '../../features/transaction/presentation/pages/add_edit_transaction_page.dart';
import '../../features/dashboard/domain/entities/transaction_entity.dart';
import '../../features/category/presentation/pages/category_list_page.dart';
import '../../features/category/presentation/pages/add_edit_category_page.dart';
import '../../features/dashboard/domain/entities/category_entity.dart';
import '../../features/statistics/presentation/pages/statistics_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionListPage(),
      ),
      GoRoute(
        path: '/transactions/add',
        builder: (context, state) => const AddEditTransactionPage(),
      ),
      GoRoute(
        path: '/transactions/edit',
        builder: (context, state) {
          final transaction = state.extra as TransactionEntity?;
          return AddEditTransactionPage(transaction: transaction);
        },
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryListPage(),
      ),
      GoRoute(
        path: '/categories/add',
        builder: (context, state) => const AddEditCategoryPage(),
      ),
      GoRoute(
        path: '/categories/edit',
        builder: (context, state) {
          final category = state.extra as CategoryEntity?;
          return AddEditCategoryPage(category: category);
        },
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
