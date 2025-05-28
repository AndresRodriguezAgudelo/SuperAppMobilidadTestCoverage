import 'package:flutter/material.dart';
import 'button.dart';

class CustomModal extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final String? secondButtonText;
  final VoidCallback? onSecondButtonPressed;
  final Color? iconColor;
  final Color? backgroundIconColor;
  final Color? buttonColor;
  final Color? secondButtonColor;
  final Color? labelButtonColor;
  final Color? labelSecondButtonColor;

  const CustomModal({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.buttonText,
    this.onButtonPressed,
    this.secondButtonText,
    this.onSecondButtonPressed,
    this.iconColor,
    this.backgroundIconColor,
    this.buttonColor,
    this.secondButtonColor,
    this.labelButtonColor,
    this.labelSecondButtonColor,
  });

  static void show({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    required String buttonText,
    VoidCallback? onButtonPressed,
    String? secondButtonText,
    VoidCallback? onSecondButtonPressed,
    Color? iconColor,
    Color? backgroundIconColor,
    Color? buttonColor,
    Color? secondButtonColor,
    Color? labelButtonColor,
    Color? labelSecondButtonColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return CustomModal(
          icon: icon,
          title: title,
          content: content,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed ?? () => Navigator.of(context).pop(),
          secondButtonText: secondButtonText,
          onSecondButtonPressed: onSecondButtonPressed ?? () => Navigator.of(context).pop(),
          iconColor: iconColor,
          backgroundIconColor: backgroundIconColor,
          buttonColor: buttonColor,
          secondButtonColor: secondButtonColor,
          labelButtonColor: labelButtonColor,
          labelSecondButtonColor: labelSecondButtonColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundIconColor ?? Color.fromRGBO(14, 93, 157, 1.0),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 45,
                  color: iconColor ?? Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Button(
              text: buttonText,
              action: onButtonPressed,
              backgroundColor: buttonColor,
              textColor: labelButtonColor,
            ),
            if (secondButtonText != null) ...[
              const SizedBox(height: 12),
              Button(
                text: secondButtonText!,
                action: onSecondButtonPressed,
                backgroundColor: secondButtonColor,
                textColor: labelSecondButtonColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
