import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/logging_providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final talker = ref.watch(talkerProvider);

    // Flutter error'larını Talker'a yönlendir
    FlutterError.onError = (details) {
      talker.handle(details.exception, details.stack);
      FlutterError.presentError(details);
    };

    ErrorWidget.builder = (FlutterErrorDetails details) {
      talker.handle(details.exception, details.stack);
      return Material(
        child: Center(
          child: Text(
            'Bir şeyler ters gitti.\n${details.exception}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    };

    return TalkerWrapper(
      talker: talker,
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      ),
    );
  }
}
