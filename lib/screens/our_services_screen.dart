import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Equirent_Mobility/BLoC/services/services_bloc.dart';

import '../widgets/top_bar.dart';
import '../widgets/nuestrosServicios/service_long_card.dart';

class OurServiciosScreen extends StatefulWidget {
  const OurServiciosScreen({super.key});

  @override
  State<OurServiciosScreen> createState() => _OurServiciosScreenState();
}

class _OurServiciosScreenState extends State<OurServiciosScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar servicios al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesBloc>().getServices();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBar(
          screenType: ScreenType.progressScreen,
          title: 'Servicios'
        ),
      ),
      body: Consumer<ServicesBloc>(
        builder: (context, servicesBloc, child) {
          if (servicesBloc.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (servicesBloc.error != null) {
            return Center(
              child: Text('Error: ${servicesBloc.error}'),
            );
          }

          final services = servicesBloc.services;
          if (services.isEmpty) {
            return const Center(
              //child: Text('No hay servicios disponibles'),
              child: Text(''),
            );
          }

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final servicio = services[index];
              return ServiceLongCard(
                imageUrl: servicio['imageKey'],
                title: servicio['title']!,
                subtitle: servicio['description']!,
                url: servicio['url']!,
              );
            },
          );
        },
      ),
    );
  }
}
