import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/prompt_provider.dart';
import '../utils/theme.dart';
import '../widgets/platform_badge.dart';

class PromptDetailsScreen extends StatelessWidget {
  final String promptId;

  const PromptDetailsScreen({super.key, required this.promptId});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.neonEmerald),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'تم نسخ نص الأمر بالكامل إلى الحافظة بنجاح!',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceHighlight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PromptProvider>();
    
    final promptIndex = provider.allPrompts.indexWhere((p) => p.id == promptId);
    if (promptIndex == -1) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('الأمر غير موجود')),
      );
    }
    
    final prompt = provider.allPrompts[promptIndex];
    final isCollected = provider.collectionIds.contains(prompt.id);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // الترويسة العلوية الحديثة
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // التدرج اللوني
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.neonCyan.withValues(alpha: 0.15),
                            AppTheme.background,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // الأيقونة الخلفية
                    Positioned(
                      left: -20, // ليتناسب مع الاتجاه العربي
                      bottom: -20,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 160,
                        color: AppTheme.neonCyan.withValues(alpha: 0.05),
                      ),
                    ),
                    // الشريط السفلي داخل الترويسة
                    Positioned(
                      right: 20,
                      left: 20,
                      bottom: 16,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.surfaceHighlight),
                            ),
                            child: Text(
                              prompt.category,
                              style: const TextStyle(
                                color: AppTheme.neonCyan,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          PlatformBadge(platform: prompt.platform),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // زر التفضيل
                IconButton(
                  icon: Icon(
                    prompt.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: prompt.isFavorite ? AppTheme.neonPink : AppTheme.textPrimary,
                  ),
                  onPressed: () => provider.toggleFavorite(prompt.id),
                  tooltip: prompt.isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                ),
                const SizedBox(width: 8),
              ],
            ),

            // محتوى تفاصيل الأمر
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان
                    Text(
                      prompt.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // الوصف القصير
                    Text(
                      prompt.description,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // عنوان قسم القالب
                    Row(
                      children: [
                        const Icon(Icons.terminal_rounded, color: AppTheme.neonViolet, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'قالب الأمر (PROMPT)',
                          style: TextStyle(
                            color: AppTheme.neonViolet,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // زر النسخ المضمن
                        TextButton.icon(
                          onPressed: () => _copyToClipboard(context, prompt.fullPrompt),
                          icon: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.neonCyan),
                          label: const Text('نسخ الأمر', style: TextStyle(color: AppTheme.neonCyan, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // صندوق الكود / التلقين
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.surfaceHighlight),
                      ),
                      child: SelectableText(
                        prompt.fullPrompt,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontFamily: 'monospace',
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // قسم الشرح وطريقة الاستخدام
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, color: AppTheme.neonAmber, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'طريقة الاستخدام / الشرح المفصل',
                          style: TextStyle(
                            color: AppTheme.neonAmber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.surfaceHighlight.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        prompt.explanation,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // قائمة الوسوم
                    const Text(
                      'الوسوم',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: prompt.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceHighlight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.surfaceHighlight.withValues(alpha: 0.5))),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // زر المفضلة السريع
              OutlinedButton.icon(
                onPressed: () => provider.toggleFavorite(prompt.id),
                icon: Icon(
                  prompt.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: prompt.isFavorite ? AppTheme.neonPink : AppTheme.textPrimary,
                  size: 20,
                ),
                label: Text(
                  prompt.isFavorite ? 'مفضلة' : 'تفضيل',
                  style: TextStyle(
                    color: prompt.isFavorite ? AppTheme.neonPink : AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: prompt.isFavorite ? AppTheme.neonPink : AppTheme.surfaceHighlight),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 12),

              // زر الإضافة / الإزالة من المجموعة
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isCollected) {
                      provider.removeFromCollection(prompt.id);
                    } else {
                      provider.addToCollection(prompt.id);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCollected ? AppTheme.surfaceHighlight : AppTheme.neonCyan,
                    foregroundColor: isCollected ? AppTheme.textPrimary : Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(isCollected ? Icons.bookmark_added : Icons.bookmark_add, size: 20),
                  label: Text(
                    isCollected ? 'إزالة من المجموعة' : 'إضافة إلى المجموعة',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
