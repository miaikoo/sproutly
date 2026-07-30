class ApiEndpoints {
  ApiEndpoints._();

  static const openRouterChatCompletions = 'https://openrouter.ai/api/v1/chat/completions';

  /// Supplied at build time so the key never lands in git:
  ///   flutter run   --dart-define=OPENROUTER_API_KEY=sk-or-v1-...
  ///   flutter build apk --dart-define=OPENROUTER_API_KEY=sk-or-v1-...
  ///
  /// ponytail: still a client-side key — anyone can extract it from the APK.
  /// Acceptable only because the model below is a free tier with no billing
  /// exposure. Move the call behind a Cloud Function before any paid model.
  static const openRouterApiKey = String.fromEnvironment('OPENROUTER_API_KEY');

  static const openRouterModel = 'meta-llama/llama-3.3-70b-instruct:free';
}
