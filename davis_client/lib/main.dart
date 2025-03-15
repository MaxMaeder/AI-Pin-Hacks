import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel("touchpad_events");
  double x = 0.0;
  double y = 0.0;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      print(call);
      if (call.method == "onTouchpadEvent") {
        setState(() {
          x = call.arguments["x"];
          y = call.arguments["y"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: Text("Touchpad: X=$x, Y=$y"))),
    );
  }
}
