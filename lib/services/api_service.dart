import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prompt_model.dart';

class ApiService {
  static const String _baseUrl = 'https://6a03911d2afe8349b4b558c4.mockapi.io/prompt';
  static const String _cacheKey = 'cached_prompts';

  static Future<List<PromptModel>> fetchPrompts() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final prompts = data.map((e) => PromptModel.fromJson(e as Map<String, dynamic>)).toList();
        
        // حفظ نسخة محلية للعمل بدون إنترنت
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, response.body);
        
        return prompts;
      } else {
        // فشل الطلب، محاولة التحميل من الكاش
        final cachedData = await _loadFromCache();
        if (cachedData.isNotEmpty) return cachedData;
        throw Exception('Failed to load prompts from API');
      }
    } catch (e) {
      // خطأ في الشبكة أو أي خطأ آخر، محاولة التحميل من الكاش
      final cachedData = await _loadFromCache();
      if (cachedData.isNotEmpty) return cachedData;
      rethrow;
    }
  }

  static Future<List<PromptModel>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      
      if (jsonString != null) {
        final List data = jsonDecode(jsonString);
        return data.map((e) => PromptModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // خطأ في قراءة الكاش
    }
    return [];
  }

  static Future<void> updateFavoriteStatus(String id, bool isFavorite) async {
    // محاكاة المزامنة مع السيرفر
    // ملاحظة: بما أن MockAPI يتطلب معرف حقيقي، وفي حال استخدام العنوان كمعرف قد يفشل الطلب
    // ولكن سنقوم بتنفيذ الطلب برمجياً كما هو مطلوب
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        body: jsonEncode({'isFavorite': isFavorite}),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200 && response.statusCode != 204 && response.statusCode != 201) {
        throw Exception('Failed to update');
      }
    } catch (e) {
      rethrow;
    }
  }
}
