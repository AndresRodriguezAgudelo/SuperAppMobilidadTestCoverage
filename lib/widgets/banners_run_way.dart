import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'banner.dart';

class BannerRunWay extends StatefulWidget {
  const BannerRunWay({super.key});

  @override
  State<BannerRunWay> createState() => _BannerRunWayState();
}

class _BannerRunWayState extends State<BannerRunWay> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  final List<BannerItem> _banners = [
    BannerItem(
        title: '',
        message: '',
        imagePath: 'assets/images/porHoras.png',
        url: 'https://www.equirent.com.co/alquiler-por-horas/home-carsharing'),
    BannerItem(
        title: '',
        message: '',
        imagePath: 'assets/images/porDias.png',
        url: 'https://www.equirent.com.co/alquiler-por-dias/home-car-rental-personas'),
    BannerItem(
        title: '',
        message: '',
        imagePath: 'assets/images/porYears.png',
        url: 'https://www.equirent.com.co/alquiler-por-meses/home-alquiler-personas-por-meses'),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
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
      if (_currentPage < _banners.length - 1) {
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
    return Column(
      children: [
        SizedBox(
          height: 128,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemCount: _banners.length,
            dragStartBehavior: DragStartBehavior.down,
            itemBuilder: (context, index) {
              return Listener(
                onPointerDown: (_) => _autoScrollTimer?.cancel(),
                onPointerUp: (_) => Future.delayed(
                  const Duration(milliseconds: 200),
                  _startAutoScroll,
                ),
                child: BannerWidget(item: _banners[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Indicadores
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? const Color(0xFF1E5E9E)
                    : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
