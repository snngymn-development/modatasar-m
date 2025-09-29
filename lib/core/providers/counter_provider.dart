import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple counter provider for testing Riverpod
final counterProvider = StateProvider<int>((ref) => 0);

/// Counter actions
final counterActionsProvider = Provider<CounterActions>((ref) {
  return CounterActions(ref);
});

class CounterActions {
  final Ref ref;

  CounterActions(this.ref);

  void increment() {
    ref.read(counterProvider.notifier).state++;
  }

  void decrement() {
    ref.read(counterProvider.notifier).state--;
  }

  void reset() {
    ref.read(counterProvider.notifier).state = 0;
  }
}
