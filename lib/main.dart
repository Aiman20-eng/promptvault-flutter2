import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/prompt_provider.dart';
import 'screens/main_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const PromptVaultApp());
}

class PromptVaultApp extends StatelessWidget {
  const PromptVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PromptProvider())],
      child: MaterialApp(
        title: 'PromptVault - مكتبة التلقين',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        supportedLocales: const [Locale('ar', 'AE')],

        locale: const Locale('ar', 'AE'),

        home: const MainScreen(),
      ),
    );
  }
}
