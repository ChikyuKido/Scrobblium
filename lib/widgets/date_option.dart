import 'package:flutter/material.dart';


class DateOption extends StatelessWidget {
  final String text;
  final bool selected;
  final GestureTapCallback onTap;

  const DateOption(
      {super.key,
      required this.text,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: selected
              ? Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).primaryColorDark)
              : Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
