import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:taller_ceramica/config/router/app_router.dart';
import 'package:taller_ceramica/config/theme/app_theme.dart';
import 'package:taller_ceramica/providers/theme_provider.dart';
import 'package:taller_ceramica/subscription/subscription_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Inicializa el flujo de compras
  final subscriptionManager = SubscriptionManager();
  subscriptionManager.listenToPurchaseUpdates();

  // Restaura las compras y verifica el estado de las suscripciones
  await subscriptionManager.restorePurchases();
  await SubscriptionManager()
      .checkAndUpdateSubscription(); // Verifica y actualiza en Supabase

  runApp(const ProviderScope(child: MyApp()));
}

final supabase = Supabase.instance.client;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtén el tema actual desde Riverpod
    final AppTheme themeNotify = ref.watch(themeNotifyProvider);

    return MaterialApp.router(
      title: "Taller de cerámica",
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: themeNotify.getColor(),
    );
  }
}
