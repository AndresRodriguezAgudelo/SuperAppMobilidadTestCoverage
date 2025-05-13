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

  /* Lista de prueba removida
  final List<Map<String, String>> servicios = [
    {
      'title': 'La Libertad CarSharing',
      'subtitle': 'Alquiler de vehículos por horas o días',
      'imageUrl': 'assets/images/image_servicio4.png',
      'url': 'https://www.equirent.com.co/home/la-libertad-carsharing/',
    },
    {
      'title': 'Renting Corporativo',
      'subtitle': 'Soluciones de movilidad para empresas',
      'imageUrl': 'assets/images/image_servicio4.png',
      'url': 'https://www.equirent.com.co/home/la-libertad-carsharing/',
    },
    {
      'title': 'Renting Personal',
      'subtitle': 'Tu vehículo con todo incluido',
      'imageUrl': 'assets/images/image_servicio4.png',
      'url': 'https://www.equirent.com.co/home/la-libertad-carsharing/',
    },
    {
      'title': 'Mantenimiento Premium',
      'subtitle': 'Servicio técnico especializado',
      'imageUrl': 'assets/images/image_servicio4.png',
      'url': 'https://www.equirent.com.co/home/la-libertad-carsharing/',
    },
    {
      'title': 'Seguros Todo Riesgo',
      'subtitle': 'Protección completa para tu vehículo',
      'imageUrl': 'assets/images/image_servicio4.png',
      'url': 'https://www.equirent.com.co/home/la-libertad-carsharing/',
    },
    {
      'title': 'Asistencia 24/7',
      'subtitle': 'Soporte técnico en cualquier momento',
      'imageUrl': 'assets/images/image_servicio4.png',
      'url': 'https://www.equirent.com.co/home/la-libertad-carsharing/',
    },
    {
      'title': 'Vehículos Eléctricos',
      'subtitle': 'Movilidad sostenible y eficiente',
      'imageUrl': 'assets/images/image_servicio4.png',
      'url': 'https://www.equirent.com.co/home/la-libertad-carsharing/',
    },
    {
      'title': 'Flotas Empresariales',
      'subtitle': 'Gestión integral de flotas',
      'imageUrl': 'assets/images/image_servicio4.png',
      'url': 'https://www.equirent.com.co/home/la-libertad-carsharing/',
    },
    {
      'title': 'Asesoría Personalizada',
      'subtitle': 'Encuentra el servicio ideal para ti',
      'imageUrl': 'assets/images/image_servicio4.png',
      'url': 'https://www.equirent.com.co/home/la-libertad-carsharing/',
    },
  ]; */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBar(
          screenType: ScreenType.progressScreen,
          title: 'Servicios',
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
              child: Text('No hay servicios disponibles'),
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
