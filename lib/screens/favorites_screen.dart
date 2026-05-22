import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prompt_provider.dart';
import '../services/firestore_service.dart';
import '../utils/theme.dart';
import '../widgets/prompt_card.dart';
import '../widgets/responsive_layout.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PromptProvider>();
    final crossAxisCount = ResponsiveLayout.getGridCrossAxisCount(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
      ),
      // ─── استخدام StreamBuilder للتحديثات الفورية من Firestore ───
      body: currentUser != null
          ? StreamBuilder<List<String>>(
              stream: FirestoreService().getFavoritesStream(currentUser.uid),
              builder: (context, snapshot) {
                // حالة التحميل
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.neonCyan),
                  );
                }

                // قائمة IDs المفضلة من Firestore
                final favoriteIds = snapshot.data ?? [];

                // تصفية الأوامر المحلية بناءً على IDs الفعلية من Firestore
                final favorites = provider.allPrompts
                    .where((p) => favoriteIds.contains(p.id))
                    .toList();

                if (favorites.isEmpty) {
                  return _buildEmptyState();
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent: 210,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    return PromptCard(prompt: favorites[index]);
                  },
                );
              },
            )
          // المستخدم غير مسجّل: نستخدم البيانات المحلية فقط
          : _buildLocalFavorites(provider, crossAxisCount),
    );
  }

  /// عرض المفضلة من المزوّد المحلي (fallback للضيوف)
  Widget _buildLocalFavorites(PromptProvider provider, int crossAxisCount) {
    final favorites = provider.favoritePrompts;
    if (favorites.isEmpty) return _buildEmptyState();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 210,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        return PromptCard(prompt: favorites[index]);
      },
    );
  }

  /// واجهة الحالة الفارغة
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 72,
            color: AppTheme.neonPink.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد عناصر مفضلة بعد',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'اضغط على أيقونة القلب على أي أمر لحفظه في قائمة الوصول السريع الخاصة بك.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

