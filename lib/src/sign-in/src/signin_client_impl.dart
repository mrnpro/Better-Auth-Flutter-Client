import 'dart:developer' as dev;
import 'package:better_auth_client/src/core/configs/api_endpoints.dart';
import 'package:better_auth_client/src/plugins/two-factor/two_factor_endpoints.dart';
import 'package:better_auth_client/src/core/configs/enums/providers.dart';
import 'package:better_auth_client/src/core/handlers/error-handler/models/better_auth_exception.dart';
import 'package:better_auth_client/src/core/types.dart';
import 'package:better_auth_client/src/models/response/user.dart';
import 'package:better_auth_client/src/service/http-service/http_service.dart';
import 'package:better_auth_client/src/service/user-local-service/user_local_service.dart';
import 'package:better_auth_client/src/sign-in/signin_client.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/handlers/error-handler/error_handler.dart';
import '../../service/local-storage-service/better_auth_local_storage_service.dart';

class SignInClientImpl with ErrorHandler implements SigninClient {
  SignInClientImpl({
    HttpService? httpService,
    BetterAuthLocalStorage? localStorage,
    UserLocalService? userLocalService,
  }) : _httpService = httpService ?? HttpService.instance,
       _userLocalService =
           userLocalService ??
           UserLocalServiceImpl(localStorageService: localStorage!);
  final HttpService _httpService;
  final UserLocalService _userLocalService;
  @override
  Future<({BetterAuthException? error, User? user})> anonymous({
    Success<User>? onSuccess,
    Error<BetterAuthException>? onError,
  }) async {
    try {
      final response = await _httpService.postRequest(
        ApiEndpoints.signInAnonymous,
      );

      final user = User.fromJson(response.body['data']['user']);
      await _userLocalService.setUser(user);

      dev.log('Anonymous sign-in successful: ${user.id}');
      onSuccess?.call(user);

      return (error: null, user: user);
    } catch (e) {
      dev.log('Anonymous sign-in failed: $e');
      final error = handleException(e);
      onError?.call(error);
      return (error: error, user: null);
    }
  }

  @override
  Future<({BetterAuthException? error, User? user, bool? requiresTwoFactor})>
  email({
    required String email,
    required String password,
    Success<User>? onSuccess,
    Error<BetterAuthException>? onError,
  }) async {
    try {
      final url = ApiEndpoints.signIn;
      final response = await _httpService.postRequest(
        url,
        body: {'email': email, 'password': password},
      );

      // Check if 2FA is required
      final requiresTwoFactor =
          response.body['data']?['requiresTwoFactor'] as bool? ?? false;

      if (requiresTwoFactor) {
        // Return partial user data and 2FA requirement flag
        final userData = response.body['data']['user'];
        final user = User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          emailVerified: userData['emailVerified'],
          createdAt: DateTime.parse(userData['createdAt']),
          updatedAt: DateTime.parse(userData['updatedAt']),
        );
        return (error: null, user: user, requiresTwoFactor: true);
      } else {
        // Normal sign-in without 2FA
        final user = User.fromJson(response.body);
        await _userLocalService.setUser(user);
        onSuccess?.call(user);
        return (error: null, user: user, requiresTwoFactor: false);
      }
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
      return (error: error, user: null, requiresTwoFactor: null);
    }
  }

  @override
  Future<({BetterAuthException? error, User? user})> twoFactor({
    required String code,
    Success<User>? onSuccess,
    Error<BetterAuthException>? onError,
  }) async {
    try {
      final response = await _httpService.postRequest(
        TwoFactorEndpoints.signInTwoFactor,
        body: {'code': code},
      );

      final user = User.fromJson(response.body);
      await _userLocalService.setUser(user);
      onSuccess?.call(user);

      return (error: null, user: user);
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
      return (error: error, user: null);
    }
  }

  @override
  Future<({BetterAuthException? error, String? loginUrl})> social({
    required Providers provider,
    Map<String, dynamic>? idToken,
    Success<User>? onSuccess,
    Error<BetterAuthException>? onError,
  }) async {
    try {
      final res = await _httpService.postRequest(
        ApiEndpoints.signInSocial,
        body: {"provider": provider.name},
      );

      final {"url": String loginUrl, "redirect": redirect} = res.body;
      launchUrl(Uri.parse(loginUrl));
      return (error: null, loginUrl: loginUrl);
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
      return (error: error, loginUrl: null);
    }
  }
}
