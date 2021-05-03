import 'package:shared_preferences/shared_preferences.dart';

class PreferencesKeys {
  static const apiKey = 'api_key';
  static const apiEndpoint = 'api_endpoint';
}

class PreferencesDefaults {
  static const apiKey = '';
  static const apiEndpoint = 'https://oc.sjtu.edu.cn/api/v1';
}

String getApiKey(SharedPreferences prefs) =>
    prefs.getString(PreferencesKeys.apiKey) ?? PreferencesDefaults.apiKey;

String getApiEndpoint(SharedPreferences prefs) =>
    prefs.getString(PreferencesKeys.apiEndpoint) ??
    PreferencesDefaults.apiEndpoint;

class KvStoreIdentifiers {
  static String main(String key) {
    return 'kanbasu_main_${key.hashCode.toRadixString(16)}';
  }
}
