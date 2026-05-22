import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/prompt_provider.dart';
import '../utils/theme.dart';
import '../widgets/platform_badge.dart';
import '../screens/prompt_details_screen.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  void _exportCollection(BuildContext context, PromptProvider provider) {
    if (provider.collectionPrompts.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln('# مجموعتي في PromptVault');
    buffer.writeln('تاريخ التصدير: ${DateTime.now().toString().split('.').first}\n');

    for (final p in provider.collectionPrompts) {
      buffer.writeln('## ${p.title}');
      buffer.writeln('**القسم**: ${p.category} | **المنصة**: ${p.platform}\n');
      buffer.writeln('```');
      buffer.writeln(p.fullPrompt);
      buffer.writeln('```\n---\n');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تصدير المجموعة بالكامل إلى الحافظة بتنسيق Markdown!'),
        backgroundColor: AppTheme.neonCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PromptProvider>();
    final groupedCollection = provider.collectionGroupedByCategory;
    final totalCount = provider.collectionCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مجموعتي'),
        actions: [
          if (totalCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.neonPink),
              tooltip: 'مسح المجموعة',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppTheme.surface,
                    title: const Text('مسح المجموعة؟'),
                    content: const Text('هل أنت متأكد من رغبتك في إزالة كافة الأوامر من مجموعتك؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء', style: TextStyle(color: AppTheme.textSecondary)),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.clearCollection();
                          Navigator.pop(context);
                        },
                        child: const Text('مسح الكل', style: TextStyle(color: AppTheme.neonPink)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: totalCount == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 72, color: AppTheme.neonCyan.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text(
                    'مجموعتك فارغة حالياً',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'تصفح الأوامر واضغط على "إضافة" لبناء مساحة التجميع والأوامر الخاصة بك.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // الشريط العلوي الملخص
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border(bottom: BorderSide(color: AppTheme.surfaceHighlight.withValues(alpha: 0.5))),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إجمالي الأوامر',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalCount أمر',
                            style: const TextStyle(
                              color: AppTheme.neonCyan,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _exportCollection(context, provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonCyan,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        icon: const Icon(Icons.copy_all_rounded, size: 18),
                        label: const Text('تصدير الكل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ),

                // القائمة المجمعة
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: groupedCollection.keys.length,
                    itemBuilder: (context, sectionIndex) {
                      final category = groupedCollection.keys.elementAt(sectionIndex);
                      final items = groupedCollection[category]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // عنوان القسم
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              children: [
                                const Icon(Icons.folder_special, size: 16, color: AppTheme.neonViolet),
                                const SizedBox(width: 8),
                                Text(
                                  category,
                                  style: const TextStyle(
                                    color: AppTheme.neonViolet,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${items.length}',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                          // عناصر القسم
                          ...items.map((prompt) {
                            return Dismissible(
                              key: Key(prompt.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerLeft, // ليتوافق مع السحب في الاتجاه العربي
                                padding: const EdgeInsets.only(left: 20),
                                color: AppTheme.neonPink.withValues(alpha: 0.8),
                                child: const Icon(Icons.delete_outline, color: Colors.white),
                              ),
                              onDismissed: (_) {
                                provider.removeFromCollection(prompt.id);
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PromptDetailsScreen(promptId: prompt.id),
                                    ),
                                  );
                                },
                                title: Text(
                                  prompt.title,
                                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    prompt.description,
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PlatformBadge(platform: prompt.platform),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: AppTheme.textSecondary, size: 20),
                                      onPressed: () => provider.removeFromCollection(prompt.id),
                                      tooltip: 'إزالة من المجموعة',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          
                          // فاصل القسم
                          Divider(color: AppTheme.surfaceHighlight.withValues(alpha: 0.2), height: 16),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
