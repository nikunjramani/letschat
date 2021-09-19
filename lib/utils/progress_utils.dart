import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(),
      );
}

class ProgressUtils {
  static CircularProgressIndicator circularProgressIndicator() {
    return CircularProgressIndicator();
  }

  static LinearProgressIndicator linearProgressIndicator() {
    return LinearProgressIndicator();
  }
}
