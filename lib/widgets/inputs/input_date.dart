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
    final DateTime sevenMonthsAgo = DateTime(now.year, now.month - 12, now.day);
    // Definir la fecha máxima permitida (5 años en el futuro)
    final DateTime maxDate = DateTime.now().add(const Duration(days: 365 * 50));
    
    // Verificar si la fecha inicial es válida
    DateTime initialDate;
    if (value != null) {
      // Si la fecha es posterior a la fecha máxima, usar la fecha máxima
      if (value!.isAfter(maxDate)) {
        print('⚠️ Fecha inicial ($value) posterior a fecha máxima ($maxDate), usando fecha máxima');
        initialDate = maxDate;
      } else {
        initialDate = value!;
      }
    } else {
      initialDate = now;
    }
    
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: sevenMonthsAgo, // Permite seleccionar desde hace 12 meses
        lastDate: maxDate,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E3340),
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
              border: Border.all(
                color: errorText != null ? Colors.red : const Color(0xFFE5E7EB),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null
                      ? DateFormat('dd/MM/yyyy').format(value!)
                      : 'Seleccionar fecha',
                  style: TextStyle(
                    fontSize: 16,
                    color: value != null
                        ? const Color(0xFF1E3340)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF9CA3AF),
                  size: 20,
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
