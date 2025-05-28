import 'package:flutter/material.dart';

class InputSelect extends StatefulWidget {
  final String label;
  final List<String> options;
  final Function(String, bool) onChanged;
  final String? initialValue;

  const InputSelect({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<InputSelect> createState() => _InputSelectState();
}

class _InputSelectState extends State<InputSelect> {
  String? _selectedOption;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _selectedOption = widget.initialValue;
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Calcular la altura del modal basada en la cantidad de opciones
  double _calculateModalHeight(BuildContext context) {
    // Altura estimada para cada opción (altura del ListTile + espaciado)
    const double optionHeight = 56.0;
    
    // Altura para el encabezado (título + indicador de arrastre + padding)
    const double headerHeight = 80.0;
    
    // Altura para el padding inferior
    const double bottomPadding = 60.0;
    
    // Calcular altura basada en la cantidad de opciones (máximo 9)
    final int visibleOptions = widget.options.length > 9 ? 9 : widget.options.length;
    final double contentHeight = headerHeight + (visibleOptions * optionHeight) + bottomPadding;
    
    // Limitar la altura máxima al 70% de la pantalla
    final double maxHeight = MediaQuery.of(context).size.height * 0.7;
    
    // Retornar el mínimo entre la altura calculada y la altura máxima
    return contentHeight < maxHeight ? contentHeight : maxHeight;
  }

  void _showOptionsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(0, 255, 10, 10),
      builder: (context) => Container(
        // Altura dinámica basada en la cantidad de opciones (máximo 9 opciones visibles)
        height: _calculateModalHeight(context),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.options.length,
                itemBuilder: (context, index) {
                  final option = widget.options[index];
                  final isSelected = _selectedOption == option;
                  return ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF38A8E0),
                          width: 2,
                        ),
                        color: isSelected ? const Color(0xFF38A8E0) : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    title: Text(option),
                    onTap: () {
                      setState(() {
                        _selectedOption = option;
                        _controller.text = option;
                      });
                      widget.onChanged(option, true);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          readOnly: true,
          onTap: _showOptionsModal,
          decoration: InputDecoration(
            //hintText: 'Selecciona ${widget.label.toLowerCase()}',
            hintText: 'Selecciona',
            suffixIcon: const Icon(Icons.keyboard_arrow_down),
            filled: true,
            fillColor: const Color.fromARGB(255, 241, 241, 241),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
