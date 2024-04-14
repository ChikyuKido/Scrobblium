import 'package:flutter/material.dart';

/// A method that will add default leading padding to all children in the list
List<Widget> getPaddedParentChildrenList(List<Widget> childrenIfEnabled,{EdgeInsets padding = const EdgeInsets.only(left: 8.0)}) {
  return childrenIfEnabled.map<Widget>((childWidget) {
    return Padding(
      padding: padding,
      child: childWidget,
    );
  }).toList();
}

TextStyle? headerTextStyle(BuildContext context) =>
    Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16.0);

TextStyle? subtitleTextStyle(BuildContext context) => Theme.of(context)
    .textTheme
    .titleSmall
    ?.copyWith(fontSize: 13.0, fontWeight: FontWeight.normal);
