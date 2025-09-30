import 'package:go_router/go_router.dart';
import '../../features/sales/presentation/sales_page.dart';
import '../../features/sales/presentation/pages/sales_list_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/performance/presentation/pages/performance_dashboard.dart';
import '../../features/reports/presentation/pages/reports_dashboard.dart';
import '../../features/ai/presentation/pages/ai_dashboard.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SalesPage()),
    GoRoute(path: '/sales', builder: (_, __) => const SalesListPage()),
    GoRoute(path: '/inventory', builder: (_, __) => const InventoryPage()),
    GoRoute(path: '/cart', builder: (_, __) => const CartPage()),
    GoRoute(path: '/customers', builder: (_, __) => const CustomersPage()),
    GoRoute(
      path: '/performance',
      builder: (_, __) => const PerformanceDashboard(),
    ),
    GoRoute(path: '/reports', builder: (_, __) => const ReportsDashboard()),
    GoRoute(path: '/ai', builder: (_, __) => const AIDashboard()),
  ],
);
