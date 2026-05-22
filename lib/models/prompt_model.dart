class PromptModel {
  final String id;
  final String title;
  final String description;
  final String fullPrompt;
  final String explanation;
  final String category;
  final List<String> tags;
  final String platform;
  final bool isFavorite;

  const PromptModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fullPrompt,
    required this.explanation,
    required this.category,
    required this.tags,
    required this.platform,
    this.isFavorite = false,
  });

  PromptModel copyWith({
    String? id,
    String? title,
    String? description,
    String? fullPrompt,
    String? explanation,
    String? category,
    List<String>? tags,
    String? platform,
    bool? isFavorite,
  }) {
    return PromptModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fullPrompt: fullPrompt ?? this.fullPrompt,
      explanation: explanation ?? this.explanation,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      platform: platform ?? this.platform,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory PromptModel.fromJson(Map<String, dynamic> json) {
    final titleStr = (json['title'] ?? '').toString().trim();
    final fullPromptStr = (json['fullPrompt'] ?? json['prompt'] ?? '').toString().trim();
    final fallbackId = titleStr.isNotEmpty ? titleStr : (fullPromptStr.isNotEmpty ? fullPromptStr : 'prompt_${DateTime.now().microsecondsSinceEpoch}');
    final idStr = json['id'] != null ? json['id'].toString() : fallbackId;

    String rawCat = (json['category'] ?? '').toString().trim();
    String mappedCat = rawCat;
    if (rawCat == 'برمجة') {
      mappedCat = 'البرمجة';
    } else if (rawCat == 'تسويق') {
      mappedCat = 'التسويق';
    } else if (rawCat == 'تصميم') {
      mappedCat = 'تصميم واجهات المستخدم';
    } else if (rawCat == 'يوتيوب') {
      mappedCat = 'نصوص الفيديو';
    } else if (rawCat == 'أعمال') {
      mappedCat = 'الأعمال';
    } else if (rawCat == 'سوشيال ميديا') {
      mappedCat = 'شبكات التواصل الاجتماعي';
    } else if (rawCat == 'تعليم') {
      mappedCat = 'الإنتاجية';
    }
    if (mappedCat.isEmpty) {
      mappedCat = 'عام';
    }

    final expStr = (json['explanation'] ?? '').toString().trim();
    final finalExp = expStr.isNotEmpty
        ? expStr
        : 'يوفر هذا التلقين الذكي إرشادات دقيقة وموجهة لنموذج الذكاء الاصطناعي لضمان استخراج مخرجات احترافية وعالية الجودة تتناسب مع أفضل المعايير والممارسات المعتمدة.';

    List<String> tagsList = [];
    if (json['tags'] != null && json['tags'] is List) {
      tagsList = List<String>.from(json['tags']);
    }
    if (tagsList.isEmpty) {
      if (mappedCat == 'البرمجة') {
        tagsList = ['فلاتر', 'تطوير', 'أكواد', 'برمجة'];
      } else if (mappedCat == 'التسويق') {
        tagsList = ['تسويق', 'سيو', 'مبيعات', 'محتوى'];
      } else if (mappedCat == 'تصميم واجهات المستخدم') {
        tagsList = ['تصميم', 'UI/UX', 'واجهات', 'ألوان'];
      } else if (mappedCat == 'نصوص الفيديو') {
        tagsList = ['يوتيوب', 'فيديو', 'سكربت', 'صناعة'];
      } else if (mappedCat == 'الأعمال') {
        tagsList = ['شركات', 'أعمال', 'استراتيجية', 'نجاح'];
      } else if (mappedCat == 'شبكات التواصل الاجتماعي') {
        tagsList = ['سوشيال', 'تيك توك', 'انتشار', 'تفاعل'];
      } else {
        tagsList = ['ذكاء اصطناعي', 'تلقين', 'أوامر', 'إبداع'];
      }
    }

    return PromptModel(
      id: idStr,
      title: titleStr,
      description: (json['description'] ?? '').toString().trim(),
      fullPrompt: fullPromptStr,
      explanation: finalExp,
      category: mappedCat,
      tags: tagsList,
      platform: (json['platform'] ?? 'ChatGPT').toString().trim(),
      isFavorite: json['isFavorite'] == true || json['isFavorite'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fullPrompt': fullPrompt,
      'explanation': explanation,
      'category': category,
      'tags': tags,
      'platform': platform,
      'isFavorite': isFavorite,
    };
  }
}
