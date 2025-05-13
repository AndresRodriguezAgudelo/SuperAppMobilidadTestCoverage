import 'package:flutter/material.dart';

enum CheckboxPosition {
  left,
  right,
}

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final String label;
  final Function(bool) onChanged;
  final CheckboxPosition? position;
  final Color? activeColor;
  final Color? borderColor;
  final Color? textColor;
  final double? fontSize;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.position,
    this.activeColor,
    this.borderColor,
    this.textColor,
    this.fontSize,
  });

  Widget _buildCheckbox() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(
          color: value 
              ? (activeColor ?? const Color(0xFF38A8E0))
              : (borderColor ?? const Color(0xFF9CA3AF)),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
        color: value 
            ? (activeColor ?? const Color(0xFF38A8E0))
            : Colors.white,
      ),
      child: value
          ? const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget _buildLabel() {
    return Text(
      label,
      style: TextStyle(
        fontSize: fontSize ?? 14,
        color: textColor ?? const Color(0xFF1E3340),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = position == CheckboxPosition.right
        ? [Expanded(child: _buildLabel()), const SizedBox(width: 12), _buildCheckbox()]
        : [_buildCheckbox(), const SizedBox(width: 12), Expanded(child: _buildLabel())];

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: children,
      ),
    );
  }
}
