import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../BLoC/images/image_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Obtener la URL del video
      final imageBloc = context.read<ImageBloc>();
      _videoUrl = await imageBloc.getImageUrl(widget.videoKey);
      
      if (_videoUrl == null || _videoUrl!.isEmpty) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      // Inicializar el controlador de video
      _videoPlayerController = VideoPlayerController.network(_videoUrl!);
      await _videoPlayerController!.initialize();
      
      // Configurar Chewie
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        autoPlay: false,
        looping: false,
        placeholder: const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 32),
                const SizedBox(height: 8),
                Text('Error: $errorMessage'),
              ],
            ),
          );
        },
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('⚠️ Error cargando video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError || _chewieController == null) {
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

    return Container(
      height: 200,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }
}
