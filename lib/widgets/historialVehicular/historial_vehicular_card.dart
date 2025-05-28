import 'package:flutter/material.dart';
import '../notification_card.dart';
import '../button.dart';
import '../../screens/simit_web_view_screen.dart';
import 'package:intl/intl.dart';

class HistorialVehicularCard extends StatefulWidget {
  final Map<String, dynamic>? data;
  final bool isMulta;
  final String? fecha;
  final String? tipoSolicitud;
  final String? estado;
  final String? entidad;
  final String? callToAction;

  const HistorialVehicularCard({
    super.key,
    this.data,
    this.isMulta = false,
    this.fecha,
    this.tipoSolicitud,
    this.estado,
    this.entidad,
    this.callToAction,
  });

  @override
  State<HistorialVehicularCard> createState() => _HistorialVehicularCardState();
}

class _HistorialVehicularCardState extends State<HistorialVehicularCard> {
  bool _isExpanded = false;


  @override
  Widget build(BuildContext context) {
    // Formato personalizado para asegurar que el símbolo $ aparezca antes del valor
    final currencyFormat = NumberFormat('#,###', 'es_CO');
    final currencySymbol = '\$';

    // Si es multa, usamos el nuevo diseño expansible
    if (widget.isMulta) {
      final descripcion = widget.data?['descripcionInfraccion']?.toString() ??
          'Sin descripción';
      final numeroMulta = widget.data?['numeroMulta']?.toString() ?? 'N/A';
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: const Color.fromARGB(255, 249, 222, 216), // Fondo
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16.0),
            child: !_isExpanded
                // CONTRAÍDO
                ? Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 224, 92, 58),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.assignment,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Infracción #$numeroMulta',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      Icon(_isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.black54),
                    ],
                  )
                // EXPANDIDO (por ahora igual que antes, luego lo mejoramos)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 224, 92, 58),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.assignment,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Infracción #$numeroMulta',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const Spacer(),
                          Icon(
                              _isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.black54),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fecha',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            widget.data?['fecha'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pago',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            '$currencySymbol ${currencyFormat.format(widget.data?['valorPagar'] ?? 0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estado',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 224, 92, 58),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Text(
                              widget.data?['estado'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Descripcion',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.data?['descripcionInfraccion'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Button(
                        text: 'Consultar y pagar', 
                        action: () {
                          final placa = widget.data?['placa'] ?? '';
                          if (placa.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SimitWebViewScreen(placa: placa),
                              ),
                            );
                          } else {
                            NotificationCard.showNotification(
                              context: context,
                              isPositive: false,
                              icon: Icons.error_outline,
                              text: 'No se encontró la placa para consultar.',
                              date: DateTime.now(),
                              title: 'Error',
                            );
                          }
                        },
                        backgroundColor: Color.fromARGB(255, 224, 92, 58),
                        icon: Icons.arrow_outward_outlined
                        )
                      // Puedes agregar más detalles aquí en el futuro
                    ],
                  ),
          ),
        ),
      );
    }

    // Comportamiento normal para otras tarjetas

    // Si es multa, mantenemos el diseño/funcionalidad actual
    if (widget.isMulta) {
      final descripcion = widget.data?['descripcionInfraccion']?.toString() ??
          'Sin descripción';
      final numeroMulta = widget.data?['numeroMulta']?.toString() ?? 'N/A';
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: const Color.fromARGB(255, 249, 222, 216),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16.0),
            child: !_isExpanded
                ? Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 224, 92, 58),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.assignment,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Infracción #$numeroMulta',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Infracción #$numeroMulta',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 10),
                      Text(descripcion,
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
          ),
        ),
      );
    }

    // Si NO es multa, la tarjeta es expansible y contraída por defecto
    final tramite = widget.data ?? {};
    String fecha = 'No disponible';
    if (tramite['date'] != null && tramite['date'] != 'No disponible') {
      try {
        final parsed = DateTime.parse(tramite['date']);
        fecha = '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
      } catch (_) {
        fecha = tramite['date'].toString();
      }
    }
    final tipoSolicitud = tramite['requestType']?.toString() ?? 'Sin tipo';
    final entidad = tramite['entity']?.toString() ?? 'Sin entidad';
    final estadoRaw = tramite['status']?.toString() ?? '';
    final tramiteEstado = estadoRaw.isNotEmpty ? estadoRaw : 'Sin estado';
    final tramiteHasEstado = estadoRaw.isNotEmpty;

    Color estadoColor;
    Color cardBgColor;
    switch (estadoRaw.toUpperCase()) {
      case 'APROBADA':
        estadoColor = const Color.fromRGBO(14, 157, 123, 1);
        cardBgColor = const Color(0xFFEcf9d5);
        break;
      case 'RECHAZADA':
        estadoColor = const Color(0xFFE53935);
        cardBgColor = const Color(0xFFF9ded8);
        break;
      default:
        estadoColor = Colors.grey;
        cardBgColor = const Color(0xFFF7F7F7);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: cardBgColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16.0),
          color: cardBgColor,
          child: !_isExpanded
              // CONTRAÍDO
              ? Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: estadoColor, width: 2),
                      ),
                      child: Icon(Icons.assignment, color: estadoColor, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Radicado #${tramite['recordId'] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            Icon( Icons.expand_more,
                          color: Colors.black54),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ],
                )
              // EXPANDIDO
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: estadoColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: estadoColor, width: 2),
                          ),
                          child: Icon(Icons.assignment, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Radicado #${tramite['recordId'] ?? ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Icon( Icons.expand_less,
                          color: Colors.black54),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fecha', style: TextStyle(fontSize: 13)),
                        Text(fecha, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tipo de solicitud', style: TextStyle(fontSize: 13)),
                        Flexible(
                          child: Text(tipoSolicitud, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estado', style: TextStyle(fontSize: 13)),
                                                  Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: estadoColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Text(
                              tramiteEstado,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Entidad', style: TextStyle(fontSize: 13)),
                        Text(
                          entidad,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
