class ApiEndpoints {
  ApiEndpoints._();

  static const openRouterChatCompletions = 'https://openrouter.ai/api/v1/chat/completions';

  // ponytail: placeholder key committed on purpose (user requested), replace with a
  // real key from https://openrouter.ai/keys before shipping. Client-side key means
  // anyone can extract it from the app bundle — acceptable only because the model
  // below is a free tier with no billing exposure.
  static const openRouterApiKey = 'sk-or-v1-REPLACE_WITH_YOUR_KEY';

  static const openRouterModel = 'meta-llama/llama-3.3-70b-instruct:free';
}
