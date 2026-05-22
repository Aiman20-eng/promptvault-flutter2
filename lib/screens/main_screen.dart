import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          ],
        ),
      ),
    );
  }
}
