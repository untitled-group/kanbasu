import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:kanbasu/models/user.dart';
import 'package:kanbasu/screens/common_screen.dart';
import 'package:kanbasu/utils/persistence.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/single.dart';
import 'package:kanbasu/widgets/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeScreen extends CommonScreen<User?> {
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
                  child: Text('Apply and Restart'),
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
      Phoenix.rebirth(context);
    }
  }

  @override
  Stream<User?> getStream() =>
      Provider.of<Model>(useContext()).canvas.getCurrentUser();

  @override
  Widget buildWidget(User? data) =>
      data == null ? Container() : Single(UserWidget(data));

  @override
  Widget getTitle() => Text('Me');

  @override
  Widget? getAction(BuildContext context) => IconButton(
      icon: Icon(Icons.settings),
      tooltip: 'Settings',
      onPressed: () {
        _pushSettings(context);
      });
}
