import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../BLoC/images/image_bloc.dart';
import '../widgets/top_bar.dart';
import '../widgets/guide_image_carousel.dart';
import '../widgets/guide_video_player.dart';

class GuideDetailScreen extends StatelessWidget {
  final String title;
  final String image;
  final String tag;
  final String content;
  final String date;
  final String? secondaryImage;
  final String? videoKey;

  const GuideDetailScreen({
    super.key,
    required this.title,
    required this.image,
    required this.tag,
    required this.content,
    required this.date,
    this.secondaryImage,
    this.videoKey,
  });

  bool get hasSecondaryImage => 
      secondaryImage != null && 
      secondaryImage!.isNotEmpty && 
      secondaryImage != " ";

  bool get hasVideo => 
      videoKey != null && 
      videoKey!.isNotEmpty && 
      videoKey != " ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBar(
          screenType: ScreenType.progressScreen,
          title: 'Guía',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Mostrar carrusel si hay imagen secundaria, de lo contrario mostrar solo la imagen principal
              hasSecondaryImage
                  ? GuideImageCarousel(
                      mainImageKey: image,
                      secondaryImageKey: secondaryImage!,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FutureBuilder<String>(
                        future: context.read<ImageBloc>().getImageUrl(image),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              width: double.infinity,
                              height: 200,
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
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('⚠️ Error cargando imagen: $error');
                                  return Image.asset(
                                    'assets/images/image_servicio1.png',
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                imageUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              );
                        },
                      ),
                    ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E5D9E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              // Mostrar reproductor de video si existe la clave de video
              if (hasVideo) ...[                
                const SizedBox(height: 24),
                GuideVideoPlayer(videoKey: videoKey!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
