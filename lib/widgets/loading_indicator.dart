import 'package:flutter/material.dart';
import 'loading_logo.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingLogo(size: 64),
    );
  }
}
