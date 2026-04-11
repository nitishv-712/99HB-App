import 'package:homebazaar/core/network/api_client.dart';

abstract final class NewsletterService {
  /// POST /newsletter/subscribe
  static Future<void> subscribe(String email) async {
    await ApiClient.fetch<Map<String, dynamic>>(
      '/newsletter/subscribe',
      method: 'POST',
      body: {'email': email},
    );
  }

  /// POST /newsletter/unsubscribe
  static Future<void> unsubscribe(String email) async {
    await ApiClient.fetch<Map<String, dynamic>>(
      '/newsletter/unsubscribe',
      method: 'POST',
      body: {'email': email},
    );
  }
}
