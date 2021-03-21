import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/user.dart';
import 'package:kanbasu/scaffolds/simple_list.dart';
import 'package:kanbasu/widgets/snack.dart';
import 'package:kanbasu/utils/persistence.dart';
import 'package:kanbasu/utils/stream_op.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/user.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeScreen extends HookWidget {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

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
          title: Text('Settings'),
          content: Form(
            child: Column(
              children: [
                TextFormField(
                  controller: keyController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    icon: Icon(Icons.vpn_key),
                  ),
                ),
                TextFormField(
                  controller: endpointController,
                  decoration: InputDecoration(
                    labelText: 'API Endpoint',
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
                  child: Text('Done'),
                )
              ],
            )
          ],
        );
      },
    );

    if (result == true) {
      await prefs.setString(PreferencesKeys.api_key, keyController.text);
      await prefs.setString(
          PreferencesKeys.api_endpoint, endpointController.text);
      await model.updateCanvasClient();
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Model>(context);

    return HookBuilder(
      builder: (context) {
        final manualRefresh = useState(false);
        final triggerRefresh = useState(Completer());

        final userStream = useMemoized(() {
          final stream = model.canvas
              .getCurrentUser()
              // Notify RefreshIndicator to complete refresh
              .doOnDone(() => triggerRefresh.value.complete())
              .doOnError((error, _) => showErrorSnack(context, error));
          if (manualRefresh.value) {
            // if manually refresh, return only latest result
            return yieldLast(stream);
          } else {
            return stream;
          }
        }, [manualRefresh.value, triggerRefresh.value]);

        final userSnapshot = useStream(userStream, initialData: null);

        final userData = userSnapshot.data;

        return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () async {
              manualRefresh.value = true;
              final completer = Completer();
              triggerRefresh.value = completer;
              await completer.future;
            },
            child: SimpleListScaffold<User>(
              title: Text('Me'),
              itemBuilder: (user) => UserWidget(user),
              items: userData != null ? [userData] : [],
              actionBuilder: () => IconButton(
                icon: Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () {
                  _pushSettings(context);
                },
              ),
            ));
      },
    );
  }
}
