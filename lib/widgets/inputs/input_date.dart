import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InputDate extends StatelessWidget {
  final String label;
  final DateTime? value;
  final Function(DateTime) onChanged;
  final bool isRequired;
  final String? errorText;

  const InputDate({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isRequired = false,
    this.errorText,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    // Definir la fecha mínima permitida (1 año atrás)
    final DateTime firstDate = DateTime(now.year - 1, now.month, now.day);
    // Definir la fecha máxima permitida (5 años en el futuro)
    final DateTime maxDate = DateTime.now().add(const Duration(days: 365 * 5));
    
    // Verificar si la fecha inicial es válida
    DateTime initialDate;
    if (value != null) {
      // Verificar que la fecha esté dentro del rango permitido
      if (value!.isAfter(maxDate)) {
        print('⚠️ Fecha inicial ($value) posterior a fecha máxima ($maxDate), usando fecha máxima');
        initialDate = maxDate;
      } else if (value!.isBefore(firstDate)) {
        print('⚠️ Fecha inicial ($value) anterior a fecha mínima ($firstDate), usando fecha mínima');
        initialDate = now;
      } else {
        initialDate = value!;
      }
    } else {
      initialDate = now;
    }
    
    print('📅 Selector de fecha - Fecha inicial: $initialDate, Mínima: $firstDate, Máxima: $maxDate');
    
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: maxDate,
        cancelText: 'CANCELAR',
        confirmText: 'ACEPTAR',
        locale: const Locale('es', 'ES'), // Establece el idioma en español
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF38A8E0),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Color(0xFF1E3340),
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        onChanged(picked);
      }
    } catch (e) {
      print('❌ Error al mostrar el selector de fecha: $e');
      // Mostrar un diálogo de error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('No se pudo mostrar el selector de fecha: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(247, 247, 247, 1.0),
              border: Border.all(
                color: errorText != null ? Colors.red : const Color.fromARGB(255, 255, 255, 255),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                 (value != null && value!.year > 1970)
                      ? DateFormat('dd/MM/yyyy').format(value!)
                      : 'Selecciona',
                  style: TextStyle(
                    fontSize: 16,
                    color: value != null
                        ? const Color(0xFF1E3340)
                        : const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color.fromARGB(255, 35, 35, 35),
                  size: 25,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}
