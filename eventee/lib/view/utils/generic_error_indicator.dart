
import 'package:flutter/material.dart';

class GenericErrorIndicator extends StatelessWidget {
  const GenericErrorIndicator();

  @override
  Widget build(context) {
    return const Center(
      child: Icon(
        Icons.error_outline,
        color: Colors.red,
      ),
    );
  }
}