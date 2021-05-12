import 'package:shared_preferences/shared_preferences.dart';

class PreferencesKeys {
  static const apiKey = 'api_key';
  static const apiEndpoint = 'api_endpoint';
  static const aggregatedAt = 'aggregated_at';
}

class PreferencesDefaults {
  static const apiKey = '';
  static const apiEndpoint = 'https://oc.sjtu.edu.cn/api/v1';
  static const aggregatedAt = '';
}

String getApiKey(SharedPreferences prefs) =>
    prefs.getString(PreferencesKeys.apiKey) ?? PreferencesDefaults.apiKey;

String getApiEndpoint(SharedPreferences prefs) =>
    prefs.getString(PreferencesKeys.apiEndpoint) ??
    PreferencesDefaults.apiEndpoint;

DateTime? getAggregatedAt(SharedPreferences prefs) =>
    DateTime.tryParse(prefs.getString(PreferencesKeys.aggregatedAt) ??
        PreferencesDefaults.aggregatedAt);

Future<bool> setAggregatedAt(SharedPreferences prefs, DateTime dateTime) =>
    prefs.setString(
      PreferencesKeys.aggregatedAt,
      DateTime.now().toIso8601String(),
    );

class KvStoreIdentifiers {
  static String main(String key) {
    return 'kanbasu_main_${key.hashCode.toRadixString(16)}';
  }
}
