import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para FilteringTextInputFormatter

enum InputType {
  text,
  email,
  plateCar,
  id,
  name,
}

class InputText extends StatefulWidget {
  final String label;
  final InputType type;
  final Function(String, bool) onChanged;
  final String? defaultValue;
  final bool enabled;

  const InputText({
    super.key,
    required this.label,
    required this.type,
    required this.onChanged,
    this.defaultValue,
    this.enabled = true,
  });

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  final _controller = TextEditingController();
  bool _isValid = true;
  bool _isDirty =
      false; // Para rastrear si el usuario ha interactuado con el campo

  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  final RegExp _specialCharRegex = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
  
  // Caracteres no permitidos en correos electrónicos (letras, números, puntos, guiones y @)
  final RegExp invalidEmailCharsRegex = RegExp(r'[^\w@.-]');
  
  // Expresión regular para detectar espacios en correos
  final RegExp emailSpacesRegex = RegExp(r'\s');

  // Expresión regular para validar placas colombianas: 3 letras seguidas de 3 números
  // Formato: ABC123 o ABC 123 (con o sin espacio)
  final RegExp _plateCarRegex = RegExp(
    r'^[A-Za-z]{3}\s?[0-9]{3}$',
  );

  // Expresión regular para validar documentos de identidad colombianos
  // Puede tener 5-11 dígitos, o 5-6 dígitos seguidos de guión y 5 dígitos más
  final RegExp _idRegex = RegExp(
    r'^((\d{5,11})|(\d{5,6}-\d{5}))?$',
  );

  @override
  void initState() {
    super.initState();
    if (widget.defaultValue != null) {
      _controller.text = widget.defaultValue!;
      // Validamos sin llamar a setState
      _isValid = _validateValue(widget.defaultValue!);
      // Notificamos el valor inicial
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged(widget.defaultValue!, _isValid);
      });
    }
  }

bool _validateValue(String value) {
  String trimmedValue = value.trim();

  if (trimmedValue.isEmpty) {
    return false; // No se permite campo vacío
  }

  if (_specialCharRegex.hasMatch(trimmedValue) && widget.type != InputType.email) {
    return false; // Solo aplica para tipos que no sean correo
  }

  if (widget.type == InputType.email) {
    if (trimmedValue.length > 254) {
      return false;
    }
    if (emailSpacesRegex.hasMatch(trimmedValue) || invalidEmailCharsRegex.hasMatch(trimmedValue)) {
      return false;
    }
    if (!_emailRegex.hasMatch(trimmedValue)) {
      return false;
    }
  }

  if (widget.type == InputType.plateCar) {
    // Verificar si contiene caracteres especiales o espacios incorrectos
    if (_specialCharRegex.hasMatch(trimmedValue)) {
      return false; // No se permiten caracteres especiales en placas
    }
    
    if (trimmedValue.length < 6 || trimmedValue.length > 7) {
      return false;
    }
    if (!_plateCarRegex.hasMatch(trimmedValue.toUpperCase())) {
      return false;
    }
  }

  if (widget.type == InputType.id) {
    return _idRegex.hasMatch(trimmedValue);
  }

  if (widget.type == InputType.name) {
    final RegExp nameRegex = RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÑñ ]+$');
    final RegExp noConsecutiveSpacesRegex = RegExp(r'^(?!.* {2,})[A-Za-zÁÉÍÓÚáéíóúÑñ ]+$');
    
    if (!nameRegex.hasMatch(trimmedValue)) {
      return false; // Solo debe contener letras y espacios
    }
    if (trimmedValue.length < 2) {
      return false; // Debe tener al menos 2 caracteres
    }
    if (trimmedValue.length > 50) {
      return false; // No puede tener más de 50 caracteres
    }
    if (trimmedValue.trim().isEmpty) {
      return false; // No puede ser solo espacios
    }
    if (!noConsecutiveSpacesRegex.hasMatch(trimmedValue)) {
      return false; // No puede contener espacios consecutivos
    }
  }

  return true;
}

  void _handleChange(String value) {
    // Marcar el campo como "sucio" (el usuario ha interactuado con él)
    setState(() {
      _isDirty = true;
      _isValid = _validateValue(value);
    });

    widget.onChanged(value, _isValid);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Función para obtener el texto de ayuda según el tipo de input
  String _getHintText() {
    // Usamos un mapa para evitar el error de lint con el switch
    final Map<InputType, String> hintTexts = {
      InputType.plateCar: 'Ingresa la placa del vehículo',
      InputType.id:
          'Ingresa el número de documento del propietario del vehículo',
      InputType.email: 'Ingresa tu correo electrónico',
      InputType.text: 'Ingresa texto',
    };

    // Retornamos el texto correspondiente al tipo o un valor por defecto
    return hintTexts[widget.type] ?? 'Ingresa la información';
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el texto de ayuda
    final String hintText = _getHintText();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onChanged: _handleChange,
          enabled: widget.enabled,
          keyboardType: widget.type == InputType.email
              ? TextInputType.emailAddress
              : (widget.type == InputType.plateCar ||
                      widget.type == InputType.id)
                  ? TextInputType.text
                  : TextInputType.text,
          textCapitalization: widget.type == InputType.plateCar
              ? TextCapitalization.characters
              : TextCapitalization.none,
          inputFormatters: widget.type == InputType.id
              ? [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))
                ] // Solo permitir números y guiones para documentos de identidad
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.enabled
                ? const Color.fromARGB(255, 241, 241, 241)
                : const Color.fromARGB(255, 230, 230, 230),
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            // Configuración para permitir que los mensajes de error hagan salto de línea
            errorMaxLines:
                3, // Permitir hasta 3 líneas para el mensaje de error
            // Estilo personalizado para el texto de error
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              height: 1.2, // Espacio entre líneas más compacto
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorText: (_isDirty && !_isValid)
                ? (_controller.text.isEmpty)
                    ? 'ⓘ Ese campo es obligatorio.'
                    : widget.type == InputType.email && _controller.text.trim().length > 254
                        ? 'ⓘ El correo no puede tener más de 254 caracteres.'
                        : widget.type == InputType.email && emailSpacesRegex.hasMatch(_controller.text.trim())
                            ? 'ⓘ El correo solo puede contener letras, números, puntos, guiones y un "@".'
                        : widget.type == InputType.email && invalidEmailCharsRegex.hasMatch(_controller.text.trim())
                            ? 'ⓘ El correo solo puede contener letras, números, puntos, guiones y un "@".'
                            : widget.type == InputType.email && !_emailRegex.hasMatch(_controller.text.trim())
                                ? 'ⓘ Ingresa un correo válido, por ejemplo, usuario@dominio.com'
                                : widget.type == InputType.plateCar && _specialCharRegex.hasMatch(_controller.text.trim())
                                    ? 'ⓘ La placa solo puede contener letras y números, sin caracteres especiales ni espacios'
                                    : widget.type == InputType.plateCar && (_controller.text.trim().length < 6 || _controller.text.trim().length > 7)
                                        ? 'ⓘ La placa debe tener entre 6 y 7 caracteres.'
                                        : widget.type == InputType.plateCar && !_plateCarRegex.hasMatch(_controller.text.trim().toUpperCase())
                                            ? 'ⓘ Ingresa una placa válida en el formato correcto (ABC123).'
                                        : widget.type == InputType.id
                                            ? 'ⓘ Documento inválido. Formato incorrecto.'
                                            : widget.type == InputType.name && _controller.text.trim().length < 2
                                                ? 'ⓘ El nombre debe tener al menos 2 caracteres'
                                                : widget.type == InputType.name && !RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÑñ ]+$').hasMatch(_controller.text.trim())
                                                    ? 'ⓘ El nombre solo puede contener letras y espacios'
                                                    : widget.type == InputType.name && _controller.text.trim().length > 50
                                                        ? 'ⓘ El nombre no puede tener más de 50 caracteres'
                                                        : widget.type == InputType.name && !RegExp(r'^(?!.* {2,})[A-Za-zÁÉÍÓÚáéíóúÑñ ]+$').hasMatch(_controller.text.trim())
                                                            ? 'ⓘ El nombre no puede contener espacios consecutivos'
                                                            : 'ⓘ Formato inválido'
                : null,
          ),
        ),
      ],
    );
  }
}
