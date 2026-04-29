class GoogleSignInConfig {
  GoogleSignInConfig._();

  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  static String? get resolvedServerClientId {
    if (serverClientId.isEmpty ||
        serverClientId == 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com') {
      return null;
    }

    return serverClientId;
  }
}
