import 'dart:math';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimSearchBar extends StatefulWidget {
  final double width;
  final TextEditingController textController;
  final Icon? suffixIcon;
  final Icon? prefixIcon;
  final String helpText;
  final int animationDurationInMilli;
  final bool rtl;
  final bool autoFocus;
  final TextStyle? style;
  final bool closeSearchOnSuffixTap;
  final Color? color;
  final Color? textFieldColor;
  final Color? searchIconColor;
  final Color? textFieldIconColor;
  final List<TextInputFormatter>? inputFormatters;
  final bool boxShadow;
  final Function(String value)? onSubmitted;
  final Function()? onSearchOpen;
  final Function()? onSearchClose;
  final ValueChanged<String>? onDebounceChanged;
  final Duration? debounceDuration;
  final bool closeOnSubmit;

  const AnimSearchBar({
    Key? key,
    required this.width,
    required this.textController,
    this.suffixIcon,
    this.prefixIcon,
    this.helpText = "Search...",
    this.color = Colors.white,
    this.textFieldColor = Colors.white,
    this.searchIconColor = Colors.black,
    this.textFieldIconColor = Colors.black,
    this.animationDurationInMilli = 375,
    this.onSubmitted,
    this.rtl = false,
    this.autoFocus = false,
    this.style,
    this.closeSearchOnSuffixTap = false,
    this.boxShadow = true,
    this.inputFormatters,
    this.onSearchOpen,
    this.onSearchClose,
    this.onDebounceChanged,
    this.debounceDuration,
    this.closeOnSubmit = true,
  }) : super(key: key);

  @override
  State<AnimSearchBar> createState() => _AnimSearchBarState();
}

class _AnimSearchBarState extends State<AnimSearchBar>
    with SingleTickerProviderStateMixin {
  static Logger log = Logger("_AnimeSearchBarState");
  late AnimationController _con;
  FocusNode focusNode = FocusNode();
  String textFieldValue = '';
  int toggle = 0;
  @override
  void initState() {
    super.initState();
    _con = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationDurationInMilli),
    );
  }

  _unfocusKeyboard() {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      alignment: widget.rtl ? Alignment.centerRight : const Alignment(-1.0, 0.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: widget.animationDurationInMilli),
        height: 48.0,
        width: (toggle == 0) ? 48.0 : widget.width,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: toggle == 1 ? widget.textFieldColor : widget.color,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: !widget.boxShadow
              ? null
              : [
            const BoxShadow(
              color: Colors.black26,
              spreadRadius: -10.0,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: widget.animationDurationInMilli),
              top: 6.0,
              right: 7.0,
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: (toggle == 0) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: AnimatedBuilder(
                    builder: (context, widget) {
                      return Transform.rotate(
                        angle: _con.value * 2.0 * pi,
                        child: widget,
                      );
                    },
                    animation: _con,
                    child: GestureDetector(
                      onTap: () {
                        try {
                          _con.reverse();
                          widget.textController.clear();
                          textFieldValue = '';
                          _unfocusKeyboard();
                          setState(() {
                            toggle = 0;
                          });
                          if(widget.onSearchClose != null) widget.onSearchClose!();
                        } catch (e) {
                          log.warning(e);
                        }
                      },
                      child: widget.suffixIcon ?? Icon(
                        Icons.close,
                        size: 20.0,
                        color: widget.textFieldIconColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: widget.animationDurationInMilli),
              left: 10,
              curve: Curves.easeOut,
              top: 11.0,
              child: AnimatedOpacity(
                opacity: (toggle == 0) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  alignment: Alignment.topCenter,
                  width: widget.width / 1.7,
                  child: TextField(
                    controller: widget.textController,
                    inputFormatters: widget.inputFormatters,
                    focusNode: focusNode,
                    cursorRadius: const Radius.circular(10.0),
                    cursorWidth: 2.0,
                    onChanged: (value) {
                      textFieldValue = value;
                      EasyDebounce.debounce('searchDebounce', widget.debounceDuration?? const Duration(milliseconds: 250), () {
                        if(widget.onDebounceChanged != null) widget.onDebounceChanged?.call(value);
                      });
                    },
                    onSubmitted: (value) {
                      if(widget.onSubmitted != null) widget.onSubmitted!(value);
                      if(widget.closeOnSubmit) {
                        setState(() {
                          toggle = 0;
                        });
                        widget.textController.clear();
                      }
                      _unfocusKeyboard();
                    },
                    onEditingComplete: () {
                      if(widget.closeOnSubmit) {
                        setState(() {
                          toggle = 0;
                        });
                      }
                      _unfocusKeyboard();
                    },
                    style: widget.style ?? const TextStyle(color: Colors.black),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(bottom: 5),
                      isDense: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelText: widget.helpText,
                      labelStyle: const TextStyle(
                        color: Color(0xff5B5B5B),
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500,
                      ),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: toggle == 0,
              child: Material(
                color: widget.color,
                borderRadius: BorderRadius.circular(30.0),
                child: IconButton(
                  splashRadius: 19.0,
                  icon: Icon(
                    Icons.search,
                    color: widget.searchIconColor,
                    size: 20.0,
                  ),
                  onPressed: () {
                    setState(
                            () {
                          if (toggle == 0) {
                            toggle = 1;
                            setState(() {
                              if (widget.autoFocus) {
                                FocusScope.of(context).requestFocus(focusNode);
                              }
                            });
                            _con.forward();
                            if (widget.onSearchOpen != null) {
                              widget.onSearchOpen?.call!();
                            }
                          }
                        }
                    );
                  },
                ),
              ),)
          ],
        ),
      ),
    );
  }
}
