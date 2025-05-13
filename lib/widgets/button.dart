import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback? action;
  final Color? backgroundColor;
  final double height;
  final IconData? icon;
  final bool isLoading;
  final Color? textColor; // Color del texto del botón
  final String? labelCoro; // Texto adicional para mostrar debajo del botón

  const Button({
    super.key,
    required this.text,
    required this.action,
    this.backgroundColor,
    this.height = 48.0,
    this.icon,
    this.isLoading = false,
    this.textColor, // Color opcional para el texto
    this.labelCoro, // Opcional, para mostrar texto adicional
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: height,
          child: ElevatedButton(
        onPressed: isLoading ? null : action,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFF38A8E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      color: textColor ?? Colors.white,
                      size: 20,
                    ),
                  ],
                ],
              ),
      ),
        ),
        if (labelCoro != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              labelCoro!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}
