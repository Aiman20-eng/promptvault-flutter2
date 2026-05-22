import 'package:firebase_auth/firebase_auth.dart';

/// خدمة المصادقة – تغليف كامل لـ FirebaseAuth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Streams ──────────────────────────────────────────────────

  /// Stream يتتبع حالة المصادقة في الوقت الفعلي
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Getters ──────────────────────────────────────────────────

  /// المستخدم الحالي (null إذا لم يكن مسجّلاً)
  User? get currentUser => _auth.currentUser;

  // ─── Authentication Methods ───────────────────────────────────

  /// تسجيل مستخدم جديد بالبريد الإلكتروني وكلمة المرور
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─── Arabic Error Mapper ──────────────────────────────────────

  /// تحويل رموز أخطاء Firebase إلى رسائل عربية واضحة
  static String getArabicErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لا يوجد حساب مسجّل بهذا البريد الإلكتروني.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة، يرجى المحاولة مجدداً.';
      case 'invalid-credential':
        return 'بيانات الدخول غير صحيحة. تحقق من البريد وكلمة المرور.';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مسجّل مسبقاً. حاول تسجيل الدخول.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً. استخدم 6 أحرف على الأقل.';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة.';
      case 'network-request-failed':
        return 'تعذّر الاتصال بالشبكة. تحقق من اتصالك بالإنترنت.';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات المسموح بها. انتظر قليلاً وأعد المحاولة.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب. تواصل مع الدعم.';
      case 'operation-not-allowed':
        return 'هذه العملية غير مسموح بها حالياً.';
      default:
        return 'حدث خطأ غير متوقع. يرجى المحاولة مجدداً.';
    }
  }
}
