import 'package:flutter/material.dart';
import '../../screens/servicios_web_view_screen.dart';

class ServicioCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String url;

  const ServicioCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiciosScreen(url: url),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imagePath.startsWith('http')
                ? Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('⚠️ Error cargando imagen: $error');
                      return Image.asset(
                        'assets/images/image_servicio1.png',
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
