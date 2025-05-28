import 'package:flutter/material.dart';
import '../utils/error_utils.dart';
import 'package:provider/provider.dart';
import '../widgets/button.dart';
import '../widgets/top_bar.dart';
import '../widgets/notification_card.dart';
import '../services/API.dart';
import '../BLoC/auth/auth_context.dart';
import '../widgets/alertas/recordatorios_adicionales.dart';
import '../widgets/banner.dart';
import '../BLoC/special_alerts/special_alerts_bloc.dart';
import '../widgets/loading.dart';

class RTMModel {
  final String numeroPoliza;
  final String aseguradora;
  final String fechaVencimiento;
  final DateTime? ultimaActualizacion;

  RTMModel({
    required this.numeroPoliza,
    required this.aseguradora,
    required this.fechaVencimiento,
    this.ultimaActualizacion,
  });
}

class Usuario {
  final String nombre;
  final RTMModel rtm;

  Usuario({
    required this.nombre,
    required this.rtm,
  });
}

// Datos de prueba
final dataTest = [
  Usuario(
    nombre: 'Andres',
    rtm: RTMModel(
      numeroPoliza: '123456789',
      aseguradora: 'Seguros Bolívar',
      fechaVencimiento: '2024-12-31',
      ultimaActualizacion: DateTime.now(),
    ),
  ),
];

class RTMScreen extends StatefulWidget {
  static Usuario usuarioActual = dataTest[0]; // Usuario de prueba
  final int? alertId;
  final int? vehicleId;

  const RTMScreen({super.key, this.alertId, this.vehicleId});

  @override
  State<RTMScreen> createState() => _RTMScreenState();
}

class _RTMScreenState extends State<RTMScreen> {
  List<Map<String, dynamic>> _selectedReminders =
      []; // Se inicializa vacío y se llenará con los datos del API
  DateTime? get ultimaActualizacion =>
      RTMScreen.usuarioActual.rtm.ultimaActualizacion;
  late final SpecialAlertsBloc _alertsBloc;

  @override
  void initState() {
    super.initState();
    _alertsBloc = SpecialAlertsBloc();

    // Cargar datos cuando se inicia la pantalla
    if (widget.alertId != null) {
      print(
          '\n🔵🔵🔵 RTM_SCREEN: Iniciando carga de alerta ID: ${widget.alertId} 🔵🔵🔵');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        setState(() => isLoading = true);
        await _alertsBloc.loadSpecialAlert(widget.alertId!);
        setState(() => isLoading = false);

        // Actualizar los recordatorios con los datos del API
        if (_alertsBloc.alertData != null &&
            _alertsBloc.alertData!.containsKey('reminders')) {
          final apiReminders =
              _alertsBloc.alertData!['reminders'] as List<dynamic>;
          setState(() {
            _selectedReminders = apiReminders
                .map((reminder) => {'days': reminder['days']})
                .toList();
          });
          print(
              '\n📅 RTM_SCREEN: Recordatorios cargados del API: $_selectedReminders');
        } else {
          print(
              '\n⚠️ RTM_SCREEN: No se encontraron recordatorios en la respuesta del API');
        }
      });
    } else {
      print('\n⚠️⚠️⚠️ RTM_SCREEN: No se proporcionó ID de alerta ⚠️⚠️⚠️');
    }
  }

  @override
  void dispose() {
    _alertsBloc.dispose();
    super.dispose();
  }

  // Los métodos _getStatusColor y _getActionItemText han sido reemplazados
  // por los métodos del bloc: bloc.getRTMStatusColor() y bloc.getRTMStatus()

  void _onRecordatoriosChanged(List<Map<String, dynamic>> newReminders) {
    setState(() {
      _selectedReminders = newReminders;
    });
  }

  Widget _buildInfoContainer({
    required String title,
    required String content,
    required IconData icon,
    Color backgroundColor = const Color(0xFFE8F7FC),
    Color iconBackgroundColor = const Color(0xFF0E5D9E),
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 16),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer2({
    required String title,
    required String content,
    required IconData icon,
    Color backgroundColor = const Color(0xFFE8F7FC),
    Color iconBackgroundColor = const Color(0xFF0E5D9E),
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 16),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(221, 100, 100, 100),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Loading(
        isLoading: isLoading,
        child: ChangeNotifierProvider.value(
          value: _alertsBloc,
          child: Consumer<SpecialAlertsBloc>(
            builder: (context, bloc, _) {
              final alertData = bloc.alertData;

              return Scaffold(
                backgroundColor: Colors.white,
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: TopBar(
                    screenType: ScreenType.expirationScreen, // Cambiado a expirationScreen para siempre navegar al home
                    title: 'RTM',
                    actionItems: [
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: bloc.getRTMStatusColor(),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 24),
                          child: Center(
                            child: Text(
                              bloc.getRTMStatus(),
                              style: const TextStyle(
                                color: Color.fromARGB(221, 255, 255, 255),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: 'La RTM es un ',
                              ),
                              TextSpan(
                                text: 'requisito obligatorio ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text:
                                    'ya que mejora la seguridad vial y reduce el riesgo de siniestros en las carreteras.  Configure esta alerta y agende en su CDA de confianza.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildInfoContainer2(
                        title: 'CDA de la ultima RTM',
                        content: alertData?['lastCDA'] ?? 'No disponible',
                        icon: Icons.construction,
                      ),
                      _buildInfoContainer2(
                        title: 'Fecha de vencimiento',
                        content: alertData != null &&
                                alertData.containsKey('expirationDate')
                            ? bloc.formatExpirationDate(
                                alertData['expirationDate'])
                            : 'No disponible',
                        icon: Icons.access_time_outlined,
                        backgroundColor: bloc.getRTMStatusSubColor(),
                        iconBackgroundColor: bloc.getRTMStatusColor(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 7),
                        child: Row(
                          children: const [
                            Icon(Icons.info, color: Color(0xFF38A8E0)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Te avisaremos un día antes y el día de vencimiento para que no se te pase.',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: RecordatoriosAdicionales(
                          selectedReminders: _selectedReminders,
                          onChanged: _onRecordatoriosChanged,
                          button: true,
                          alertId: widget.alertId,
                          expirationType: 'RTM',
                          onSaveSuccess: () {
                            // Recargar la alerta para mostrar los cambios actualizados
                            if (widget.alertId != null) {
                              bloc.loadSpecialAlert(widget.alertId!);
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                      if (alertData?['hasBanner'] == true) ...[
                        // Solo mostrar si hasBanner es true
                        SizedBox(
                          height: 138,
                          width: double.infinity,
                          child: BannerWidget(
                            item: BannerItem(
                              imagePath: alertData?['imageBanner'] ??
                                  'assets/images/bannerImage.png',
                              title: '',
                              message: '',
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 30),
                      _buildInfoContainer(
                        title: '¿Renovaste tu RTM?',
                        content:
                            'Puedes refrescar la información manualmente un mes antes del vencimiento.',
                        icon: Icons.info_outline,
                        backgroundColor: const Color(0xFFFCECDE),
                        iconBackgroundColor: const Color(0xFFF5A462),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Última actualización',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                if (ultimaActualizacion?.year != null)
                                  Text(
                                    bloc.formatExpirationDate(
                                        alertData?['lastUpdate']),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Button(
                              text: 'Refrescar informacion',
                              icon: Icons.refresh,
                              action: () async {
                                setState(() => isLoading = true);
                                final api = APIService();
                                final token = AuthContext().token;
                                try {
                                  // Verificar los valores que se están pasando
                                  debugPrint('\n💾 RTM_SCREEN: Valores antes de la llamada:');
                                  debugPrint('- alertId: ${widget.alertId}');
                                  debugPrint('- vehicleId: ${widget.vehicleId}');
                                  
                                  // Construir el endpoint para mostrar en los logs
                                  final endpointPath = api.getReloadExpirationEndpoint(
                                    'rtm',
                                    expirationId: widget.alertId,
                                    vehicleId: widget.vehicleId,
                                  );
                                  debugPrint('\n🔗 URL del endpoint: $endpointPath');
                                  
                                  final result = await api.reloadExpiration(
                                    'rtm',
                                    token: token,
                                    expirationId: widget.alertId,
                                    vehicleId: widget.vehicleId, // Incluir el ID del vehículo
                                  );
                                  if (result['success'] == true ||
                                      result['result'] == true) {
                                    if (widget.alertId != null) {
                                      await bloc
                                          .loadSpecialAlert(widget.alertId!);
                                    }
                                  } else {
                                    NotificationCard.showNotification(
                                      context: context,
                                      isPositive: false,
                                      icon: Icons.error,
                                      text: result['message'] ??
                                          'No se pudo refrescar la información.',
                                      date: DateTime.now(),
                                      title: 'Error',
                                    );
                                  }
                                } catch (e) {
                                  // Limpiar el mensaje de error usando ErrorUtils
                                  final cleanedError =
                                      ErrorUtils.cleanErrorMessage(e);

                                  NotificationCard.showNotification(
                                    context: context,
                                    isPositive: false,
                                    icon: Icons.error,
                                    text: cleanedError,
                                    date: DateTime.now(),
                                    title: 'Error',
                                  );
                                } finally {
                                  setState(() => isLoading = false);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
