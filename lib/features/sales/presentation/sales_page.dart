import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/logging/talker_config.dart';
import '../../../../core/di/logging_providers.dart';

class SalesPage extends ConsumerWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Kasa Sistemi'),
        actions: [
          IconButton(
            onPressed: () {
              TalkerConfig.logUserAction('Navigate to sales list');
              context.go('/sales');
            },
            icon: const Icon(Icons.list),
            tooltip: 'Sales List',
          ),
          IconButton(
            onPressed: () {
              TalkerConfig.logUserAction('Navigate to inventory');
              context.go('/inventory');
            },
            icon: const Icon(Icons.inventory),
            tooltip: 'Inventory Management',
          ),
          IconButton(
            onPressed: () {
              TalkerConfig.logUserAction('Refresh sales data');
              // TODO: Implement refresh functionality
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              TalkerConfig.logUserAction('Open performance dashboard');
              context.go('/performance');
            },
            icon: const Icon(Icons.analytics),
            tooltip: 'Performance Dashboard',
          ),
          IconButton(
            onPressed: () {
              TalkerConfig.logUserAction('Open AI dashboard');
              context.go('/ai');
            },
            icon: const Icon(Icons.psychology),
            tooltip: 'AI Dashboard',
          ),
          IconButton(
            onPressed: () {
              TalkerConfig.logUserAction('Open logs screen');
              final talker = ref.read(talkerProvider);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TalkerScreen(talker: talker),
                ),
              );
            },
            icon: const Icon(Icons.bug_report),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // POS Dashboard Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Hoş Geldiniz!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'POS Kasa Sistemine başlamak için aşağıdaki modülleri kullanın',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // POS Modules Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildModuleCard(
                    context,
                    'Ürünler',
                    Icons.inventory_2,
                    Colors.blue,
                    () {
                      TalkerConfig.logUserAction('Navigate to Products');
                      // TODO: Navigate to products when created
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ürünler modülü yakında!'),
                        ),
                      );
                    },
                  ),
                  _buildModuleCard(
                    context,
                    'Müşteriler',
                    Icons.people,
                    Colors.green,
                    () {
                      TalkerConfig.logUserAction('Navigate to Customers');
                      context.go('/customers');
                    },
                  ),
                  _buildModuleCard(
                    context,
                    'Sepet',
                    Icons.shopping_cart,
                    Colors.orange,
                    () {
                      TalkerConfig.logUserAction('Navigate to Cart');
                      context.go('/cart');
                    },
                  ),
                  _buildModuleCard(
                    context,
                    'Satışlar',
                    Icons.point_of_sale,
                    Colors.purple,
                    () {
                      TalkerConfig.logUserAction('Navigate to Sales');
                      context.go('/sales');
                    },
                  ),
                  _buildModuleCard(
                    context,
                    'Ödemeler',
                    Icons.payment,
                    Colors.red,
                    () {
                      TalkerConfig.logUserAction('Navigate to Payments');
                      // TODO: Navigate to payments when created
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ödemeler modülü yakında!'),
                        ),
                      );
                    },
                  ),
                  _buildModuleCard(
                    context,
                    'Raporlar',
                    Icons.assessment,
                    Colors.indigo,
                    () {
                      TalkerConfig.logUserAction('Navigate to Reports');
                      context.go('/reports');
                    },
                  ),
                  _buildModuleCard(
                    context,
                    'Envanter',
                    Icons.warehouse,
                    Colors.teal,
                    () {
                      TalkerConfig.logUserAction('Navigate to Inventory');
                      context.go('/inventory');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
