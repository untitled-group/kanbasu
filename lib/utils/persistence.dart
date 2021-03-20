import 'package:shared_preferences/shared_preferences.dart';

class PreferencesKeys {
  static const api_key = 'api_key';
  static const api_endpoint = 'api_endpoint';
}

class PreferencesDefaults {
  static const api_key = '';
  static const api_endpoint = 'https://oc.sjtu.edu.cn/api/v1';
}

String getApiKey(SharedPreferences prefs) =>
    prefs.getString(PreferencesKeys.api_key) ?? PreferencesDefaults.api_key;

String getApiEndpoint(SharedPreferences prefs) =>
    prefs.getString(PreferencesKeys.api_endpoint) ??
    PreferencesDefaults.api_endpoint;

class KvStoreIdentifiers {
  static const main = 'kanbasu_main_kvs';
}
