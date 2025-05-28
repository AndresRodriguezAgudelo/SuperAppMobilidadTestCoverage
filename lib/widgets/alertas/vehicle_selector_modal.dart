import 'package:flutter/material.dart';
import '../button.dart';
import '../../screens/add_vehicle_screen.dart';
import '../modales.dart';

class VehicleSelectorModal extends StatelessWidget {
  final List<String> plates;
  final String selectedPlate;
  final Function(String) onPlateSelected;
  final Function(String) onNewPlateAdded;

  const VehicleSelectorModal({
    super.key,
    required this.plates,
    required this.selectedPlate,
    required this.onPlateSelected,
    required this.onNewPlateAdded,
  });

  static Future<String?> show({
    required BuildContext context,
    required List<String> plates,
    required String selectedPlate,
    required Function(String) onPlateSelected,
    required Function(String) onNewPlateAdded,
  }) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return VehicleSelectorModal(
          plates: plates,
          selectedPlate: selectedPlate,
          onPlateSelected: onPlateSelected,
          onNewPlateAdded: onNewPlateAdded,
        );
      },
    );
  }

  void _showLimitModal(BuildContext context) {
    // Guardamos el contexto de la ruta principal
    final navigator = Navigator.of(context);
    // Cerramos primero la modal de selección
    navigator.pop();
    // Usamos el contexto guardado para mostrar la nueva modal
    CustomModal.show(
      context: context,
      icon: Icons.info_outline,
      iconColor: Colors.white,
      title: 'Límite alcanzado',
      content:
          'Solo puedes agregar hasta 2 vehículos. Si necesitas gestionar otro, elimina uno existente o contáctanos para más opciones',
      buttonText: 'Aceptar',
      onButtonPressed: () => navigator.pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLimitReached = plates.length >= 2;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Vehículos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Botón de cierre (X)
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...plates.map((plate) => RadioListTile(
                  title: Text(plate),
                  value: plate,
                  groupValue: selectedPlate,
                  onChanged: (value) {
                    onPlateSelected(value!);
                    // Cerrar el modal con una ruta nombrada para que didPopNext pueda identificarla
                    Navigator.of(context).pop('/select_plate');
                  },
                )),
            const SizedBox(height: 8),
            if (isLimitReached) ...[
              Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF38A8E0),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      // Usamos Center para centrar el contenido
                      child: Text(
                        'i',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    // Este widget permite que el texto ocupe el espacio restante
                    child: Text(
                      'Solo puedes agregar hasta 2 vehículos. Si necesitas gestionar otro, elimina uno existente.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                      softWrap:
                          true, // El texto se ajusta automáticamente a varias líneas
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Opacity(
              opacity: isLimitReached ? 0.5 : 1.0,
              child: Button(
                text: 'Agregar vehículo',
                action: isLimitReached
                    ? () => _showLimitModal(context)
                    : () async {
                        // Cerrar el modal con una ruta nombrada para que didPopNext pueda identificarla
                        Navigator.of(context).pop('/add_vehicle');

                        // Navegar a la pantalla de agregar vehículo usando rootNavigator
                        // y configurando el nombre de la ruta para que didPopNext pueda identificarla
                        final newPlate =
                            await Navigator.of(context, rootNavigator: true)
                                .push<String>(
                          MaterialPageRoute(
                            settings: const RouteSettings(name: '/add_vehicle'),
                            builder: (ctx) => const AgregarVehiculoScreen(),
                            fullscreenDialog: true,
                          ),
                        );

                        // Si se agregó un nuevo vehículo, actualizar la UI
                        if (newPlate != null && newPlate.isNotEmpty) {
                          onNewPlateAdded(newPlate);
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
