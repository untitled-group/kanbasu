import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/router.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'buffer_api/kvstore.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  KvStore.initFfi();
  initRouter();

  final model = Model();
  await Future.wait([model.init()]);

  return runApp(EasyLocalization(
    supportedLocales: [
      Locale('zh', 'CN'),
      Locale('en'),
    ],
    startLocale: Locale('zh', 'CN'),
    fallbackLocale: Locale('en'),
    path: 'assets/translations',
    assetLoader: YamlAssetLoader(),
    child: ChangeNotifierProvider(
      create: (context) => model,
      child: Phoenix(child: MyApp()), // for rebirthing the app
    ),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Model>(context);
    final theme = model.theme;

    return MaterialApp(
      title: 'Kanbasu',
      theme: ThemeData(
        brightness: model.brightness,
        primarySwatch: Colors.red,
        primaryColor: theme.primary,
        accentColor: theme.primary,
        scaffoldBackgroundColor: theme.background,
        buttonColor: theme.primary,
        primaryTextTheme: TextTheme(
          headline6: TextStyle(color: theme.text),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: theme.grayBackground,
          foregroundColor: theme.text,
          actionsIconTheme: IconThemeData(color: theme.text),
          iconTheme: IconThemeData(color: theme.text),
        ),
        pageTransitionsTheme: PageTransitionsTheme(builders: {}),
      ),
      onGenerateRoute: router.generator,
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      home: Home(),
    );
  }
}
