import 'package:html/parser.dart' show parse;

String getPlainText(String htmlData) {
  final bodyText = parse(htmlData).body?.text;
  return bodyText ?? '';
}
