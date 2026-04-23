import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class Env {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:4000/api';

  static String get googlePlacesApiKey =>
      dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
}
