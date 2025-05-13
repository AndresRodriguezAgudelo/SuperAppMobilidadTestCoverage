import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/button.dart';
import '../widgets/top_bar.dart';
import '../widgets/alertas/recordatorios_adicionales.dart';
import '../widgets/banner.dart';
import '../BLoC/special_alerts/special_alerts_bloc.dart';
import '../widgets/notification_card.dart';
import '../services/API.dart';
import '../BLoC/auth/auth_context.dart';
import '../widgets/loading.dart';


class SOATScreen extends StatefulWidget {
  final int? alertId;
  final int? vehicleId;
  
  const SOATScreen({super.key, this.alertId, this.vehicleId});

  @override
  State<SOATScreen> createState() => _SOATScreenState();
}

class _SOATScreenState extends State<SOATScreen> {
  List<Map<String, dynamic>> _selectedReminders = []; // Se inicializa vacío y se llenará con los datos del API
  late final SpecialAlertsBloc _alertsBloc;
  
  @override
  void initState() {
    super.initState();
    _alertsBloc = SpecialAlertsBloc();
    
    // Cargar datos cuando se inicia la pantalla
    if (widget.alertId != null) {
      print('\n🔵🔵🔵 SOAT_SCREEN: Iniciando carga de alerta ID: ${widget.alertId} 🔵🔵🔵');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        setState(() => isLoading = true);
        await _alertsBloc.loadSpecialAlert(widget.alertId!);
        setState(() => isLoading = false);
        
        // Actualizar los recordatorios con los datos del API
        if (_alertsBloc.alertData != null && _alertsBloc.alertData!.containsKey('reminders')) {
          final apiReminders = _alertsBloc.alertData!['reminders'] as List<dynamic>;
          setState(() {
            _selectedReminders = apiReminders
                .map((reminder) => {'days': reminder['days']})
                .toList();
          });
          print('\n📅 SOAT_SCREEN: Recordatorios cargados del API: $_selectedReminders');
        } else {
          print('\n⚠️ SOAT_SCREEN: No se encontraron recordatorios en la respuesta del API');
        }
      });
    } else {
      print('\n⚠️⚠️⚠️ SOAT_SCREEN: No se proporcionó ID de alerta ⚠️⚠️⚠️');
    }
  }
  
  @override
  void dispose() {
    _alertsBloc.dispose();
    super.dispose();
  }

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
              size: 20,
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
                    fontWeight: FontWeight.bold,
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
              size: 20,
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
    print('\n🟢🟢🟢 SOAT_SCREEN: Construyendo pantalla SOAT con alertId: ${widget.alertId}');
    
    return Loading(
      isLoading: isLoading,
      child: ChangeNotifierProvider.value(
        value: _alertsBloc,
      child: Consumer<SpecialAlertsBloc>(
        builder: (context, bloc, child) {
          print('\n🟢 SOAT_SCREEN: Estado del bloc - isLoading: ${bloc.isLoading}, hasError: ${bloc.error != null}, alertId: ${bloc.alertId}');
          // No mostramos un loading que ocupe toda la pantalla
          // Solo mostramos indicadores de carga localizados en los componentes que lo necesiten
          
          if (bloc.error != null) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: TopBar(
                  screenType: ScreenType.progressScreen,
                  title: 'SOAT',
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      bloc.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => widget.alertId != null ? bloc.loadSpecialAlert(widget.alertId!) : null,
                      child: const Text('Intentar de nuevo'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          final alertData = bloc.alertData;
          
          // Depuración mejorada
          print('\n📝📝📝 SOAT_SCREEN: DATOS DE ALERTA RECIBIDOS:');
          print('ALERTA ID: ${bloc.alertId}');
          print('TIPO DE DATOS: ${alertData?.runtimeType}');
          print('CONTENIDO COMPLETO: $alertData');
          print('FECHA DE EXPIRACIÓN: ${alertData?['expirationDate']}');
          print('ASEGURADORA: ${alertData?['insurer']}');
          print('NÚMERO DE PÓLIZA: ${alertData?['policyNumber']}');
          print('IMAGEN BANNER: ${alertData?['imageBanner']}');
          
          // Verificar si la imagen existe y no está vacía
          if (alertData != null && alertData['imageBanner'] != null) {
            print('TIPO DE IMAGEN: ${alertData['imageBanner'].runtimeType}');
            print('IMAGEN VACÍA: ${alertData['imageBanner'].toString().isEmpty}');
          } else {
            print('NO HAY IMAGEN EN LOS DATOS');
          }
          
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: TopBar(
                screenType: ScreenType.progressScreen,
                title: 'SOAT',
                actionItems: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: bloc.getSOATStatusColor(),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 24),
                      child: Center(
                        child: Text(
                          bloc.getSOATStatus(),
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
                    child: Text(
                      alertData?['description'] ?? 'El SOAT además de ser un requisito obligatorio, se encarga de salvaguardar la integridad física de los involucrados en un accidente de tránsito, configure esta alerta y RENUÉVELO con nosotros.',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  _buildInfoContainer2(
                    title: 'Número de póliza',
                    content: alertData?['policyNumber'] ?? 'No disponible',
                    icon: Icons.description_outlined,
                  ),
                  _buildInfoContainer2(
                    title: 'Aseguradora',
                    content: alertData?['insurer'] ?? 'No disponible',
                    icon: Icons.business_outlined,
                  ),
                  _buildInfoContainer2(
                    title: 'Fecha de vencimiento',
                    content: alertData != null && alertData.containsKey('expirationDate') 
                        ? bloc.formatExpirationDate(alertData['expirationDate']) 
                        : 'No disponible',
                    icon: Icons.calendar_today_outlined,
                    backgroundColor: bloc.getSOATStatusSubColor(),
                    iconBackgroundColor: bloc.getSOATStatusColor(),
                  ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Te avisaremos un día antes y el día de vencimiento para que no se te pase.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
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
                expirationType: 'SOAT',
                onSaveSuccess: () {
                  // Recargar la alerta para mostrar los cambios actualizados
                  if (widget.alertId != null) {
                    bloc.loadSpecialAlert(widget.alertId!);
                  }
                },
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 138,
              width: double.infinity,
              child: BannerWidget(
                item: BannerItem(
                  imagePath: alertData != null && alertData['imageBanner'] != null && alertData['imageBanner'].toString().isNotEmpty
                    ? alertData['imageBanner']
                    : 'assets/images/BannerSOAT.png',
                  title: '',
                  message: '',
                  url: 'https://apps.clientify.net/forms/simpleembed/#/forms/embedform/228575/39252',
                ),
              ),
            ),
            SizedBox(height: 30),
            _buildInfoContainer(
              title: '¿Renovaste tu SOAT?',
              content: alertData != null && alertData.containsKey('updatedAt')
                  ? 'Puedes refrescar la información manualmente a partir del ${bloc.formatExpirationDate(alertData['updatedAt'])}, un mes antes del vencimiento.'
                  : 'Puedes refrescar la información manualmente un mes antes del vencimiento.',
              icon: Icons.align_vertical_bottom,
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
                        style: TextStyle(color: Colors.black54),
                      ),
                      if (alertData != null && alertData.containsKey('lastUpdate'))
                        Text(
                          bloc.formatExpirationDate(alertData['lastUpdate']),
                          style: 
                          const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Button(
                    text: 'Refrescar información',
                    icon: Icons.refresh,
                    action: () async {
                      setState(() => isLoading = true);
                      final api = APIService();
                      final token = AuthContext().token;
                      try {
                        final result = await api.reloadExpiration(
                          'soat',
                          token: token,
                          expirationId: widget.alertId,
                        );
                        if (result['success'] == true || result['result'] == true) {
                          if (widget.alertId != null) {
                            await bloc.loadSpecialAlert(widget.alertId!);
                          }
                        } else {
                          final message = result['message'] ?? 'No se pudo refrescar la información. Intente más tarde.';
                          NotificationCard.showNotification(
                            context: context,
                            isPositive: false,
                            icon: Icons.error_outline,
                            text: message,
                            date: DateTime.now(),
                            title: 'Error al refrescar',
                            duration: const Duration(seconds: 4),
                          );
                        }
                      } catch (e) {
                        NotificationCard.showNotification(
                          context: context,
                          isPositive: false,
                          icon: Icons.error_outline,
                          text: e.toString(),
                          date: DateTime.now(),
                          title: 'Error de conexión',
                          duration: const Duration(seconds: 4),
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
