import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutSettingsScreen extends StatelessWidget {
  final String version = '1.0.0';
  const AboutSettingsScreen({super.key});

  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Scrobblium'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Scrobblium',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            FutureBuilder(future: PackageInfo.fromPlatform(), builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if(!snapshot.hasData || snapshot.data == null) {
                return Text("Version: Could not fetch version",style: Theme.of(context).textTheme.titleSmall,);
              }
              return Text("Version: ${snapshot.data!.version}",style: Theme.of(context).textTheme.titleSmall,);
            }),
            const SizedBox(height: 16.0),
            Text(
              'Scrobblium is an app that tracks music played from other apps on your device.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Source Code:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8.0),
            InkWell(
              child: const Text(
                'GitHub Repository',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              onTap: () {
                launchUrl(Uri.parse("https://github.com/ChikyuKido/Scrobblium"));
              },
            ),
          ],
        ),
      ),
    );
  }
}
