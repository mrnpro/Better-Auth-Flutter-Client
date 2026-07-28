import 'package:better_auth_client/src/core/configs/api_endpoints.dart';

abstract class TwoFactorEndpoints {
  static String get signInTwoFactor =>
      '${ApiEndpoints.prefix}/sign-in/two-factor';
  static String get generate => '${ApiEndpoints.prefix}/two-factor/generate';
  static String get enable => '${ApiEndpoints.prefix}/two-factor/enable';
  static String get verify => '${ApiEndpoints.prefix}/two-factor/verify';
  static String get disable => '${ApiEndpoints.prefix}/two-factor/disable';
  static String get status => '${ApiEndpoints.prefix}/two-factor/status';
}
