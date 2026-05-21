import 'two_factor_endpoints.dart';
import 'package:better_auth_client/src/core/handlers/error-handler/error_handler.dart';
import 'package:better_auth_client/src/core/handlers/error-handler/models/better_auth_exception.dart';
import 'package:better_auth_client/src/core/types.dart';
import 'package:better_auth_client/src/service/http-service/http_service.dart';

/// Two-Factor Authentication (2FA) client for Better Auth
abstract class TwoFactorClient {
  /// Generate a 2FA secret and QR code for enabling 2FA
  Future<({BetterAuthException? error, TwoFactorSetupData? data})> generate({
    Success<TwoFactorSetupData>? onSuccess,
    Error<BetterAuthException>? onError,
  });

  /// Enable 2FA by verifying the code from authenticator app
  Future<({BetterAuthException? error, TwoFactorEnableResponse? data})> enable({
    required String code,
    Success<TwoFactorEnableResponse>? onSuccess,
    Error<BetterAuthException>? onError,
  });

  /// Verify a 2FA code (used during sign-in)
  Future<({BetterAuthException? error, bool? verified})> verify({
    required String code,
    Success<bool>? onSuccess,
    Error<BetterAuthException>? onError,
  });

  /// Disable 2FA for the current user
  Future<({BetterAuthException? error, bool? disabled})> disable({
    required String code,
    Success<bool>? onSuccess,
    Error<BetterAuthException>? onError,
  });

  /// Check if 2FA is enabled for the current user
  Future<({BetterAuthException? error, bool? enabled})> status({
    Success<bool>? onSuccess,
    Error<BetterAuthException>? onError,
  });
}

/// Data returned when setting up 2FA
class TwoFactorSetupData {
  final String secret;
  final String qrCodeUrl;
  final String backupCodes;

  TwoFactorSetupData({
    required this.secret,
    required this.qrCodeUrl,
    required this.backupCodes,
  });

  factory TwoFactorSetupData.fromJson(Map<String, dynamic> json) {
    return TwoFactorSetupData(
      secret: json['secret'] as String,
      qrCodeUrl: json['qrCodeUrl'] as String,
      backupCodes: json['backupCodes'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'secret': secret,
      'qrCodeUrl': qrCodeUrl,
      'backupCodes': backupCodes,
    };
  }
}

/// Response when enabling 2FA
class TwoFactorEnableResponse {
  final bool enabled;
  final String backupCodes;

  TwoFactorEnableResponse({required this.enabled, required this.backupCodes});

  factory TwoFactorEnableResponse.fromJson(Map<String, dynamic> json) {
    return TwoFactorEnableResponse(
      enabled: json['enabled'] as bool,
      backupCodes: json['backupCodes'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'enabled': enabled, 'backupCodes': backupCodes};
  }
}

/// Implementation of Two-Factor Authentication client
class TwoFactorClientImpl with ErrorHandler implements TwoFactorClient {
  final HttpService _httpService;

  TwoFactorClientImpl({HttpService? httpService})
    : _httpService = httpService ?? HttpService.instance;

  @override
  Future<({BetterAuthException? error, TwoFactorSetupData? data})> generate({
    Success<TwoFactorSetupData>? onSuccess,
    Error<BetterAuthException>? onError,
  }) async {
    try {
      final response = await _httpService.postRequest(
        TwoFactorEndpoints.generate,
      );

      final setupData = TwoFactorSetupData.fromJson(response.body['data']);
      onSuccess?.call(setupData);

      return (error: null, data: setupData);
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
      return (error: error, data: null);
    }
  }

  @override
  Future<({BetterAuthException? error, TwoFactorEnableResponse? data})> enable({
    required String code,
    Success<TwoFactorEnableResponse>? onSuccess,
    Error<BetterAuthException>? onError,
  }) async {
    try {
      final response = await _httpService.postRequest(
        TwoFactorEndpoints.enable,
        body: {'code': code},
      );

      final enableResponse = TwoFactorEnableResponse.fromJson(
        response.body['data'],
      );
      onSuccess?.call(enableResponse);

      return (error: null, data: enableResponse);
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
      return (error: error, data: null);
    }
  }

  @override
  Future<({BetterAuthException? error, bool? verified})> verify({
    required String code,
    Success<bool>? onSuccess,
    Error<BetterAuthException>? onError,
  }) async {
    try {
      final response = await _httpService.postRequest(
        TwoFactorEndpoints.verify,
        body: {'code': code},
      );

      final verified = response.body['data']['verified'] as bool;
      onSuccess?.call(verified);

      return (error: null, verified: verified);
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
      return (error: error, verified: null);
    }
  }

  @override
  Future<({BetterAuthException? error, bool? disabled})> disable({
    required String code,
    Success<bool>? onSuccess,
    Error<BetterAuthException>? onError,
  }) async {
    try {
      final response = await _httpService.postRequest(
        TwoFactorEndpoints.disable,
        body: {'code': code},
      );

      final disabled = response.body['data']['disabled'] as bool;
      onSuccess?.call(disabled);

      return (error: null, disabled: disabled);
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
      return (error: error, disabled: null);
    }
  }

  @override
  Future<({BetterAuthException? error, bool? enabled})> status({
    Success<bool>? onSuccess,
    Error<BetterAuthException>? onError,
  }) async {
    try {
      final response = await _httpService.getRequest(TwoFactorEndpoints.status);

      final enabled = response.body['data']['enabled'] as bool;
      onSuccess?.call(enabled);

      return (error: null, enabled: enabled);
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
      return (error: error, enabled: null);
    }
  }
}
