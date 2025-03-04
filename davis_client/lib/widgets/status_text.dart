import 'package:davis_client/constants/ui_constants.dart';
import 'package:flutter/material.dart';

class StatusText extends StatelessWidget {
  final String message;
  final String? details;
  final bool disabled;

  const StatusText({
    super.key,
    required this.message,
    this.details,
    this.disabled = false,
  });

  Text _styledText(String text, {required double fontSize}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: disabled ? Colors.white70 : UiConstants.accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Column(
        key: ValueKey<String>(message + (details ?? "")),
        mainAxisSize: MainAxisSize.min,
        children: [
          _styledText(message, fontSize: 36),
          if (details != null) _styledText(details!, fontSize: 20),
        ],
      ),
    );
  }
}
