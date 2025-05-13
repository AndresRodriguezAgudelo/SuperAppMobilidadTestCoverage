import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../BLoC/images/image_bloc.dart';
import '../screens/guide_detail_screen.dart';

class GuideCard extends StatelessWidget {
  final String title;
  final String imageKey;
  final String date;
  final String tag;
  final String content;
  final String? secondaryImageKey;
  final String? videoKey;

  const GuideCard({
    super.key,
    required this.title,
    required this.imageKey,
    required this.date,
    required this.tag,
    required this.content,
    this.secondaryImageKey,
    this.videoKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuideDetailScreen(
              title: title,
              image: imageKey,
              tag: tag,
              content: content,
              date: date,
              secondaryImage: secondaryImageKey,
              videoKey: videoKey,
            ),
          ),
        );
      },
      child: Container(
        height: 250,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F7FC),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: FutureBuilder<String>(
                future: context.read<ImageBloc>().getImageUrl(imageKey),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final imageUrl = snapshot.data ?? 'assets/images/image_servicio1.png';
                  return imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('⚠️ Error cargando imagen: $error');
                          return Image.asset(
                            'assets/images/image_servicio1.png',
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        imageUrl,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF0E5D9E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
