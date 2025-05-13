import 'package:flutter/material.dart';

class ConfirmationModal extends StatefulWidget {
  final int attitude;
  final String label;

  const ConfirmationModal({
    super.key,
    required this.attitude,
    required this.label,
  });

  @override
  State<ConfirmationModal> createState() => _ConfirmationModalState();
}

class _ConfirmationModalState extends State<ConfirmationModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _position = Tween<Offset>(
      begin: Offset(0.0, widget.attitude == 1 ? -1.0 : 1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeModal() {
    _controller.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.attitude == 1;
    final statusColor = isPositive ? const Color(0xFF319E7C) : const Color(0xFFE05C3A);
    final backgroundColor = isPositive ? const Color(0xFFECFAD7) : const Color(0xFFFADDD7);

    return SlideTransition(
      position: _position,
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: EdgeInsets.only(
            top: isPositive ? 16 : 0,
            bottom: !isPositive ? 16 : 0,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive ? Icons.check : Icons.cancel,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _closeModal,
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF1E3340),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showConfirmationModal(BuildContext context, {
  required int attitude,
  required String label,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) => Align(
      alignment: attitude == 1 ? Alignment.topCenter : Alignment.bottomCenter,
      child: ConfirmationModal(
        attitude: attitude,
        label: label,
      ),
    ),
  );
}
