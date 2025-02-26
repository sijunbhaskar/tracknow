import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SwitchListTile(
        title: Text("Enable Notifications"),
        value: notificationsEnabled,
        onChanged: (value) {
          setState(() {
            notificationsEnabled = value;
          });
        },
      ),
    );
  }
}
