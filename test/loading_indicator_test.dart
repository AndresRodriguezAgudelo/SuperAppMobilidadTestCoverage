import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/widgets/loading_indicator.dart';

void main() {
  group('LoadingIndicator Widget Tests', () {
    test('should create LoadingIndicator instance', () {
      // Crear una instancia del widget
      const widget = LoadingIndicator();
      
      // Verificar que el widget se crea correctamente
      expect(widget, isA<StatelessWidget>());
    });
  });
}

