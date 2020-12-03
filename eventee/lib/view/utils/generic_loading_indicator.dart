
import 'package:flutter/material.dart';

class GenericLoadingIndicator extends StatelessWidget {
  final double size;
  const GenericLoadingIndicator({this.size = 80});

  @override
  Widget build(context) {
    return Center(
      child: SizedBox(
        child: const CircularProgressIndicator(),
        width: this.size,
        height: this.size,
      ),
    );
  }
}
