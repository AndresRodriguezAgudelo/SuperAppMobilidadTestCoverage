import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputCode extends StatefulWidget {
  final Function(String) onCompleted;
  final bool enabled;

  const InputCode({
    super.key,
    required this.onCompleted,
    this.enabled = true,
  });

  @override
  State<InputCode> createState() => _InputCodeState();
}

class _InputCodeState extends State<InputCode> {
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1) {
      // Si se ingresó un dígito, mover al siguiente campo
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Si es el último campo, verificar si tenemos todos los dígitos
        _checkComplete();
      }
    } else if (value.isEmpty && index > 0) {
      // Si se borró un dígito, mover al campo anterior
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _checkComplete() {
    String code = _controllers.map((c) => c.text).join();
    if (code.length == 4) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        4,
        (index) => SizedBox(
          width: 64,
          height: 64,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            enabled: widget.enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor:const Color.fromARGB(255, 241, 241, 241),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) => _onCodeChanged(value, index),
          ),
        ),
      ),
    );
  }
}
