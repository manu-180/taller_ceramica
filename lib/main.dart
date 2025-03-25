import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:taller_ceramica/config/router/app_router.dart';
import 'package:taller_ceramica/config/theme/app_theme.dart';
import 'package:taller_ceramica/l10n/app_localizations.dart';
import 'package:taller_ceramica/providers/theme_provider.dart';
import 'package:taller_ceramica/subscription/subscription_manager.dart';
import 'dart:io';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno asdasdffsolo si existe el archivo .env
  if (File('.env').existsSync()) {
    if (!dotenv.isInitialized) {
  await dotenv.load(fileName: ".env");
}

  }

  // Seleccionar método de carga de variables según entorno
  final supabaseUrl = Platform.environment.containsKey('CI')
      ? String.fromEnvironment("SUPABASE_URL")
      : dotenv.env['SUPABASE_URL'] ?? '';

  final supabaseAnonKey = Platform.environment.containsKey('CI')
      ? String.fromEnvironment("SUPABASE_ANON_KEY")
      : dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  await initializeDateFormatting('es_ES', null);

  final subscriptionManager = SubscriptionManager();
  subscriptionManager.listenToPurchaseUpdates();
  await subscriptionManager.restorePurchases();
  await subscriptionManager.checkAndUpdateSubscription();

  runApp(const ProviderScope(child: MyApp()));
}

final supabase = Supabase.instance.client;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppTheme themeNotify = ref.watch(themeNotifyProvider);

    return MaterialApp.router(
      title: "Taller de cerámica",
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: themeNotify.getColor(),
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('pt'),
        Locale('de'),
        Locale('it'),
        Locale('zh'),
        Locale('ja'),
        Locale('ko'),
        Locale('ar'),
        Locale('hi'),
        Locale('ru'),
        Locale('tr'),
        Locale('nl'),
        Locale('sv'),
        Locale('pl'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return const Locale('en');
        }

        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }

        return const Locale('en');
      },
    );
  }
}
