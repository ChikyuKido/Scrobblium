
import 'package:flutter/material.dart';

class SimpleTextSettingsTile extends StatefulWidget {
  final String title;
  final Widget? leading;
  final String? subtitle;
  final TextStyle? subtitleTextStyle;
  final TextStyle? titleTextStyle;
  final bool enabled;
  final Widget child;
  final GestureTapCallback? onTap;

  const SimpleTextSettingsTile({super.key,
    required this.title,
    required this.child,
    this.subtitle = '',
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.onTap,
    this.enabled = true,
    this.leading,
  });

  @override
  _SimpleTextSettingsTileState createState() => _SimpleTextSettingsTileState();
}

class _SimpleTextSettingsTileState extends State<SimpleTextSettingsTile> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListTile(
            leading: widget.leading,
            title: Text(
              widget.title,
              style: widget.titleTextStyle ?? headerTextStyle(context),
            ),
            subtitle: widget.subtitle?.isEmpty ?? true
                ? null
                : Text(
              widget.subtitle!,
              style:
              widget.subtitleTextStyle ?? subtitleTextStyle(context),
            ),
            enabled: widget.enabled,
            onTap: widget.onTap,
            trailing: widget.child,
            dense: true,
            isThreeLine: (widget.subtitle?.isNotEmpty ?? false) &&
                widget.subtitle!.length > 70,
          ),
        ],
      ),
    );
  }
}

TextStyle? headerTextStyle(BuildContext context) =>
    Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16.0);

TextStyle? subtitleTextStyle(BuildContext context) => Theme.of(context)
    .textTheme
    .titleSmall
    ?.copyWith(fontSize: 13.0, fontWeight: FontWeight.normal);