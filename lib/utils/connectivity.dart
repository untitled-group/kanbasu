import 'dart:io';

Future<bool> checkConnectivity() async {
  var connected = false;
  try {
    final result = await InternetAddress.lookup('oc.sjtu.edu.cn');
    connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {}
  return connected;
}
