import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../BLoC/images/image_bloc.dart';
import '../../screens/servicios_web_view_screen.dart';

class ServiceLongCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String url;

  const ServiceLongCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
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
      child: Container(
        height: 110,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F7FC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: FutureBuilder<String>(
                future: context.read<ImageBloc>().getImageUrl(imageUrl),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                        width: 300,
                        height: 240,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final imageUrl = snapshot.data ?? 'assets/images/image_servicio1.png';
                  return imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        height: 110,
                        width: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('⚠️ Error cargando imagen: $error');
                          return Image.asset(
                            'assets/images/image_servicio1.png',
                        width: 300,
                        height: 240,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        imageUrl,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_outward,
                color: Color.fromARGB(255, 33, 33, 33),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
