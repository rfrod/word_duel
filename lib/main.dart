import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/ad_manager.dart';
import 'core/utils/revenue_cat_manager.dart';
import 'data/repositories/dictionary_repository.dart';
import 'features/game/notifiers/game_notifier.dart';

// ─── Gerado por: flutter gen-l10n ────────────────────────────────────────────
// Arquivo gerado em lib/gen_l10n/ via `flutter gen-l10n` (l10n.yaml).
import 'gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Supabase ──────────────────────────────────────────────────────────────
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://SEU_PROJETO.supabase.co',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'SUA_ANON_KEY',
    ),
  );

  // ── RevenueCat + AdMob (mobile only) ─────────────────────────────────────
  if (!kIsWeb) {
    await RevenueCatManager.instance.initialize(
      androidApiKey: const String.fromEnvironment(
        'REVENUECAT_ANDROID_KEY',
        defaultValue: 'appl_xxxx',
      ),
      iosApiKey: const String.fromEnvironment(
        'REVENUECAT_IOS_KEY',
        defaultValue: 'appl_xxxx',
      ),
    );
    await AdManager.instance.initialize();
  }

  // ── Dicionário Hive ───────────────────────────────────────────────────────
  final dict = DictionaryRepository();
  await dict.initialize();

  runApp(
    ProviderScope(
      overrides: [
        // Injeta o repositório de dicionário inicializado
        dictionaryRepositoryProvider.overrideWithValue(dict),
      ],
      child: const WordDuelApp(),
    ),
  );
}

class WordDuelApp extends ConsumerWidget {
  const WordDuelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Duelo de Palavras',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,

      // ── Internacionalização ──────────────────────────────────────────────
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
      locale: const Locale('pt', 'BR'), // Idioma padrão; altere conforme o perfil do usuário
      debugShowCheckedModeBanner: false,
    );
  }
}
