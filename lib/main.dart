import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as app_auth;
import 'providers/prompt_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase – مطلوب قبل استخدام أي خدمة
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const PromptVaultApp());
}

class PromptVaultApp extends StatelessWidget {
  const PromptVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // المزوّد الأصلي للأوامر
        ChangeNotifierProvider(create: (_) => PromptProvider()),
        // مزوّد المصادقة الجديد
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
      ],
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

        // ─── التنقل التلقائي بناءً على حالة المصادقة ─────────────
        // authStateChanges() هو المتطلب الأساسي للمحاضرة
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // حالة التحميل الأولية
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppTheme.neonCyan),
                ),
              );
            }

            // مستخدم مسجّل → الشاشة الرئيسية
            if (snapshot.hasData && snapshot.data != null) {
              return const MainScreen();
            }

            // غير مسجّل → شاشة تسجيل الدخول
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

