import 'package:flutter/material.dart';
import '../widgets/loading_logo.dart';
import 'package:Equirent_Mobility/widgets/notification_card.dart';

/// Pantalla de carga simple y reutilizable para tareas asíncronas genéricas
class SimpleLoadingScreen extends StatefulWidget {
  /// Lista de tareas asíncronas que retornan un valor y se deben completar antes de mostrar la pantalla destino
  final List<Future<dynamic> Function()> tasks;
  /// Builder que recibe la lista de resultados de las tareas y construye la pantalla destino
  final Widget Function(BuildContext context, List<dynamic> results) builder;

  const SimpleLoadingScreen({
    super.key,
    required this.tasks,
    required this.builder,
  });

  @override
  _SimpleLoadingScreenState createState() => _SimpleLoadingScreenState();
}

class _SimpleLoadingScreenState extends State<SimpleLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  Future<void> _startLoading() async {
    final results = <dynamic>[];
    try {
      for (final task in widget.tasks) {
        final res = await task();
        results.add(res);
      }
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (ctx) => widget.builder(ctx, results),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      NotificationCard.showNotification(
  context: context,
  isPositive: false,
  icon: Icons.error,
  text: 'Error cargando datos: $e',
  date: DateTime.now(),
  title: 'Error',
);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            LoadingLogo(size: 80),
            SizedBox(height: 16),
            Text('Cargando datos...',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
