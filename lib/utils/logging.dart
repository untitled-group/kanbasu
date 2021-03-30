import 'package:logger/logger.dart';

Logger createLogger() {
  return Logger(printer: SimplePrinter());
}
