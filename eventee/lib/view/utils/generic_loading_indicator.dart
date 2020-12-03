
import 'package:flutter/material.dart';

class GenericLoadingIndicator extends StatelessWidget {
  @override
  Widget build(context) {
    return const Center(
      child: SizedBox(
        child: CircularProgressIndicator(),
        width: 80,
        height: 80,
      ),
    );
  }
}
