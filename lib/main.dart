import 'package:flutter/material.dart';
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'buffer_api/kvstore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KvStore.initFfi();

  final model = Model();
  await Future.wait([model.init()]);

  return runApp(
    ChangeNotifierProvider(create: (context) => model, child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Model>(context).theme;

    return MaterialApp(
      title: 'Kanbasu',
      theme: ThemeData(
          primarySwatch: Colors.red,
          primaryColor: theme.primary,
          accentColor: theme.primary,
          scaffoldBackgroundColor: theme.background,
          buttonColor: theme.primary,
          primaryTextTheme: TextTheme(
            headline6: TextStyle(color: theme.text),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: theme.background,
          ),
          pageTransitionsTheme: PageTransitionsTheme(builders: {})),
      home: Home(),
    );
  }
}
