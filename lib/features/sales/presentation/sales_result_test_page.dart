import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../domain/entities/sale.dart';
import '../data/repositories/sale_repository_impl.dart';
import '../../../../core/logging/talker_config.dart';
import '../../../../core/network/result.dart';
import '../../../../core/di/logging_providers.dart';
import '../../../../core/di/providers.dart';

// Result pattern kullanımı için test provider
final salesResultProvider = FutureProvider<Result<List<Sale>>>((ref) async {
  try {
    TalkerConfig.logBusiness('Sales Result Test page loaded');
    final dio = ref.watch(dioProvider);
    return SaleRepositoryImpl(dio: dio).fetchSalesResult();
  } catch (error, stackTrace) {
    TalkerConfig.logError(
      'Failed to load sales Result test',
      error,
      stackTrace,
    );
    rethrow;
  }
});

class SalesResultTestPage extends ConsumerWidget {
  const SalesResultTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Pattern Test'),
        actions: [
          IconButton(
            onPressed: () {
              TalkerConfig.logUserAction('Refresh Result test data');
              ref.invalidate(salesResultProvider);
            },
            icon: const Icon(Icons.refresh),
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
      body: state.when(
        loading: () {
          TalkerConfig.logInfo('Loading Result test data...');
          return const Center(child: CircularProgressIndicator());
        },
        error: (e, s) {
          TalkerConfig.logError('Error loading Result test data', e, s);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Provider Error: $e'),
                ElevatedButton(
                  onPressed: () => ref.refresh(salesResultProvider),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        },
        data: (result) {
          return result.when(
            success: (items) {
              TalkerConfig.logInfo(
                'Result pattern success: ${items.length} items',
              );
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final s = items[i];
                  return ListTile(
                    title: Text(
                      s.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('Toplam: ${s.total.toStringAsFixed(2)} ₺'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      TalkerConfig.logUserAction(
                        'Tapped on Result test sale: ${s.id}',
                      );
                    },
                  );
                },
              );
            },
            error: (failure) {
              TalkerConfig.logError('Result pattern error: ${failure.message}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Result Error: ${failure.message}'),
                    if (failure.code != null) Text('Kod: ${failure.code}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(salesResultProvider),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
