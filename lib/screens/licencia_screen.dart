import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/alertas/recordatorios_adicionales.dart';
import '../widgets/inputs/input_select.dart';
import '../widgets/button.dart';

// Modelos
class LicenciaCategoria {
  final String categoria;
  final String servicio;
  final String status;
  final DateTime fechaVencimiento;
  final DateTime? ultimaActualizacion;

  LicenciaCategoria({
    required this.categoria,
    required this.servicio,
    required this.status,
    required this.fechaVencimiento,
    this.ultimaActualizacion,
  });
}

class LicenciaModel {
  final List<LicenciaCategoria> categorias;
  final bool puedeRenovar;
  final DateTime? fechaRenovacionDisponible;

  LicenciaModel({
    required this.categorias,
    required this.puedeRenovar,
    this.fechaRenovacionDisponible,
  });
}

class Usuario {
  final String nombre;
  final LicenciaModel licencia;

  Usuario({
    required this.nombre,
    required this.licencia,
  });
}

// Datos de prueba
final dataTest = [
  Usuario(
    nombre: 'Andres',
    licencia: LicenciaModel(
      categorias: [
        LicenciaCategoria(
          categoria: 'B2',
          servicio: 'Particul',
          status: 'Vigente',
          fechaVencimiento: DateTime(2026, 1, 21),          
          ultimaActualizacion: DateTime(2025, 1, 8, 10, 31),
        ),
      ],
      puedeRenovar: false,
      fechaRenovacionDisponible: DateTime(2025, 10, 7),
    ),
  ),
  Usuario(
    nombre: 'Alvaro',
    licencia: LicenciaModel(
      categorias: [
        LicenciaCategoria(
          categoria: 'B2',
          servicio: 'Particular',
          status: 'Vigente',
          fechaVencimiento: DateTime(2026, 1, 21),
        ),
        LicenciaCategoria(
          categoria: 'C1',
          servicio: 'Público',
          status: 'Por vencer',
          fechaVencimiento: DateTime(2024, 3, 15),
          ultimaActualizacion: DateTime(2025, 1, 8, 10, 31),
        ),
        LicenciaCategoria(
          categoria: 'A2',
          servicio: 'Particular',
          status: 'Vencido',
          fechaVencimiento: DateTime(2023, 12, 31),
          ultimaActualizacion: DateTime(2025, 1, 8, 10, 31),
        ),
      ],
      puedeRenovar: true,
      fechaRenovacionDisponible: DateTime(2024, 11, 15),
    ),
  ),
];

class LicenciaScreen extends StatefulWidget {
  const LicenciaScreen({super.key});
  
  // Por ahora usamos a Andres
  static final usuarioActual = dataTest[0];
  
  @override
  State<LicenciaScreen> createState() => _LicenciaScreenState();
}

class _LicenciaScreenState extends State<LicenciaScreen> {
  final List<Map<String, dynamic>> _selectedReminders = [
    {'days': 1},
    {'days': 7},
    {'days': 15},
    {'days': 30}
  ];
  late LicenciaCategoria _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _categoriaSeleccionada = LicenciaScreen.usuarioActual.licencia.categorias[0];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          // Asegurarse de que la UI refleje la categoría inicial
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          children: [
            TopBar(
              screenType: ScreenType.progressScreen,
              title: 'Licencia de Conducción',
              onBackPressed: () => Navigator.pop(context),
              actionItems: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 24),
                    child: SizedBox(
                      height: 24,
                      child: Center(
                        child: Text(
                          _categoriaSeleccionada.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Renueve su licencia de conducción a tiempo y Evite Sanciones! Aplica T&C',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3340),
              ),
            ),
            const SizedBox(height: 24),
            if (LicenciaScreen.usuarioActual.licencia.categorias.length == 1)
              // Vista horizontal para una sola categoría
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.card_membership,
                      title: 'Categoría',
                      subtitle: _categoriaSeleccionada.categoria,
                      backgroundColor: const Color(0xFFE8F7FC),
                      iconBackgroundColor: const Color(0xFF0E5D9E),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.directions_car,
                      title: 'Servicio',
                      subtitle: _categoriaSeleccionada.servicio,
                      backgroundColor: const Color(0xFFE8F7FC),
                      iconBackgroundColor: const Color(0xFF0E5D9E),
                    ),
                  ),
                ],
              )
            else
              // Vista vertical para múltiples categorías
              Column(
                children: [
                  _buildCategoriaDropdown(),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.directions_car,
                    title: 'Servicio',
                    subtitle: _categoriaSeleccionada.servicio,
                    backgroundColor: const Color(0xFFE8F7FC),
                    iconBackgroundColor: const Color(0xFF0E5D9E),
                    fullWidth: true,
                  ),
                ],
              ),
            const SizedBox(height: 24),
            _buildInfoCard(
              icon: Icons.access_time,
              title: 'Fecha de vencimiento',
              subtitle: '${_categoriaSeleccionada.fechaVencimiento.day.toString().padLeft(2, '0')}/${_categoriaSeleccionada.fechaVencimiento.month.toString().padLeft(2, '0')}/${_categoriaSeleccionada.fechaVencimiento.year}',
              backgroundColor: const Color(0xFFECFAD7),
              iconBackgroundColor: const Color(0xFF0B9E7C),
              fullWidth: true,
            ),
            const SizedBox(height: 24),
            const Text(
              'Te avisaremos un día antes y el día de vencimiento para que no se te pase.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1E3340),
              ),
            ),
            const SizedBox(height: 16),
            RecordatoriosAdicionales(
              selectedReminders: _selectedReminders,
              onChanged: (List<Map<String, dynamic>> reminders) {
                setState(() {
                  _selectedReminders.clear();
                  _selectedReminders.addAll(reminders);
                });
              },
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              icon: Icons.info_outline,
              title: '¿Renovaste tu licencia?',
              subtitle: LicenciaScreen.usuarioActual.licencia.fechaRenovacionDisponible != null
                  ? 'Puedes refrescar la información manualmente a partir del ${LicenciaScreen.usuarioActual.licencia.fechaRenovacionDisponible!.day.toString().padLeft(2, '0')}/${LicenciaScreen.usuarioActual.licencia.fechaRenovacionDisponible!.month.toString().padLeft(2, '0')}/${LicenciaScreen.usuarioActual.licencia.fechaRenovacionDisponible!.year}, que es un mes antes de la fecha de vencimiento'
                  : 'No es posible renovar en este momento',
              backgroundColor: const Color(0xFFFCECDE),
              iconBackgroundColor: const Color(0xFFF5A462),
              fullWidth: true,
            ),
            if (_categoriaSeleccionada.status.toLowerCase() == 'por vencer' ||
                _categoriaSeleccionada.status.toLowerCase() == 'vencido') ...[              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Última actualización',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8F959E),
                    ),
                  ),
                  Text(
                    _categoriaSeleccionada.ultimaActualizacion != null
                        ? '${_categoriaSeleccionada.ultimaActualizacion!.day.toString().padLeft(2, '0')} ${_categoriaSeleccionada.ultimaActualizacion!.month.toString().padLeft(2, '0')} ${_categoriaSeleccionada.ultimaActualizacion!.year} ${_categoriaSeleccionada.ultimaActualizacion!.hour.toString().padLeft(2, '0')}:${_categoriaSeleccionada.ultimaActualizacion!.minute.toString().padLeft(2, '0')} ${_categoriaSeleccionada.ultimaActualizacion!.hour >= 12 ? 'PM' : 'AM'}'
                        : 'No disponible',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3340),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Button(
                text: 'Refrescar información',
                backgroundColor: const Color(0xFF2FA8E0),
                icon: Icons.refresh_rounded,
                action: () {
                  // acción de refrescar
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_categoriaSeleccionada.status.toLowerCase()) {
      case 'vigente':
        return const Color(0xFF0B9E7C);
      case 'por vencer':
        return const Color(0xFFF5A462);
      case 'vencido':
        return const Color(0xFFE05C3A);
      default:
        return const Color(0xFF0B9E7C);
    }
  }

  Widget _buildCategoriaDropdown() {
    return InputSelect(
      label: 'Categorías',
      options: LicenciaScreen.usuarioActual.licencia.categorias
          .map((cat) => cat.categoria)
          .toList(),
      initialValue: LicenciaScreen.usuarioActual.licencia.categorias[0].categoria,
      onChanged: (String selectedCategoria, bool isSelected) {
        final newCategoria = LicenciaScreen.usuarioActual.licencia.categorias
            .firstWhere((cat) => cat.categoria == selectedCategoria);
        setState(() {
          _categoriaSeleccionada = newCategoria;
        });
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required Color iconBackgroundColor,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: title == '¿Renovaste tu licencia?' ? 18 : 14,
                    color: title == '¿Renovaste tu licencia?' 
                      ? const Color(0xFF1E3340)
                      : const Color(0xFF8F959E),
                    fontWeight: title == '¿Renovaste tu licencia?' 
                      ? FontWeight.w700
                      : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: title == 'Fecha de vencimiento' || (!fullWidth && title != '¿Renovaste tu licencia?') ? 18 : 14,
                    color: const Color(0xFF1E3340),
                    fontWeight: title == 'Fecha de vencimiento' || (!fullWidth && title != '¿Renovaste tu licencia?') ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
