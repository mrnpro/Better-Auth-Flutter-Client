import 'package:better_auth_client/better_auth_client.dart';

import '../core/types.dart';
import 'src/signin_client_impl.dart';

abstract class SigninClient {
  static SigninClient get getDefaultInstance => SignInClientImpl();

  Future<({BetterAuthException? error, User? user, bool? requiresTwoFactor})>
  email({
    required String email,
    required String password,
    Success<User>? onSuccess,
    Error<BetterAuthException>? onError,
  });

  Future<({BetterAuthException? error, User? user})> twoFactor({
    required String code,
    Success<User>? onSuccess,
    Error<BetterAuthException>? onError,
  });

  Future<({BetterAuthException? error, User? user})> anonymous({
    Success<User>? onSuccess,
    Error<BetterAuthException>? onError,
  });

  Future<({BetterAuthException? error, String? loginUrl, User? user})> social({
    required Providers provider,
    String? idToken,

    Success<User>? onSuccess,
    Error<BetterAuthException>? onError,
  });
}
