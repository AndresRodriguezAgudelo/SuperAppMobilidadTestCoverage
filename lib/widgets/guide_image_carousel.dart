import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../BLoC/images/image_bloc.dart';

class GuideImageCarousel extends StatefulWidget {
  final String mainImageKey;
  final String secondaryImageKey;

  const GuideImageCarousel({
    super.key,
    required this.mainImageKey,
    required this.secondaryImageKey,
  });

  @override
  State<GuideImageCarousel> createState() => _GuideImageCarouselState();
}

class _GuideImageCarouselState extends State<GuideImageCarousel> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  List<String> _imageKeys = [];
  List<String?> _imageUrls = [];
  bool _imagesLoaded = false;

  @override
  void initState() {
    super.initState();
    _imageKeys = [widget.mainImageKey, widget.secondaryImageKey];
    _loadImages();
  }

  Future<void> _loadImages() async {
    final imageBloc = context.read<ImageBloc>();
    _imageUrls = [];
    
    for (var key in _imageKeys) {
      try {
        final url = await imageBloc.getImageUrl(key);
        _imageUrls.add(url);
      } catch (e) {
        print('⚠️ Error cargando imagen: $e');
        _imageUrls.add('assets/images/image_servicio1.png');
      }
    }
    
    if (mounted) {
      setState(() {
        _imagesLoaded = true;
      });
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _imageUrls.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_imagesLoaded) {
      return const SizedBox(
        width: double.infinity,
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemCount: _imageUrls.length,
            dragStartBehavior: DragStartBehavior.down,
            itemBuilder: (context, index) {
              final imageUrl = _imageUrls[index] ?? 'assets/images/image_servicio1.png';
              return Listener(
                onPointerDown: (_) => _autoScrollTimer?.cancel(),
                onPointerUp: (_) => Future.delayed(
                  const Duration(milliseconds: 200),
                  _startAutoScroll,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('⚠️ Error mostrando imagen: $error');
                          return Image.asset(
                            'assets/images/image_servicio1.png',
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Indicadores
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _imageUrls.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? const Color(0xFF0E5D9E)
                    : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
