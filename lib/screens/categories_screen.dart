import 'package:flutter/material.dart';
import '../data/dummy_prompts.dart';
import '../utils/theme.dart';
import '../widgets/responsive_layout.dart';
import 'category_prompts_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'البرمجة':
        return Icons.code_rounded;
      case 'التسويق':
        return Icons.campaign_rounded;
      case 'صناعة المحتوى':
        return Icons.create_rounded;
      case 'تصميم واجهات المستخدم':
        return Icons.design_services_rounded;
      case 'الأعمال':
        return Icons.business_center_rounded;
      case 'الإنتاجية':
        return Icons.task_alt_rounded;
      case 'تحسين محركات البحث':
        return Icons.travel_explore_rounded;
      case 'شبكات التواصل الاجتماعي':
        return Icons.share_rounded;
      case 'نصوص الفيديو':
        return Icons.video_library_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppTheme.neonCyan,
      AppTheme.neonViolet,
      AppTheme.neonEmerald,
      AppTheme.neonAmber,
      AppTheme.neonPink,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveLayout.getGridCrossAxisCount(context) + 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأقسام'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: appCategories.length,
        itemBuilder: (context, index) {
          final category = appCategories[index];
          final icon = _getCategoryIcon(category);
          final color = _getCategoryColor(index);

          return Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: color.withValues(alpha: 0.2), width: 1),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryPromptsScreen(category: category),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
