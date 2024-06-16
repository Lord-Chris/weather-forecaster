abstract class IAppException {
  final String title;
  final String message;
  final dynamic data;

  IAppException({
    this.title = 'Error',
    required this.message,
    this.data,
  });

  @override
  String toString() =>
      'IAppException(title: $title, message: $message, data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IAppException &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          message == other.message &&
          data == other.data;

  @override
  int get hashCode => title.hashCode ^ message.hashCode ^ data.hashCode;
}

class AppException extends IAppException {
  AppException({
    required super.message,
    super.data,
  });

  factory AppException.fromHttpErrorMap(Map<String, dynamic> json) =>
      AppException(
        message: json['message'] ??
            json['errors']?['Message'] ??
            json['error'] ??
            'An error occurred',
        data: json,
      );
}

/// This is not to be used freely, it should be used as a fallback for errors
/// that need to be handled, especially for the API service where we don't know
/// all the errors beforehand.
class FallbackAppException extends IAppException {
  FallbackAppException({
    super.data,
    super.message =
        "Oops! App encountered an issue. We're on it. Please try again later or contact us.",
  });
}

/// Errors that come from API calls that return error codes 500 and above
class InternetAppException extends IAppException {
  InternetAppException({
    super.title = 'Internet Connection Error',
    super.data,
    super.message = 'Please check your internet connection and try again.',
  });
}

/// Errors that come from API calls that return error codes 500 and above
class ServerAppException extends IAppException {
  ServerAppException({
    super.title = 'Server Error',
    super.data,
    super.message =
        "Sorry, we're having trouble on our end. Please try again later or contact support for assistance.",
  });
}

/// Errors that come from serializing data
class ObjectParserAppException extends IAppException {
  final StackTrace? stackTrace;
  ObjectParserAppException({
    super.title = 'Serialization Error',
    super.message = 'An error occurred while parsing data. Please try again.',
    super.data,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'ObjectParserAppException(title: $title, message: $message, data: $data, stackTrace: $stackTrace)';
  }
}

/// Errors concerning device access, eg. camera, location, etc.
class DeviceAppException extends IAppException {
  DeviceAppException({
    super.title = 'Device Query Error',
    super.message =
        'An error occurred while accessing data from the device. Please try again.',
    super.data,
  });
}

/// Errors concerning unauthorized access, eg. invalid token, etc.
class UnauthorizedAppException extends IAppException {
  UnauthorizedAppException({
    super.title = 'Unauthorized',
    super.message =
        'You are not authorized to perform this action. Please login.',
    super.data,
  });
}
