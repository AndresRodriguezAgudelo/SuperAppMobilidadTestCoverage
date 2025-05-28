import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../BLoC/services/services_bloc.dart';
import '../../BLoC/images/image_bloc.dart';
import 'servicio_card.dart';
import '../../widgets/transparentloading.dart';

class NuestrosServicios extends StatefulWidget {
  const NuestrosServicios({super.key});

  @override
  State<NuestrosServicios> createState() => _NuestrosServiciosState();
}

class _NuestrosServiciosState extends State<NuestrosServicios> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesBloc>(
      builder: (context, servicesBloc, child) {
        // Usar el widget Loading para mostrar el estado de carga
        return LoadingTransparent(
          isLoading: servicesBloc.isLoading,
          message: 'Cargando servicios...',
          child: servicesBloc.error != null
            ? Center(
                child: Text('Error: ${servicesBloc.error}'),
              )
            : servicesBloc.services.isEmpty
              ? const Center(
                  //child: Text('No hay servicios disponibles'),
                  child: Text(''),
                )
              : _buildServicesContent(context, servicesBloc.services),
        );
      },
    );
  }

  // Método para construir el contenido de los servicios
  Widget _buildServicesContent(BuildContext context, List<dynamic> services) {
    // Determinar el número óptimo de elementos por página basado en el tamaño de pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final itemsPerRow = screenWidth > 600 ? 4 : 3; // Más elementos por fila en pantallas grandes
    final rowsPerPage = 2; // Mantener 2 filas por página
    final itemsPerPage = itemsPerRow * rowsPerPage;
    
    // Calcular el número total de páginas basado en los elementos disponibles
    final int totalPages = (services.length / itemsPerPage).ceil();

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nuestros servicios',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Calcular la altura basada en el número de filas necesarias
          LayoutBuilder(
            builder: (context, constraints) {
              // Calcular cuántas filas necesitamos realmente
              final int totalItems = services.length;
              final int rowsNeeded = (totalItems / itemsPerRow).ceil();
              
              // Limitar a un máximo de 2 filas por página
              final int rowsToShow = min(rowsNeeded, rowsPerPage);
              
              // Calcular la altura basada en las filas con suficiente espacio para el título
              final double cardHeight = 140.0; // Aumentado de 120 a 140 para dar más espacio al título
              final double rowSpacing = 16.0; // Aumentado de 8 a 16 para mayor separación entre filas
              final double totalHeight = (cardHeight * rowsToShow) + (rowsToShow > 1 ? rowSpacing : 0);
              
              return SizedBox(
                height: totalHeight,
                child: PageView.builder(
                  itemCount: totalPages,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: itemsPerRow,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 16,
                        childAspectRatio: 100 / 140, // Ajustado para coincidir con la nueva altura
                      ),
                      // Calcular el número de items para esta página específica
                      itemCount: min((pageIndex + 1) * itemsPerPage, services.length) - (pageIndex * itemsPerPage),
                      itemBuilder: (context, index) {
                        final serviceIndex = pageIndex * itemsPerPage + index;
                        // Ya no necesitamos verificar si serviceIndex >= services.length porque
                        // hemos ajustado itemCount para que solo muestre los elementos disponibles
                        final servicio = services[serviceIndex];
                        final imageKey = servicio['imageKey'];
                        
                        // Obtener URL de la imagen
                        return FutureBuilder<String>(
                          future: context.read<ImageBloc>().getImageUrl(imageKey),
                          builder: (context, snapshot) {
                            return ServicioCard(
                              imagePath: snapshot.data ?? 'assets/images/image_servicio1.png',
                              title: servicio['title']!,
                              url: servicio['url']!,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          // Indicadores de página - solo mostrar si hay más de una página
          if (totalPages > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalPages,
                (index) => Container(
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index
                        ? const Color.fromRGBO(46, 168, 224, 1.0)
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
