import 'package:better_auth_client/src/core/exceptions/app_exceptions.dart';
import 'package:better_auth_client/src/core/handlers/error-handler/models/better_auth_exception.dart';

import 'src/index.dart';

abstract class BaseErrorHandler {
  BetterAuthException handleError(AppException error, [StackTrace? stackTrace]);
}

class _ErrorFactory {
  static BaseErrorHandler getErrorHandler(AppException exception) {
    return switch (exception) {
      BadRequestException() ||
      UnauthorizedException() ||
      NotFoundException() ||
      InternalServerErrorException() => BetterAuthErrorHandler(),
      NetworkException() => NetworkIssueHandler(),
      UnknownException() || GenericException() => GenericErrorHandler(),
    };
  }
}

mixin ErrorHandler {
  BetterAuthException handleException(Object error, [StackTrace? stackTrace]) {
    if (error is! AppException) {
      return GenericErrorHandler().handleError(
        GenericException('_'),
        stackTrace,
      );
    }
    final errorHandler = _ErrorFactory.getErrorHandler(error);
    return errorHandler.handleError(error, stackTrace);
  }
}
