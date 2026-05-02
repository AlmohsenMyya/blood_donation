import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sheryan/core/theme/app_theme.dart';
import 'package:sheryan/firebase_options.dart';
import 'package:sheryan/l10n/app_localizations.dart';
import 'package:sheryan/providers/auth/auth_provider.dart';
import 'package:sheryan/providers/locale/locale_provider.dart';
import 'package:sheryan/providers/theme/theme_provider.dart';
import 'package:sheryan/screens/auth/role_selection_screen.dart';
import 'package:sheryan/screens/home/home_screen.dart';
import 'package:sheryan/screens/misc/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: theme,
      home: const SplashScreen(),
    );
  }
}

class StartupRouter extends ConsumerWidget {
  const StartupRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      data: (user) {
        if (user != null) {
          return const HomeScreen();
        } else {
          return const RoleSelectionScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context)!.genericError(err.toString())),
        ),
      ),
    );
  }
}
