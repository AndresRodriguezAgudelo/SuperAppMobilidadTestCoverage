import 'package:flutter/material.dart';
import '../inputs/input_checkbox.dart';
import '../button.dart';
import '../notification_card.dart';
import '../../BLoC/special_alerts/special_alerts_bloc.dart';

class RecordatoriosAdicionales extends StatefulWidget {
  // Ahora aceptamos una lista de objetos Map con la propiedad 'days'
  final List<Map<String, dynamic>> selectedReminders;
  // La función onChanged ahora devuelve una lista de objetos Map con la propiedad 'days'
  final Function(List<Map<String, dynamic>>) onChanged;
  // Indica si se debe mostrar un botón de guardar
  final bool button;
  // ID de la alerta (necesario para guardar en el backend)
  final int? alertId;
  // Tipo de expiración (SOAT o RTM)
  final String? expirationType;
  // Callback para cuando se guarda exitosamente
  final Function()? onSaveSuccess;

  const RecordatoriosAdicionales({
    super.key,
    required this.selectedReminders,
    required this.onChanged,
    this.button = false,
    this.alertId,
    this.expirationType,
    this.onSaveSuccess,
  });

  @override
  State<RecordatoriosAdicionales> createState() => _RecordatoriosAdicionalesState();
}

class _RecordatoriosAdicionalesState extends State<RecordatoriosAdicionales> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  
  // Para manejar el estado de carga del botón
  bool _isSaving = false;
  // Instancia del bloc para interactuar con el backend
  late final SpecialAlertsBloc _alertsBloc;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    // Inicializar el bloc
    _alertsBloc = SpecialAlertsBloc();
  }

  @override
  void dispose() {
    _controller.dispose();
    // No hacemos dispose del bloc porque es un singleton
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _toggleOption(int days) {
    // Crear una copia de la lista actual de recordatorios
    final newSelection = List<Map<String, dynamic>>.from(widget.selectedReminders);
    
    // Buscar si ya existe un recordatorio con el mismo número de días
    final existingIndex = newSelection.indexWhere((reminder) => reminder['days'] == days);
    
    if (existingIndex >= 0) {
      // Si existe, lo eliminamos
      newSelection.removeAt(existingIndex);
    } else {
      // Si no existe, añadimos uno nuevo
      newSelection.add({'days': days});
    }
    
    // Notificar el cambio
    widget.onChanged(newSelection);
  }
  
  // Método para guardar los recordatorios en el backend
  void _saveReminders() async {
    // Verificar que tenemos la información necesaria
    if (widget.alertId == null) {
      // Mostrar un mensaje de error usando NotificationCard
      NotificationCard.showNotification(
        context: context,
        isPositive: false,
        icon: Icons.error,
        text: 'No se puede guardar: falta información necesaria',
        date: DateTime.now(),
        title: 'Error',
      );
      return;
    }
    
    // Actualizar el estado para mostrar el indicador de carga
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Llamar al método del bloc para actualizar solo los recordatorios
      final success = await _alertsBloc.updateSOATandRTM(
        widget.alertId!,
        reminders: widget.selectedReminders,
      );
      
      // Actualizar el estado para quitar el indicador de carga
      setState(() {
        _isSaving = false;
      });
      
      // Mostrar un mensaje de éxito o error usando NotificationCard
      if (success) {
        NotificationCard.showNotification(
          context: context,
          isPositive: true,
          icon: Icons.check_circle,
          text: 'Recordatorios guardados correctamente',
          date: DateTime.now(),
          title: 'Éxito',
        );
        
        // Llamar al callback de éxito si existe
        if (widget.onSaveSuccess != null) {
          widget.onSaveSuccess!();
        }
      } else {
        NotificationCard.showNotification(
          context: context,
          isPositive: false,
          icon: Icons.error,
          text: 'Error al guardar los recordatorios',
          date: DateTime.now(),
          title: 'Error',
        );
      }
    } catch (e) {
      // En caso de error, actualizar el estado y mostrar un mensaje usando NotificationCard
      setState(() {
        _isSaving = false;
      });
      
      NotificationCard.showNotification(
        context: context,
        isPositive: false,
        icon: Icons.error,
        text: 'Error: ${e.toString()}',
        date: DateTime.now(),
        title: 'Error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7FC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2FA8E0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.alarm,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Recordatorios adicionales',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3340),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _isExpanded ? 0.5 : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF1E3340),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                children: [
                  const Divider(height: 1, color: Color(0xFFD1D5DB)),
                  const SizedBox(height: 16),
                  InputCheckbox(
                    value: widget.selectedReminders.any((reminder) => reminder['days'] == 3),
                    label: 'Recordar 3 días antes',
                    onChanged: (value) => _toggleOption(3),
                    position: CheckboxPosition.right,
                  ),
                  const SizedBox(height: 12),
                  InputCheckbox(
                    value: widget.selectedReminders.any((reminder) => reminder['days'] == 5),
                    label: 'Recordar 5 días antes',
                    onChanged: (value) => _toggleOption(5),
                    position: CheckboxPosition.right,
                  ),
                  const SizedBox(height: 12),
                  InputCheckbox(
                    value: widget.selectedReminders.any((reminder) => reminder['days'] == 7),
                    label: 'Recordar 7 días antes',
                    onChanged: (value) => _toggleOption(7),
                    position: CheckboxPosition.right,
                  ),
                  const SizedBox(height: 12),
                  InputCheckbox(
                    value: widget.selectedReminders.any((reminder) => reminder['days'] == 30),
                    label: 'Recordar 30 días antes',
                    onChanged: (value) => _toggleOption(30),
                    position: CheckboxPosition.right,
                  ),
                  
                  // Mostrar el botón de guardar si la propiedad button es true
                  if (widget.button) ...[  
                    const SizedBox(height: 20),
                    Button(
                      text: 'Guardar',
                      isLoading: _isSaving,
                      action: _saveReminders,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
