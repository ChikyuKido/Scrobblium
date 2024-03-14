
import 'package:flutter/material.dart';


TextStyle? headerTextStyle(BuildContext context) =>
    Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16.0);

TextStyle? subtitleTextStyle(BuildContext context) => Theme.of(context)
    .textTheme
    .titleSmall
    ?.copyWith(fontSize: 13.0, fontWeight: FontWeight.normal);