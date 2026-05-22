import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../providers/prompt_provider.dart';
import '../utils/theme.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'collection_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    FavoritesScreen(),
    CollectionScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // تهيئة مزامنة Firestore عند دخول MainScreen (أي بعد تسجيل الدخول)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<app_auth.AuthProvider>();
      final promptProvider = context.read<PromptProvider>();
      if (authProvider.currentUid != null) {
        promptProvider.initFirestoreSync(authProvider.currentUid!);
      }
    });
  }

  /// تسجيل الخروج مع تأكيد
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // إيقاف مزامنة Firestore قبل الخروج
      context.read<PromptProvider>().clearFirestoreSync();
      await context.read<app_auth.AuthProvider>().signOut();
      // StreamBuilder في main.dart سيعود تلقائياً إلى LoginScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionCount = context.watch<PromptProvider>().collectionCount;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.surfaceHighlight.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // الضغط على الزر الأخير (الحساب) يفتح قائمة تسجيل الخروج
            if (index == 4) {
              _handleLogout();
              return;
            }
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'الأقسام',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline_rounded),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'المفضلة',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: collectionCount > 0,
                label: Text('$collectionCount', style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: AppTheme.neonCyan,
                textColor: Colors.black,
                child: const Icon(Icons.bookmarks_outlined),
              ),
              activeIcon: Badge(
                isLabelVisible: collectionCount > 0,
                label: Text('$collectionCount', style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: AppTheme.neonCyan,
                textColor: Colors.black,
                child: const Icon(Icons.bookmarks_rounded),
              ),
              label: 'مجموعتي',
            ),
            // زر تسجيل الخروج
            const BottomNavigationBarItem(
              icon: Icon(Icons.logout_rounded),
              label: 'خروج',
            ),
          ],
        ),
      ),
    );
  }
}

