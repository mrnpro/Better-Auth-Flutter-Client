import 'package:better_auth_client/src/plugins/phone-auth/src/phone_number_auth_plugin_impl.dart';

import '../../core/types.dart';

abstract class PhoneAuthPlugin {
  static PhoneAuthPlugin get instance => PhoneNumberAuthPluginImpl();

  Future<void> sendOtp({
    required String phone,
    Success? onSuccess,
    Error? onError,
  });

  Future<void> verify({
    required String phone,
    required String otp,
    bool updatePhoneNumber = false,
    bool disableSession = true,
    Success? onSuccess,
    Error? onError,
  });

  Future<void> forgetPassword({
    required String phone,
    Success? onSuccess,
    Error? onError,
  });

  resetPassword({
    required String otp,
    required String phoneNumber,
    required String newPassword,
    Success? onSuccess,
    Error? onError,
  });
}
