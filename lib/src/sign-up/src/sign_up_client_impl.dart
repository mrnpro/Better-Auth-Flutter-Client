import 'package:better_auth_client/src/core/configs/api_endpoints.dart';
import 'package:better_auth_client/src/core/handlers/error-handler/error_handler.dart';
import 'package:better_auth_client/src/core/handlers/error-handler/models/better_auth_exception.dart';
import 'package:better_auth_client/src/core/types.dart';
import 'package:better_auth_client/src/models/response/user.dart';
import 'package:better_auth_client/src/service/http-service/http_service.dart';
import 'package:better_auth_client/src/service/local-storage-service/better_auth_local_storage_service.dart';
import 'package:better_auth_client/src/service/user-local-service/user_local_service.dart';

import '../signup_client.dart';

class SignUpClientImpl with ErrorHandler implements SignupClient {
  SignUpClientImpl({
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
  Future<({BetterAuthException? error, User? user})> email({
    required String email,
    required String password,
    String? name,
    String? image,
    String? callbackUrl,
    Map<String, dynamic>? data,
    Success<User>? onSuccess,
    Error<BetterAuthException>? onError,
  }) async {
    try {
      final response = await _httpService.postRequest(
        ApiEndpoints.signUp,
        body: {
          'email': email,
          'password': password,
          if (name != null) 'name': name,
          if (image != null) 'image': image,
          if (callbackUrl != null) 'callbackUrl': callbackUrl,
          if (data != null) ...data,
        },
      );
      final userJson = response.body;
      final user = User.fromJson(userJson);
      await _userLocalService.setUser(user);
      onSuccess?.call(user);

      return (error: null, user: user);
    } catch (e) {
      final error = handleException(e);
      onError?.call(error);
      return (error: error, user: null);
    }
  }
}
