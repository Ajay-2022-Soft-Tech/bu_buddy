

class TFirebaseAuthException implements Exception {
  /// The error code associated with the exception.
  final String code;

  /// Constructor that takes an error code.
  TFirebaseAuthException(this.code);

  /// Get the corresponding error message based on the error code.
  String get message {
    switch (code) {
      case 'email-already-in-use':
        return 'The email address is already registered. Please use a different email.';
      case 'invalid-email':
        return 'The email address provided is invalid. Please enter a valid email.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'user-disabled':
        return 'This user account has been disabled. Please contact support for assistance.';
      case 'user-not-found':
        return 'Invalid login details. User not found.';
      case 'wrong-password':
        return 'Incorrect password. Please check your password and try again.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please enter a valid code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please request a new verification code.';
      case 'quota-exceeded':
        return 'Quota exceeded. Please try again later.';
      case 'email-already-exists':
        return 'The email address already exists. Please use a different email.';
      case 'provider-already-linked':
        return 'The account is already linked with another provider.';
      case 'requires-recent-login':
        return 'This operation is sensitive and requires recent authentication. Please log in again.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';
      case 'user-mismatch':
        return 'The supplied credentials do not correspond to the previously signed-in user.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different credentials.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'invalid-action-code':
        return 'The action code is invalid. Please request a new one.';
      case 'missing-action-code':
        return 'Missing action code. Please provide a valid action code.';
      case 'user-token-expired':
        return 'The user\'s token has expired. Please sign in again.';
      case 'user-token-expired':
        return 'Your session has expired. Please sign in again.';
      case 'user-token-revoked':
        return 'The user\'s token has been revoked. Please sign in again.';
      case 'invalid-message-payload':
        return 'The email template verification message payload is invalid.';
      case 'invalid-sender':
        return 'The email template sender is invalid. Please verify the sender\'s email.';
      case 'invalid-recipient-email':
        return 'The recipient email address is invalid. Please provide a valid email.';
      default:
        return 'An unexpected error occurred. Please try again later.';

    }
  }
}
