import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prompt_model.dart';
import '../services/api_service.dart';
import '../data/dummy_prompts.dart';

class PromptProvider extends ChangeNotifier {
  // All prompts
  List<PromptModel> _prompts = [];

  // IDs of prompts added to collection
  final Set<String> _collectionIds = {};

  // Search query
  String _searchQuery = '';

  // Selected category filter (null or empty means all categories)
  String? _selectedCategory;

  static const String _favoritesKey = 'favorite_ids';
  static const String _collectionKey = 'collection_ids';
  static const String _pendingSyncKey = 'pending_sync_ids';
  
  bool _isInitializedFromApi = false;
  final Set<String> _pendingSyncIds = {};

  PromptProvider() {
    // Initialize with dummy data
    _prompts = List.from(dummyPrompts);
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load Favorites
      final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
      bool changed = false;
      for (var i = 0; i < _prompts.length; i++) {
        final isFav = favoriteIds.contains(_prompts[i].id);
        if (_prompts[i].isFavorite != isFav) {
          _prompts[i] = _prompts[i].copyWith(isFavorite: isFav);
          changed = true;
        }
      }

      // Load Collection
      final collectionIdsList = prefs.getStringList(_collectionKey) ?? [];
      if (collectionIdsList.isNotEmpty) {
        _collectionIds.clear();
        _collectionIds.addAll(collectionIdsList);
        changed = true;
      }

      // Load Pending Sync
      final pendingList = prefs.getStringList(_pendingSyncKey) ?? [];
      if (pendingList.isNotEmpty) {
        _pendingSyncIds.clear();
        _pendingSyncIds.addAll(pendingList);
        changed = true;
      }
      
      if (changed) notifyListeners();
    } catch (e) {
      // Error loading data
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save Favorites
      final favoriteIds = _prompts.where((p) => p.isFavorite).map((p) => p.id).toList();
      await prefs.setStringList(_favoritesKey, favoriteIds);

      // Save Collection
      await prefs.setStringList(_collectionKey, _collectionIds.toList());

      // Save Pending Sync
      await prefs.setStringList(_pendingSyncKey, _pendingSyncIds.toList());
    } catch (e) {
      // Error saving data
    }
  }

  // Getters
  List<PromptModel> get allPrompts => _prompts;

  bool get isInitializedFromApi => _isInitializedFromApi;

  Set<String> get collectionIds => _collectionIds;

  String get searchQuery => _searchQuery;

  String? get selectedCategory => _selectedCategory;

  // Filtered prompts based on search query and selected category
  List<PromptModel> get filteredPrompts {
    return _prompts.where((prompt) {
      final matchesCategory = _selectedCategory == null ||
          _selectedCategory!.isEmpty ||
          prompt.category.toLowerCase() == _selectedCategory!.toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          prompt.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prompt.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prompt.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prompt.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Favorite prompts
  List<PromptModel> get favoritePrompts {
    return _prompts.where((p) => p.isFavorite).toList();
  }

  // Collected prompts
  List<PromptModel> get collectionPrompts {
    return _prompts.where((p) => _collectionIds.contains(p.id)).toList();
  }

  // Live collection count badge getter
  int get collectionCount => _collectionIds.length;

  // Actions

  void setPrompts(List<PromptModel> prompts) {
    _prompts = prompts;
    _isInitializedFromApi = true;
    _loadFromStorage(); // تطبيق المفضلات والمجموعات المحفوظة على البيانات الجديدة
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _prompts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final prompt = _prompts[index];
      _prompts[index] = prompt.copyWith(isFavorite: !prompt.isFavorite);
      
      // إضافة إلى قائمة المزامنة المعلقة
      _pendingSyncIds.add(id);
      
      _saveToStorage();
      notifyListeners();
      
      // محاولة المزامنة الفورية إذا وجد إنترنت
      _trySyncPrompt(id, _prompts[index].isFavorite);
    }
  }

  Future<void> _trySyncPrompt(String id, bool isFav) async {
    try {
      await ApiService.updateFavoriteStatus(id, isFav);
      _pendingSyncIds.remove(id);
      _saveToStorage();
      // لا نحتاج لـ notifyListeners هنا لأن الحالة المحلية صحيحة بالفعل
    } catch (e) {
      // فشل المزامنة (ربما لا يوجد إنترنت)، ستبقى في القائمة للمحاولة لاحقاً
    }
  }

  Future<void> syncPendingActions() async {
    if (_pendingSyncIds.isEmpty) return;
    
    final idsToSync = List<String>.from(_pendingSyncIds);
    bool anySuccess = false;
    
    for (final id in idsToSync) {
      final promptIndex = _prompts.indexWhere((p) => p.id == id);
      if (promptIndex != -1) {
        try {
          await ApiService.updateFavoriteStatus(id, _prompts[promptIndex].isFavorite);
          _pendingSyncIds.remove(id);
          anySuccess = true;
        } catch (e) {
          // تخطي إذا فشل والاحتفاظ به للمرة القادمة
        }
      }
    }
    
    if (anySuccess) {
      _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    try {
      final prompts = await ApiService.fetchPrompts();
      setPrompts(prompts);
      await syncPendingActions();
    } catch (e) {
      // في حال الخطأ نكتفي بما هو موجود محلياً
    }
  }

  void addToCollection(String id) {
    if (!_collectionIds.contains(id)) {
      _collectionIds.add(id);
      _saveToStorage();
      notifyListeners();
    }
  }

  void removeFromCollection(String id) {
    if (_collectionIds.contains(id)) {
      _collectionIds.remove(id);
      _saveToStorage();
      notifyListeners();
    }
  }

  void clearCollection() {
    if (_collectionIds.isNotEmpty) {
      _collectionIds.clear();
      _saveToStorage();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  // Helper to get prompts strictly for a specific category regardless of general search filters
  List<PromptModel> getPromptsForCategory(String category) {
    return _prompts.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
  }

  // Helper to group collection items by category
  Map<String, List<PromptModel>> get collectionGroupedByCategory {
    final map = <String, List<PromptModel>>{};
    for (final p in collectionPrompts) {
      map.putIfAbsent(p.category, () => []).add(p);
    }
    return map;
  }
}
