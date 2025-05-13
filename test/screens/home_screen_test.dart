import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:Equirent_Mobility/BLoC/home/home_bloc.dart';
import 'package:Equirent_Mobility/BLoC/vehicles/vehicles_bloc.dart';
import 'package:Equirent_Mobility/BLoC/alerts/alerts_bloc.dart';
import 'package:Equirent_Mobility/BLoC/services/services_bloc.dart';

void main() {
  testWidgets('HomeScreen renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<VehiclesBloc>(create: (_) => VehiclesBloc()),
          ChangeNotifierProvider<HomeBloc>(create: (_) => HomeBloc()),
          ChangeNotifierProvider<AlertsBloc>(create: (_) => AlertsBloc()),
          ChangeNotifierProvider<ServicesBloc>(create: (_) => ServicesBloc()),
        ],
        child: MaterialApp(
          home: const Scaffold(body: HomeScreen()),
        ),
      ),
    );
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
