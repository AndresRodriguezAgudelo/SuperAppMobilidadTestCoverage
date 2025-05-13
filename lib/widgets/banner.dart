import 'package:flutter/material.dart';
import '../screens/servicios_web_view_screen.dart';

class BannerItem {
  final String imagePath;
  final String title;
  final String message;
  final String? url;

  BannerItem({
    required this.imagePath,
    required this.title,
    required this.message,
    this.url,
  });
}

class BannerWidget extends StatelessWidget {
  final BannerItem item;
  final bool fullWidth;

  const BannerWidget({
    super.key,
    required this.item,
    this.fullWidth = false,
  });

  void _handleTap(BuildContext context) {
    if (item.url != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiciosScreen(url: item.url!),
        ),
      );
    }
  }
  
  // Construye el widget de imagen con manejo de errores
  Widget _buildImage(String imagePath) {
    //print('\n📷 BANNER: Cargando imagen: $imagePath');
    
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Es una URL, usar Image.network con manejo de errores
      //print('\n📷 BANNER: Usando Image.network para: $imagePath');
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          print('\n❌ ERROR CARGANDO IMAGEN DE RED: $error');
          print('URL: $imagePath');
          print('STACK TRACE: $stackTrace');
          // Mostrar imagen de respaldo en caso de error
          return Image.asset(
            'assets/images/BannerSOAT.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      // Es un asset local
      //print('\n📷 BANNER: Usando Image.asset para: $imagePath');
      return Image.asset(
        imagePath,
        fit: BoxFit.fill,
        width: double.infinity,
        height: double.infinity,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stackContent = Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildImage(item.imagePath),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: fullWidth
          ? SizedBox(width: double.infinity, child: stackContent)
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(width: 328, child: stackContent),
            ),
    );
  }
}
