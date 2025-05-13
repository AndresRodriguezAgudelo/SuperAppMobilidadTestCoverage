import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Equirent_Mobility/BLoC/alerts/alerts_bloc.dart';
import 'package:Equirent_Mobility/BLoC/services/services_bloc.dart';
import 'package:Equirent_Mobility/screens/guias_screen.dart';
import '../widgets/top_bar.dart';
import '../widgets/leftMenu/left_menu.dart';
import '../widgets/banners_run_way.dart';
import '../widgets/alertas/alertas.dart';
import '../widgets/nuestrosServicios/our_services.dart';
import '../BLoC/home/home_bloc.dart';
import 'package:Equirent_Mobility/widgets/loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();


}

class HomeScreenState extends State<HomeScreen> with RouteAware {
  String? lastPopSource;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeBloc = Provider.of<HomeBloc>(context, listen: false);
      final servicesBloc = Provider.of<ServicesBloc>(context, listen: false);
      final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
      homeBloc.viewInitialization(servicesBloc: servicesBloc, alertsBloc: alertsBloc);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<HomeBloc>().isLoading;
    debugPrint('[HomeScreen] build: isLoading = $isLoading');
    return Loading(
      isLoading: isLoading,
      child: Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Cambia este color al que prefieras
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBar(
          screenType: ScreenType.baseScreen,
        ),
      ),
        drawer: const LeftMenu(),
              floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GuiasScreen()),
              );
            },
            backgroundColor: const Color(0xFF38A8E0),
            shape: const CircleBorder(),
            child: const Icon(Icons.map_outlined, color: Colors.white),
          ),
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              child: Center(
                child: Text(
                  '${context.watch<HomeBloc>().totalGuides}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
        body: const SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16),
              BannerRunWay(),
              SizedBox(height: 24),
              Alertas(),
              NuestrosServicios(),
              SizedBox(height: 54),
            ],
          ),
        ),
      ),
    );
  }
}
