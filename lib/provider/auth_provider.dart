import 'package:flutter/foundation.dart';

/// Reserved for the app's existing ChangeNotifier-based authentication state.
///
/// It intentionally contains no guessed OTP/login implementation. The backend
/// must first document req encoding/encryption, reqType values, session payload,
/// and the exact Authorization header scheme.
class AuthProvider extends ChangeNotifier {}
