import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import '../BLoC/pick_and_plate/pick_and_plate_bloc.dart';

class PicoPlaca extends StatefulWidget {
  const PicoPlaca({super.key});

  @override
  State<PicoPlaca> createState() => _PicoPlacaState();
}

class _PicoPlacaState extends State<PicoPlaca>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late List<DateTime?> _calendarDays;
  
  // Controlador para la animación de parpadeo del día actual
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    print('\n🚦 PICO_PLACA_WIDGET: initState - Inicializando widget');
    initializeDateFormatting('es_ES', null);
    _selectedDate = DateTime.now();
    print('\n🚦 PICO_PLACA_WIDGET: initState - Fecha seleccionada: $_selectedDate');
    _generateCalendarDays();

    // Inicializar el controlador de parpadeo
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _blinkAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(_blinkController);
    
    // Repetir la animación de parpadeo indefinidamente
    _blinkController.repeat(reverse: true);
    
    // Escuchar cambios en el bloc para regenerar el calendario cuando cambie la ciudad o la placa
    Future.microtask(() {
      try {
        final bloc = Provider.of<PeakPlateBloc>(context, listen: false);
        print('\n🚦 PICO_PLACA_WIDGET: initState - Bloc obtenido: ${bloc.hashCode}');
        if (bloc.peakPlateData != null) {
          print('\n🚦 PICO_PLACA_WIDGET: initState - Ya hay datos de pico y placa disponibles');
          // Regenerar el calendario si ya hay datos disponibles
          if (mounted) {
            setState(() {
              _generateCalendarDays();
            });
          }
        }
      } catch (e) {
        print('\n⚠️ PICO_PLACA_WIDGET: initState - Error al obtener el bloc: $e');
      }
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  void _generateCalendarDays() {
    print(
        '\n🚦 PICO_PLACA_WIDGET: _generateCalendarDays - Generando días del calendario');
    _calendarDays = [];

    final DateTime firstDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month, 1);
    final DateTime lastDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    print(
        '\n🚦 PICO_PLACA_WIDGET: _generateCalendarDays - Primer día: $firstDayOfMonth, Último día: $lastDayOfMonth');

    // Agregar espacios vacíos al inicio
    int daysToAdd = firstDayOfMonth.weekday % 7;
    for (int i = 0; i < daysToAdd; i++) {
      _calendarDays.add(null);
    }

    // Agregar días del mes actual
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      _calendarDays.add(DateTime(_selectedDate.year, _selectedDate.month, i));
    }

    // Agregar espacios vacíos al final
    int remainingDays = 7 - (_calendarDays.length % 7);
    if (remainingDays < 7) {
      for (int i = 0; i < remainingDays; i++) {
        _calendarDays.add(null);
      }
    }
  }

  bool _canDrive(BuildContext context, DateTime date) {
    // Usar listen: true para que el widget se reconstruya cuando cambie el bloc
    final bloc = Provider.of<PeakPlateBloc>(context, listen: true);
    final canDrive = bloc.canDriveOnDate(date);
    print('\n🚦 PICO_PLACA_WIDGET: _canDrive - Fecha: $date, ¿Puede circular? $canDrive');
    print('\n🚦 PICO_PLACA_WIDGET: _canDrive - Ciudad: ${bloc.selectedCity != null ? bloc.selectedCity!['cityName'] : 'No seleccionada'}');
    return canDrive;
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el bloc con listen: true para reconstruir cuando cambie
    final bloc = Provider.of<PeakPlateBloc>(context, listen: true);
    print('\n🚦 PICO_PLACA_WIDGET: build - Reconstruyendo widget');
    print('\n🚦 PICO_PLACA_WIDGET: build - Ciudad seleccionada: ${bloc.selectedCity != null ? bloc.selectedCity!['cityName'] : 'No seleccionada'}');
    print('\n🚦 PICO_PLACA_WIDGET: build - Placa: ${bloc.plate ?? 'No establecida'}');
    print('\n🚦 PICO_PLACA_WIDGET: build - ¿Puede circular hoy? ${bloc.canDrive ? 'Sí' : 'No'}');
    
    // Si cambia la ciudad o la placa, regenerar el calendario
    if (bloc.peakPlateData != null) {
      print('\n🚦 PICO_PLACA_WIDGET: build - Hay datos de pico y placa, regenerando calendario');
      _generateCalendarDays();
    }
    
    final monthYear = DateFormat('MMMM yyyy', 'es_ES').format(_selectedDate);
    final formattedMonthYear =
        monthYear[0].toUpperCase() + monthYear.substring(1);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2FA8E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  formattedMonthYear,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Dom'),
                Text('Lun'),
                Text('Mar'),
                Text('Mié'),
                Text('Jue'),
                Text('Vie'),
                Text('Sáb'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _calendarDays.length,
            itemBuilder: (context, index) {
              final date = _calendarDays[index];
              if (date == null) return const SizedBox();
              final canDrive = _canDrive(context, date);
              // Normalizar las fechas para compararlas correctamente (sin hora/minutos/segundos)
              final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
              final normalizedDate = DateTime(date.year, date.month, date.day);
              // Determinar si la fecha es pasada, actual o futura
              final isPastDate = normalizedDate.isBefore(today);
              final isToday = normalizedDate.isAtSameMomentAs(today);
              final isFutureDate = normalizedDate.isAfter(today);
              // Widget condicional según el tipo de fecha
              if (isPastDate) {
                // Para fechas pasadas, mostrar en gris
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.history,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                    ],
                  ),
                );
              } else if (isToday) {
                // Para la fecha actual, usar animación de parpadeo
                return AnimatedBuilder(
                  animation: _blinkAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _blinkAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: canDrive
                              ? const Color(0xFFFADDD7)
                              : const Color(0xFFECFAD7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${date.day}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              canDrive ? Icons.cancel : Icons.check_circle,
                              color: canDrive
                                  ? const Color(0xFFE05C3A)
                                  : const Color(0xFF319E7C),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                // Para fechas futuras, comportamiento normal
                return Container(
                  decoration: BoxDecoration(
                    color: canDrive
                        ? const Color(0xFFFADDD7)
                        : const Color(0xFFECFAD7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        canDrive ? Icons.cancel : Icons.check_circle,
                        color: canDrive
                            ? const Color(0xFFE05C3A)
                            : const Color(0xFF319E7C),
                        size: 16,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
