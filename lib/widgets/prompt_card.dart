import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/prompt_model.dart';
import '../providers/prompt_provider.dart';
import '../utils/theme.dart';
import '../screens/prompt_details_screen.dart';
import 'platform_badge.dart';

class PromptCard extends StatelessWidget {
  final PromptModel prompt;

  const PromptCard({super.key, required this.prompt});

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: prompt.fullPrompt));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.neonEmerald),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'تم نسخ نص الأمر إلى الحافظة بنجاح!',
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
    final currentPrompt = provider.allPrompts.firstWhere(
      (p) => p.id == prompt.id,
      orElse: () => prompt,
    );
    final isCollected = provider.collectionIds.contains(currentPrompt.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PromptDetailsScreen(promptId: currentPrompt.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف العلوي: الوسم الخاص بالقسم وشارة المنصة
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceHighlight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      currentPrompt.category,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  PlatformBadge(platform: currentPrompt.platform),
                ],
              ),
              const SizedBox(height: 12),

              // العنوان
              Text(
                currentPrompt.title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // الوصف القصير
              Expanded(
                child: Text(
                  currentPrompt.description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),

              // فاصل
              Divider(color: AppTheme.surfaceHighlight.withValues(alpha: 0.3), height: 1),
              const SizedBox(height: 8),

              // أزرار الإجراءات السفلية: تفضيل، إضافة للمجموعة، نسخ
              Row(
                children: [
                  // زر التفضيل
                  IconButton(
                    icon: Icon(
                      currentPrompt.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: currentPrompt.isFavorite ? AppTheme.neonPink : AppTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => provider.toggleFavorite(currentPrompt.id),
                    tooltip: currentPrompt.isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  const SizedBox(width: 4),

                  // زر الإضافة للمجموعة
                  TextButton.icon(
                    onPressed: () {
                      if (isCollected) {
                        provider.removeFromCollection(currentPrompt.id);
                      } else {
                        provider.addToCollection(currentPrompt.id);
                      }
                    },
                    icon: Icon(
                      isCollected ? Icons.bookmark : Icons.bookmark_add_outlined,
                      color: isCollected ? AppTheme.neonCyan : AppTheme.textSecondary,
                      size: 18,
                    ),
                    label: Text(
                      isCollected ? 'مضاف' : 'إضافة',
                      style: TextStyle(
                        color: isCollected ? AppTheme.neonCyan : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const Spacer(),

                  // زر النسخ
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: AppTheme.textSecondary, size: 18),
                    onPressed: () => _copyToClipboard(context),
                    tooltip: 'نسخ الأمر',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
