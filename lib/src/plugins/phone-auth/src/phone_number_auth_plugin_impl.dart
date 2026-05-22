import 'package:better_auth_client/src/core/handlers/error-handler/error_handler.dart';
import 'package:better_auth_client/src/core/types.dart';
import 'package:better_auth_client/src/plugins/phone-auth/phone_auth_plugin.dart';
import '../../../core/configs/api_endpoints.dart';
import '../../../service/http-service/http_service.dart';

class PhoneNumberAuthPluginImpl with ErrorHandler implements PhoneAuthPlugin {
  final HttpService _httpService;

  PhoneNumberAuthPluginImpl({HttpService? httpService})
    : _httpService = httpService ?? HttpService.instance;

  @override
  Future<void> sendOtp({
    required String phone,
    Success? onSuccess,
    Error? onError,
  }) async {
    try {
      final response = await _httpService.postRequest(
        ApiEndpoints.phoneSendOtp,
        body: {'phone': phone},
      );

      onSuccess?.call(response.body);
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
    }
  }

  @override
  Future<void> verify({
    required String phone,
    required String otp,
    Map<String, dynamic>? options,
    bool updatePhoneNumber = false,
    bool disableSession = true,
    Success? onSuccess,
    Error? onError,
  }) async {
    try {
      final response = await _httpService.postRequest(
        ApiEndpoints.phoneVerifyOtp,
        body: {
          'phone': phone,
          'otp': otp,
          'updatePhoneNumber': updatePhoneNumber,
          'disableSession': disableSession,
        },
      );

      onSuccess?.call(response.body);
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
    }
  }

  @override
  Future<void> forgetPassword({
    required String phone,
    Success? onSuccess,
    Error? onError,
  }) async {
    try {
      final response = await _httpService.postRequest(
        ApiEndpoints.phoneForgetPassword,
        body: {'phone': phone},
      );

      onSuccess?.call(response.body);
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
    }
  }

  @override
  Future<void> resetPassword({
    required String otp,
    required String phoneNumber,
    required String newPassword,
    Success? onSuccess,
    Error? onError,
  }) async {
    try {
      final response = await _httpService.postRequest(
        ApiEndpoints.phoneResetPassword,
        body: {
          'otp': otp,
          'phoneNumber': phoneNumber,
          'newPassword': newPassword,
        },
      );

      onSuccess?.call(response.body);
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
    }
  }
}
