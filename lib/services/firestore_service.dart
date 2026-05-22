import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/prompt_model.dart';

/// خدمة Firestore – تغليف كامل لعمليات قاعدة البيانات
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Collections References ───────────────────────────────────

  CollectionReference get _usersCol => _db.collection('users');
  CollectionReference get _promptsCol => _db.collection('prompts');

  CollectionReference _favoritesCol(String uid) =>
      _usersCol.doc(uid).collection('favorites');

  // ─── User Profile ─────────────────────────────────────────────

  /// حفظ/تحديث بيانات المستخدم في Firestore عند التسجيل أول مرة
  Future<void> saveUserProfile(UserModel user) async {
    await _usersCol.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  /// الحصول على بيانات المستخدم كـ Stream للتحديثات الفورية
  Stream<UserModel?> getUserStream(String uid) {
    return _usersCol.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // ─── Prompts Collection ───────────────────────────────────────

  /// قراءة الأوامر المحفوظة في Firestore كـ Stream فوري
  Stream<List<PromptModel>> getPromptsStream() {
    return _promptsCol.snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PromptModel.fromJson(data);
      }).toList();
    });
  }

  /// إضافة أمر جديد إلى مجموعة prompts
  Future<void> addPrompt(PromptModel prompt) async {
    await _promptsCol.add(prompt.toJson());
  }

  /// تحديث أمر موجود في Firestore
  Future<void> updatePrompt(String docId, Map<String, dynamic> data) async {
    await _promptsCol.doc(docId).update(data);
  }

  /// حذف أمر من Firestore
  Future<void> deletePrompt(String docId) async {
    await _promptsCol.doc(docId).delete();
  }

  // ─── Favorites ────────────────────────────────────────────────

  /// قراءة مفضلات المستخدم كـ Stream فوري (realtime)
  Stream<List<String>> getFavoritesStream(String uid) {
    return _favoritesCol(uid).snapshots().map((snap) {
      return snap.docs.map((doc) => doc.id).toList();
    });
  }

  /// إضافة أمر إلى مفضلات المستخدم
  Future<void> addFavorite(String uid, String promptId) async {
    await _favoritesCol(uid).doc(promptId).set({
      'promptId': promptId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// حذف أمر من مفضلات المستخدم
  Future<void> removeFavorite(String uid, String promptId) async {
    await _favoritesCol(uid).doc(promptId).delete();
  }

  /// التحقق من كون أمر مفضلاً مرة واحدة (one-time read)
  Future<bool> isFavorite(String uid, String promptId) async {
    final doc = await _favoritesCol(uid).doc(promptId).get();
    return doc.exists;
  }
}
