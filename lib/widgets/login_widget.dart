import 'package:flutter/material.dart';

class LoginWidget extends StatefulWidget {
  final List<String> fieldNames;
  final String integrationName;
  final Function(Map<String,String>) onLogin;
  const LoginWidget(this.fieldNames, this.integrationName, {super.key, required this.onLogin});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  List<TextEditingController> controllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.fieldNames.length; i++) {
      controllers.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Login'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          widget.fieldNames.length,
              (index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controllers[index],
              decoration: InputDecoration(
                labelText: widget.fieldNames[index],
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            Map<String,String> loginData = {};
            for(var i = 0;i<controllers.length;i++) {
              loginData[widget.fieldNames[i]] = controllers[i].text;
            }
            widget.onLogin(loginData);
            Navigator.of(context).pop();
          },
          child: const Text('Login'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (int i = 0; i < controllers.length; i++) {
      controllers[i].dispose();
    }
    super.dispose();
  }
}