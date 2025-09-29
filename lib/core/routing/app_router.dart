import 'package:go_router/go_router.dart';
import '../../features/sales/presentation/sales_page.dart';
import '../../features/sales/presentation/sales_result_test_page.dart';
import '../../features/sales/presentation/pages/sales_list_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SalesPage()),
    GoRoute(path: '/sales', builder: (_, __) => const SalesListPage()),
    GoRoute(
      path: '/result-test',
      builder: (_, __) => const SalesResultTestPage(),
    ),
    GoRoute(path: '/inventory', builder: (_, __) => const InventoryPage()),
  ],
);
