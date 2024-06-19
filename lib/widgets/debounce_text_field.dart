import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';

class DebounceTextField extends StatefulWidget {
  final ValueChanged<String> onDebounceChanged;
  final Duration bounceDuration;
  final InputDecoration? decoration;
  final TextStyle? style;
  const DebounceTextField({super.key, required this.onDebounceChanged, required this.bounceDuration, this.decoration, this.style});

  @override
  State<DebounceTextField> createState() => _DebounceTextFieldState();
}

class _DebounceTextFieldState extends State<DebounceTextField> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String text) {
    EasyDebounce.debounce('searchDebounce', widget.bounceDuration, () {
      widget.onDebounceChanged.call(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textEditingController,
      onChanged: _onSearchTextChanged,
      decoration: widget.decoration,
      style: widget.style,
    );
  }
}
