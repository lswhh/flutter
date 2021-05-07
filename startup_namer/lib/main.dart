import 'package:flutter/material.dart';
import 'package:startup_namer/ScoreSelector.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bowling Average Recorder',
      home: ScoreSelector(),
    );
  }
}
