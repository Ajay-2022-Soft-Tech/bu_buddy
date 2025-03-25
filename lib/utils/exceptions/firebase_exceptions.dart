
class TFirebaseException implements Exception {
  /// The error code associated with the exception.
  final String code;

  /// Constructor that takes an error code.
  TFirebaseException(this.code);

  /// Get the corresponding error message based on the error code.
  String get message {
    switch (code) {
      case 'invalid-custom-token':
        return 'The custom token format is incorrect. Please check your custom token.';
      case 'custom-token-mismatch':
        return 'The provided custom token does not match the expected audience.';
      case 'invalid-email':
        return 'The email address provided is invalid. Please enter a valid email.';
      case 'user-not-found':
        return 'No user found for the given email or UID.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'provider-already-linked':
        return 'The account is already linked with another provider.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Contact support for assistance.';
      case 'invalid-credential':
        return 'The supplied credential is malformed or has expired.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please enter a valid code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please request a new verification code.';
      case 'captcha-check-failed':
        return 'The reCAPTCHA response is invalid. Please try again.';
      case 'app-not-authorized':
        return 'The app is not authorized to use Firebase Authentication with the provided API key.';
      case 'keychain-error':
        return 'A Keychain error occurred. Please check the keychain and try again.';
      case 'internal-error':
        return 'An internal authentication error occurred. Please try again later.';
      case 'invalid-app-credential':
        return 'The app credential is invalid. Please verify your app configuration.';
      default:
        return 'An unexpected Firebase error occurred. Please try again later.';
    }
  }
}
