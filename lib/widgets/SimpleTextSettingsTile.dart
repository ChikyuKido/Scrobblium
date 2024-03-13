
import 'package:flutter/material.dart';

/// [SimpleTextSettingsTile] is a Basic Building block for Any Settings widget.
///
/// This widget is container for any widget which is to be used for setting.
class SimpleTextSettingsTile extends StatefulWidget {
  /// title string for the tile
  final String title;

  /// widget to be placed at first in the tile
  final Widget? leading;

  /// subtitle string for the tile
  final String? subtitle;

  /// title text style
  final TextStyle? titleTextStyle;

  /// subtitle text style
  final TextStyle? subtitleTextStyle;

  /// flag to represent if the tile is accessible or not, if false user input is ignored
  final bool enabled;

  /// widget which is placed as the main element of the tile as settings UI
  final Widget child;

  /// call back for handling the tap event on tile
  final GestureTapCallback? onTap;

  // /// flag to show the child below the main tile elements
  // final bool showChildBelow;

  SimpleTextSettingsTile({
    required this.title,
    required this.child,
    this.subtitle = '',
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.onTap,
    this.enabled = true,
    // this.showChildBelow = false,
    this.leading,
  });

  @override
  _SimpleTextSettingsTileState createState() => _SimpleTextSettingsTileState();
}

class _SimpleTextSettingsTileState extends State<SimpleTextSettingsTile> {
  @override
  void initState() {
    super.initState();
  }

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
            // trailing: Visibility(
            //   visible: !widget.showChildBelow,
            //   child: widget.child,
            // ),
            trailing: widget.child,
            dense: true,
            // wrap only if the subtitle is longer than 70 characters
            isThreeLine: (widget.subtitle?.isNotEmpty ?? false) &&
                widget.subtitle!.length > 70,
          ),
          // Visibility(
          //   visible: widget.showChildBelow,
          //   child: widget.child,
          // ),
        ],
      ),
    );
  }
}

TextStyle? headerTextStyle(BuildContext context) =>
    Theme.of(context).textTheme.headline6?.copyWith(fontSize: 16.0);

TextStyle? subtitleTextStyle(BuildContext context) => Theme.of(context)
    .textTheme
    .subtitle2
    ?.copyWith(fontSize: 13.0, fontWeight: FontWeight.normal);