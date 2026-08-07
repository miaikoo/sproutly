class ApiEndpoints {
  ApiEndpoints._();

  static const geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Optional proxy endpoint for production. If you point this to a backend
  /// function, the Gemini key can live there instead of the app bundle.
  static const aiProxyUrl = String.fromEnvironment('AI_PROXY_URL', defaultValue: '');

  /// Supplied at build time so the key never lands in git:
  ///   flutter run --dart-define=GEMINI_API_KEY=...
  ///   flutter build apk --dart-define=GEMINI_API_KEY=...
  ///
  /// For local development, you can also create a .env file and load it in a
  /// launcher script, but do not commit the actual value.
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  static const geminiModel = 'gemini-2.0-flash';
}
