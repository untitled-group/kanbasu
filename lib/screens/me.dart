import 'package:flutter/material.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/user.dart';
import 'package:kanbasu/scaffolds/list.dart';
import 'package:kanbasu/utils/prefs.dart';
import 'package:kanbasu/widgets/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeScreen extends StatefulWidget {
  @override
  _MeScreenState createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  void _pushSettings() async {
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
        });

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
    // FIXME: a change of `model.canvas` won't make the widget rebuild

    return ListScaffold<User, int>(
      title: Text('Me'),
      itemBuilder: (user) => UserWidget(user),
      fetch: (_cursor) async {
        final user = (await model.canvas.getCurrentUser()).data;
        return ListPayload(items: [user], hasMore: false);
      },
      actionBuilder: () => IconButton(
        icon: Icon(Icons.settings),
        tooltip: 'Settings',
        onPressed: () {
          _pushSettings();
        },
      ),
    );
  }
}
