import 'package:better_auth_client/src/core/configs/api_endpoints.dart';

abstract class PhoneAuthEndpoints {
  static String get sendOtp => '${ApiEndpoints.prefix}/phone/send-otp';
  static String get verifyOtp => '${ApiEndpoints.prefix}/phone/verify-otp';
  static String get forgetPassword =>
      '${ApiEndpoints.prefix}/phone/forget-password';
  static String get resetPassword =>
      '${ApiEndpoints.prefix}/phone/reset-password';
}
