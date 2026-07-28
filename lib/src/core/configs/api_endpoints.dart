abstract class ApiEndpoints {
  static String prefix = '/api/auth';

  static String get signIn => '$prefix/sign-in/email';
  static String get signInSocial => '$prefix/sign-in/social';
  static String get signUp => '$prefix/sign-up/email';
  static String get resetPassword => '$prefix/reset-password';
  static String get sendVerificationEmail => '$prefix/send-verification-email';
  static String get forgetPassword => '$prefix/forget-password';

  // Anonymous Authentication
  static String get signInAnonymous => '$prefix/sign-in/anonymous';
}
