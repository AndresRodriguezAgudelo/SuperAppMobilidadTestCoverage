import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../BLoC/images/image_bloc.dart';
import '../screens/video_player_web_view_screen.dart';

class GuideVideoPlayer extends StatefulWidget {
  final String videoKey;

  const GuideVideoPlayer({
    super.key,
    required this.videoKey,
  });

  @override
  State<GuideVideoPlayer> createState() => _GuideVideoPlayerState();
}

class _GuideVideoPlayerState extends State<GuideVideoPlayer> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    _loadVideoUrl();
  }

  Future<void> _loadVideoUrl() async {
    try {
      // Obtener la URL del video
      final imageBloc = context.read<ImageBloc>();
      debugPrint('🎬 Intentando cargar video con key: ${widget.videoKey}');
      _videoUrl = await imageBloc.getImageUrl(widget.videoKey, forceRefresh: true);
      
      debugPrint('🎬 URL del video obtenida: $_videoUrl');
      
      if (_videoUrl == null || _videoUrl!.isEmpty || _videoUrl!.contains('assets/images')) {
        debugPrint('⚠️ URL de video inválida o es una imagen por defecto');
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      // Asegurarse de que la URL sea válida para video
      if (!_videoUrl!.startsWith('http')) {
        debugPrint('⚠️ URL de video no comienza con http: $_videoUrl');
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _isLoading = false;
      });
      
    } catch (e) {
      debugPrint('❌ Error cargando URL del video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _openVideoPlayer() {
    if (_videoUrl != null && _videoUrl!.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerWebViewScreen(
            url: _videoUrl!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar indicador de carga mientras se obtiene la URL del video
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Mostrar mensaje de error si hubo problemas al cargar el video
    if (_hasError) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No se pudo cargar el video'),
            ],
          ),
        ),
      );
    }

    // Mostrar tarjeta con vista previa del video y botón para reproducirlo
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(_videoUrl!.replaceAll('.mp4', '.webp')),
          fit: BoxFit.cover,
          onError: (_, __) {}, // Ignorar errores de carga de imagen
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openVideoPlayer,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Botón de reproducción
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              // Texto informativo en la parte inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Toca para reproducir el video',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
