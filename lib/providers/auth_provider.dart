import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// مزوّد حالة المصادقة – يدير دورة حياة تسجيل الدخول والخروج
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Getters ──────────────────────────────────────────────────

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _firebaseUser != null;
  String? get currentUid => _firebaseUser?.uid;

  /// Stream لاستخدامه في StreamBuilder الجذر
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // ─── Internal Helpers ─────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// تحديث المستخدم الحالي داخلياً (يُستدعى من StreamBuilder في main)
  void updateUser(User? user) {
    _firebaseUser = user;
    if (user == null) {
      _userModel = null;
    }
    notifyListeners();
  }

  // ─── Sign Up ──────────────────────────────────────────────────

  /// إنشاء حساب جديد
  /// ملاحظة: حفظ بيانات Firestore هو best-effort ولا يوقف عملية التسجيل
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _setError(null);
    _setLoading(true);

    try {
      // الخطوة 1: التسجيل في Firebase Auth (الأساس)
      final credential = await _authService.signUp(
        email: email,
        password: password,
      );

      final user = credential.user!;
      _firebaseUser = user;

      // الخطوة 2: حفظ الملف الشخصي في Firestore (اختياري – لا يوقف التسجيل)
      try {
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? email,
          displayName: user.email?.split('@').first ?? 'مستخدم',
          createdAt: DateTime.now(),
        );
        await _firestoreService.saveUserProfile(userModel);
        _userModel = userModel;
      } catch (firestoreError) {
        // خطأ Firestore لا يلغي التسجيل الناجح
        debugPrint('⚠️ Firestore profile save skipped: $firestoreError');
      }

      _setLoading(false);
      return true; // التسجيل ناجح

    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      debugPrint('🔴 FirebaseAuthException [signUp]: ${e.code} — ${e.message}');
      _setError(AuthService.getArabicErrorMessage(e.code));
      return false;
    } on FirebaseException catch (e) {
      _setLoading(false);
      debugPrint('🔴 FirebaseException [signUp]: ${e.code} — ${e.message}');
      _setError(AuthService.getArabicErrorMessage(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      debugPrint('🔴 Unknown error [signUp]: $e');
      // عرض رسالة تفصيلية بدلاً من الرسالة الغامضة
      _setError('فشل إنشاء الحساب: ${e.toString().split('\n').first}');
      return false;
    }
  }

  // ─── Sign In ──────────────────────────────────────────────────

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setError(null);
    _setLoading(true);

    try {
      final credential = await _authService.signIn(
        email: email,
        password: password,
      );

      _firebaseUser = credential.user;
      _setLoading(false);
      return true;

    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      debugPrint('🔴 FirebaseAuthException [signIn]: ${e.code} — ${e.message}');
      _setError(AuthService.getArabicErrorMessage(e.code));
      return false;
    } on FirebaseException catch (e) {
      _setLoading(false);
      debugPrint('🔴 FirebaseException [signIn]: ${e.code} — ${e.message}');
      _setError(AuthService.getArabicErrorMessage(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      debugPrint('🔴 Unknown error [signIn]: $e');
      _setError('فشل تسجيل الدخول: ${e.toString().split('\n').first}');
      return false;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────

  /// تسجيل الخروج ومسح حالة المستخدم
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _firebaseUser = null;
      _userModel = null;
    } catch (_) {
      // تجاهل أخطاء تسجيل الخروج
    } finally {
      _setLoading(false);
    }
  }
}
