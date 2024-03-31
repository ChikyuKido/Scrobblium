import 'package:flutter/material.dart';

class SongsFilterPage extends StatefulWidget {
  const SongsFilterPage({super.key});

  @override
  State<SongsFilterPage> createState() => _SongsFilterPageState();
}

class _SongsFilterPageState extends State<SongsFilterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter"),

      ),
    );
  }
}
