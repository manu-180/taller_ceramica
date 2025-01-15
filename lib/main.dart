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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
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
        AppLocalizationsDelegate(), // Delegado personalizado para traducciones
        GlobalMaterialLocalizations.delegate, // Traducciones Material Design
        GlobalWidgetsLocalizations.delegate, // Traducciones de widgets
        GlobalCupertinoLocalizations.delegate, // Traducciones Cupertino
      ],
      supportedLocales: const [
    Locale('en'), // Inglés
    Locale('es'), // Español
    Locale('fr'), // Francés
    Locale('de'), // Alemán
    Locale('it'), // Italiano
    Locale('pt'), // Portugués
    Locale('zh'), // Chino Simplificado
    Locale('ja'), // Japonés
    Locale('ko'), // Coreano
    Locale('ar'), // Árabe
    Locale('hi'), // Hindi
    Locale('ru'), // Ruso
    Locale('tr'), // Turco
    Locale('nl'), // Holandés
    Locale('sv'), // Sueco
    Locale('pl'), // Polaco
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
