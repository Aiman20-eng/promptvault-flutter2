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

  /// إنشاء حساب جديد وحفظ بيانات المستخدم في Firestore
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _setError(null);
    _setLoading(true);

    try {
      final credential = await _authService.signUp(
        email: email,
        password: password,
      );

      final user = credential.user!;
      _firebaseUser = user;

      // حفظ بيانات المستخدم في Firestore
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? email,
        displayName: user.email?.split('@').first ?? 'مستخدم',
        createdAt: DateTime.now(),
      );
      await _firestoreService.saveUserProfile(userModel);
      _userModel = userModel;

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(AuthService.getArabicErrorMessage(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('حدث خطأ غير متوقع. يرجى المحاولة مجدداً.');
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
      _setError(AuthService.getArabicErrorMessage(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('حدث خطأ غير متوقع. يرجى المحاولة مجدداً.');
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
