import 'dart:async';
import 'dart:developer' as dev;
import 'package:better_auth_client/src/core/handlers/error-handler/error_handler.dart';
import 'package:better_auth_client/src/core/handlers/error-handler/models/better_auth_exception.dart';
import 'package:better_auth_client/src/models/response/better_auth_http_response.dart';
import 'package:better_auth_client/src/service/local-storage-service/better_auth_local_storage_service.dart';
import 'package:better_auth_client/src/service/user-local-service/user_local_service.dart';
import 'package:better_auth_client/src/sign-in/src/signin_client_impl.dart';
import 'package:better_auth_client/src/sign-up/src/sign_up_client_impl.dart';
import 'core/configs/api_endpoints.dart';
import 'core/types.dart';
import 'models/response/user.dart';
import 'plugins/phone-auth/phone_auth_plugin.dart';
import 'plugins/two-factor/two_factor_client.dart';
import 'service/http-service/http_service.dart';
import 'sign-in/signin_client.dart';
import 'sign-up/signup_client.dart';

class BetterAuthClient with ErrorHandler {
  static BetterAuthClient get instance => BetterAuthClient._internal();
  static HttpService? _httpService;
  static SigninClient? _signinClient;
  static SignupClient? _signupClient;
  static UserLocalService? _userLocalService;
  BetterAuthClient._internal();

  static String? _baseUrl;
  static Future<BetterAuthClient> create({
    required String baseUrl,
    String prefix = '/api/auth',
    BetterAuthLocalStorage? localStorage,
  }) async {
    _baseUrl = baseUrl;
    ApiEndpoints.prefix = prefix;
    dev.log('--------------------------------');
    dev.log('Initializing better auth with base URL: $baseUrl');
    dev.log('--------------------------------');

    // Initialize HTTP service first
    HttpService.instance.init(baseUrl);

    _userLocalService = UserLocalServiceImpl(
      localStorageService:
          localStorage ?? BetterAuthLocalStorage.getDefaultInstance,
    );
    _signinClient = SignInClientImpl(
      httpService: HttpService.instance,
      localStorage: localStorage,
      userLocalService: _userLocalService,
    );
    _signupClient = SignUpClientImpl(
      httpService: HttpService.instance,
      localStorage: localStorage,
      userLocalService: _userLocalService,
    );

    dev.log('BetterAuth initialized successfully!');
    // Don't load user during initialization to avoid hanging the app
    // User will be loaded when needed by the auth wrapper
    // log('-------------Getting Current User-------------------');
    // final user = await BetterAuthClient._internal().getCurrentUser();
    // log(user?.toString() ?? 'No user found');
    // log('----------------------------------------------------');

    return instance;
  }

  bool _isInitialized() {
    final isInitialized = _baseUrl != null;

    return isInitialized;
  }

  void _throwUninitialized() {
    throw Exception('BetterAuthClient has not been created');
  }

  SigninClient get signIn {
    return _signinClient!;
  }

  SignupClient get signUp {
    if (!_isInitialized()) {
      _throwUninitialized();
    }
    return _signupClient!;
  }

  Stream<User?> get userChanges =>
      _userLocalService?.userChanges ?? Stream.empty();

  /// signout
  Future<void> signOut({Success? onSuccess, Error? onError}) async {
    final currentUser = await getCurrentUser();
    if (currentUser != null) {
      await _userLocalService?.deleteUser();
      dev.log('Signed out');
      onSuccess?.call(null);
    } else {
      final error = BetterAuthException(
        message: 'No user found',
        code: BetterAuthExceptionCode.noUserFound,
      );
      dev.log(error.message.toString());
      onError?.call(error);
    }
  }

  Future<void> forgetPassword({
    required String email,
    Success<BetterAuthHttpResponse>? onSuccess,
    Error? onError,
  }) async {
    try {
      final response = await _httpService?.postRequest(
        ApiEndpoints.forgetPassword,
        body: {'email': email},
      );

      dev.log('Password reset email sent');
      onSuccess?.call(response!);
      return;
    } catch (e) {
      // final error = BetterAuthException(
      //   message: e.toString(),
      //   code: BetterAuthExceptionCode,
      // );
      // log(error.message);
      // onError?.call(error);
      return;
    }
  }

  Future<void> sendVerificationEmail({
    required String email,
    String? callbackURL,
    Success<BetterAuthHttpResponse>? onSuccess,
    Error? onError,
  }) async {
    try {
      final response = await _httpService?.postRequest(
        ApiEndpoints.sendVerificationEmail,
        body: {
          'email': email,
          if (callbackURL != null) 'callbackURL': callbackURL,
        },
      );
      onSuccess?.call(response!);
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
    }
  }

  Future<void> resetPassword({
    required String newPassword,
    required String token,
    Success<BetterAuthHttpResponse>? onSuccess,
    Error? onError,
  }) async {
    try {
      final response = await _httpService?.postRequest(
        ApiEndpoints.resetPassword,
        body: {'newPassword': newPassword, 'token': token},
      );

      onSuccess?.call(response!);
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
    }
  }

  //////// Plugins ////////

  PhoneAuthPlugin get phoneNumber {
    if (!_isInitialized()) {
      _throwUninitialized();
    }
    return PhoneAuthPlugin.instance;
  }

  TwoFactorClient get twoFactor {
    if (!_isInitialized()) {
      _throwUninitialized();
    }
    return TwoFactorClientImpl();
  }

  /// get session
  Future<User?> getCurrentUser() async {
    return await _userLocalService?.getUser();
  }
}
