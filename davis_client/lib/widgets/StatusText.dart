import 'package:davis_client/constants/ui_constants.dart';
import 'package:flutter/material.dart';

class StatusText extends StatelessWidget {
  final String text;

  const StatusText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(
        text,
        key: ValueKey<String>(text),
        style: const TextStyle(
          fontFamily: "HumaneFont",
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: UiConstants.accentColor,
        ),
      ),
    );
  }
}
