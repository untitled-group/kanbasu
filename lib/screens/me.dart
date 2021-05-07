import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:kanbasu/models/resolver_model.dart';
import 'package:kanbasu/models/user.dart';
import 'package:kanbasu/utils/logging.dart';
import 'package:kanbasu/utils/persistence.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/common/future.dart';
import 'package:kanbasu/widgets/resolver.dart';
import 'package:kanbasu/widgets/snack.dart';
import 'package:kanbasu/widgets/user.dart';
import 'package:provider/provider.dart';
import 'package:separated_column/separated_column.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kanbasu/aggregation.dart';

class _MeView extends FutureWidget<User?> {
  @override
  Widget buildWidget(context, User? data) =>
      data == null ? Container() : UserWidget(data);

  @override
  List<Future<User?>> getFutures(context) =>
      Provider.of<Model>(context).canvas.getCurrentUser();
}

class MeScreen extends HookWidget {
  void _pushSettings(context) async {
    final model = Provider.of<Model>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    final keyController = TextEditingController(text: getApiKey(prefs));
    final endpointController =
        TextEditingController(text: getApiEndpoint(prefs));

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: Text('title.settings'.tr()),
          content: Form(
            child: Column(
              children: [
                TextFormField(
                  controller: keyController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'settings.api_key'.tr(),
                    icon: Icon(Icons.vpn_key),
                  ),
                ),
                TextFormField(
                  controller: endpointController,
                  decoration: InputDecoration(
                    labelText: 'settings.api_endpoint'.tr(),
                    icon: Icon(Icons.link),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ButtonBar(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text('settings.apply'.tr()),
                )
              ],
            )
          ],
        );
      },
    );

    if (result == true) {
      await prefs.setString(
        PreferencesKeys.apiKey,
        keyController.text,
      );
      await prefs.setString(
        PreferencesKeys.apiEndpoint,
        endpointController.text,
      );
      await model.updateCanvasClient();
      Phoenix.rebirth(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Model>(context, listen: false);
    final tapped = useState(0);

    final developerTools = Container(
      padding: EdgeInsets.all(15),
      child: SeparatedColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        separatorBuilder: (context, index) => SizedBox(height: 5),
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.grey, // background
              onPrimary: Colors.white, // foreground
            ),
            onPressed: () {
              final logger = createLogger();
              logger.i('Aggregator!');
              final aggregation = aggregate(
                  Provider.of<Model>(context, listen: false).canvas,
                  useOnlineData: true);
              aggregation.listen((data) => {logger.i(data)}).onDone(() {
                showSnack(context, 'Done');
              });
            },
            child: Text('运行 Aggregator'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.grey, // background
              onPrimary: Colors.white, // foreground
            ),
            onPressed: () {
              final logger = createLogger();
              logger.i('Aggregator!');
              final aggregation = aggregate(
                  Provider.of<Model>(context, listen: false).canvas,
                  useOnlineData: false);
              aggregation.listen((data) => {logger.i(data)}).onDone(() {
                showSnack(context, 'Done');
              });
            },
            child: Text('运行 Aggregator (Offline)'),
          ),
        ],
      ),
    );

    final resolverModel = Provider.of<ResolverModel>(context);

    final tools = Container(
      padding: EdgeInsets.all(15),
      child: SeparatedColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        separatorBuilder: (context, index) => SizedBox(height: 5),
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.grey, // background
              onPrimary: Colors.white, // foreground
            ),
            onPressed: () async => await resolverModel.requestFullSync(),
            child: Text('同步数据'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.grey, // background
              onPrimary: Colors.white, // foreground
            ),
            onPressed: () async {
              await model.deleteKv();
              Phoenix.rebirth(context);
            },
            child: Text('清空缓存'),
          )
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('title.settings'.tr()),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'title.settings'.tr(),
            onPressed: () {
              _pushSettings(context);
            },
          )
        ],
      ),
      body: ListView(children: [
        InkWell(
          onTap: () {
            tapped.value += 1;
          },
          child: _MeView(),
        ),
        tools,
        ResolverWidget(),
        if (tapped.value >= 5) developerTools,
      ]),
    );
  }
}
