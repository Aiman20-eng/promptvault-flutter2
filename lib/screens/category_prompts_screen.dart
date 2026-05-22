import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prompt_provider.dart';
import '../utils/theme.dart';
import '../widgets/prompt_card.dart';
import '../widgets/responsive_layout.dart';

class CategoryPromptsScreen extends StatelessWidget {
  final String category;

  const CategoryPromptsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PromptProvider>();
    final prompts = provider.getPromptsForCategory(category);
    final crossAxisCount = ResponsiveLayout.getGridCrossAxisCount(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: prompts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_mosaic_rounded, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد أوامر في قسم $category',
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'عد لاحقاً للاطلاع على التحديثات والأوامر المميزة',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisExtent: 210,
              ),
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                return PromptCard(prompt: prompts[index]);
              },
            ),
    );
  }
}
