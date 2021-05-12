import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/route_manager.dart';
import 'package:kanbasu/aggregation.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/resolver_model.dart';
import 'package:kanbasu/router.dart';
import 'package:kanbasu/utils/timeago_zh_cn.dart';
import 'package:kanbasu/widgets/offline_mode.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'home.dart';
import 'buffer_api/kvstore.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:timeago/timeago.dart' as timeago;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  KvStore.initFfi();
  timeago.setLocaleMessages('zh_CN', KZhCnMessages());

  if (Platform.isAndroid || Platform.isIOS) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  final model = Model();
  await model.init();

  return runApp(EasyLocalization(
    supportedLocales: [
      Locale('zh', 'CN'),
      Locale('en', 'US'),
    ],
    startLocale: Locale('zh', 'CN'),
    fallbackLocale: Locale('en', 'US'),
    useFallbackTranslations: true,
    path: 'assets/translations',
    assetLoader: YamlAssetLoader(),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => model),
        ChangeNotifierProxyProvider<Model, ResolverModel>(
            create: (_) => ResolverModel(),
            update: (_, model, notifier) => notifier!..updateModel(model))
      ],
      child: Phoenix(child: MyApp()), // for rebirthing the app
    ),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<Model>();
    final theme = model.theme;

    final themeData = ThemeData(
      brightness: model.brightness,
      primarySwatch: Colors.red,
      primaryColor: theme.primary,
      accentColor: theme.primary,
      scaffoldBackgroundColor: theme.background,
      buttonColor: theme.primary,
      primaryTextTheme: TextTheme(
        headline6: TextStyle(color: theme.text),
      ),
      tabBarTheme: TabBarTheme(labelColor: theme.text),
      appBarTheme: AppBarTheme(
        backgroundColor: theme.grayBackground,
        foregroundColor: theme.text,
        actionsIconTheme: IconThemeData(color: theme.text),
        iconTheme: IconThemeData(color: theme.text),
      ),
      pageTransitionsTheme: PageTransitionsTheme(builders: {}),
      indicatorColor: theme.primary,
    );

    return GetMaterialApp(
      title: 'Kanbasu',
      darkTheme: themeData,
      theme: themeData,
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      defaultTransition: Transition.fade,
      getPages: getPages,
      debugShowCheckedModeBanner: false,
      builder: (_, child) => OfflineModeWrapper(child: child),
      home: Home(),
    );
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case Workmanager.iOSBackgroundTask:
        {
          KvStore.initFfi();
          final model = Model();
          await model.init();

          await aggregate(
            model.canvas,
            useOnlineData: true,
            dryRun: true,
          ).toList();
          await model.setAggregatedNow();

          break;
        }
    }
    return true;
  });
}
