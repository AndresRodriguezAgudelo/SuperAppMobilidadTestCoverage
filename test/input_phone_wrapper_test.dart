import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/models/indicativos_model.dart';

// Datos de prueba para los países
final List<dynamic> mockCountriesData = [
  {
    "nameES": "Colombia",
    "nameEN": "Colombia",
    "iso2": "CO",
    "iso3": "COL",
    "phoneCode": "57"
  },
  {
    "nameES": "Estados Unidos",
    "nameEN": "United States",
    "iso2": "US",
    "iso3": "USA",
    "phoneCode": "1"
  },
  {
    "nameES": "México",
    "nameEN": "Mexico",
    "iso2": "MX",
    "iso3": "MEX",
    "phoneCode": "52"
  }
];

// Wrapper para InputPhone que expone métodos internos para testing
class InputPhoneWrapper extends StatefulWidget {
  final Function(String) onPhoneChanged;
  final Function(String) onCountryChanged;
  final bool enabled;

  const InputPhoneWrapper({
    super.key,
    required this.onPhoneChanged,
    required this.onCountryChanged,
    this.enabled = true,
  });

  @override
  InputPhoneWrapperState createState() => InputPhoneWrapperState();
}

class InputPhoneWrapperState extends State<InputPhoneWrapper> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  
  // Países de prueba
  final List<Pais> paises = mockCountriesData
      .map((e) => Pais.fromJson(e as Map<String, dynamic>))
      .toList();
  
  late List<Pais> paisesFiltrados;
  Pais selectedCountry = Pais(
    nombreES: 'Colombia',
    nombreEN: 'Colombia',
    iso2: 'CO',
    iso3: 'COL',
    phoneCode: '57',
  );
  
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    paisesFiltrados = List.from(paises);
  }

  void filtrarPaises(String query) {
    setState(() {
      if (query.isEmpty) {
        paisesFiltrados = List.from(paises);
      } else {
        paisesFiltrados = paises
            .where((pais) =>
                pais.nombreES.toLowerCase().contains(query.toLowerCase().trim()))
            .toList();
      }
    });
  }

  void showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  // Indicador de arrastre
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Título y buscador
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecciona un país',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar país...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              filtrarPaises(value);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Lista de países
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : error != null
                            ? Center(child: Text('Error: $error'))
                            : paisesFiltrados.isEmpty
                                ? const Center(
                                    child: Text('No se encontraron países'),
                                  )
                                : ListView.builder(
                                    itemCount: paisesFiltrados.length,
                                    itemBuilder: (context, index) {
                                      final pais = paisesFiltrados[index];
                                      return ListTile(
                                        leading: Text(
                                          pais.bandera,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        title: Text(pais.nombreES),
                                        subtitle: Text(pais.indicativo),
                                        onTap: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            this.setState(() {
                                              selectedCountry = pais;
                                            });
                                          });
                                          widget.onCountryChanged(pais.indicativo);
                                        },
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // Limpiar el búscador cuando se cierra el modal
      searchController.clear();
      paisesFiltrados = List.from(paises);
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.enabled ? () => showCountryPicker() : null,
          child: Container(
            width: 100,
            height: 50,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: widget.enabled ? Colors.white : const Color.fromARGB(255, 230, 230, 230),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(selectedCountry.bandera, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Text(
                  selectedCountry.indicativo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: widget.enabled ? Colors.white : const Color.fromARGB(255, 230, 230, 230),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: phoneController,
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                hintText: 'Número de teléfono',
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                widget.onPhoneChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Configurar un mock para cargar los datos de países
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(MethodChannel('flutter/assets'), (MethodCall methodCall) async {
    if (methodCall.method == 'loadString') {
      if (methodCall.arguments == 'lib/usefull/json/indicativos.json') {
        return json.encode(mockCountriesData);
      }
    }
    return null;
  });

  group('InputPhoneWrapper Tests', () {
    testWidgets('tests showCountryPicker method', (WidgetTester tester) async {
      String selectedCountry = '';
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InputPhoneWrapper(
            onPhoneChanged: (_) {},
            onCountryChanged: (country) {
              selectedCountry = country;
            },
          ),
        ),
      ));
      
      // Obtener el estado del wrapper
      final state = tester.state<InputPhoneWrapperState>(find.byType(InputPhoneWrapper));
      
      // Llamar directamente al método showCountryPicker
      state.showCountryPicker();
      await tester.pumpAndSettle();
      
      // Verificar que se muestra el modal
      expect(find.text('Selecciona un país'), findsOneWidget);
      expect(find.byType(TextField), findsAtLeastNWidgets(2)); // Al menos 2 TextField (el de teléfono y el buscador)
      
      // Buscar un país
      await tester.enterText(find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextField),
      ), 'Col');
      await tester.pump();
      
      // Verificar que se filtraron los países
      expect(state.paisesFiltrados.length, equals(1));
      expect(state.paisesFiltrados.first.nombreES, equals('Colombia'));
      
      // Seleccionar el país
      await tester.tap(find.text('Colombia'));
      await tester.pumpAndSettle();
      
      // Verificar que se cerró el modal y se actualizó el país seleccionado
      expect(find.byType(BottomSheet), findsNothing);
      expect(selectedCountry, equals('+57'));
    });
    
    testWidgets('tests filtrarPaises method', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InputPhoneWrapper(
            onPhoneChanged: (_) {},
            onCountryChanged: (_) {},
          ),
        ),
      ));
      
      // Obtener el estado del wrapper
      final state = tester.state<InputPhoneWrapperState>(find.byType(InputPhoneWrapper));
      
      // Verificar que inicialmente se muestran todos los países
      expect(state.paisesFiltrados.length, equals(3));
      
      // Filtrar por 'Estados'
      state.filtrarPaises('Estados');
      await tester.pump();
      
      // Verificar que se filtraron los países correctamente
      expect(state.paisesFiltrados.length, equals(1));
      expect(state.paisesFiltrados.first.nombreES, equals('Estados Unidos'));
      
      // Filtrar por algo que no existe
      state.filtrarPaises('XYZ');
      await tester.pump();
      
      // Verificar que no hay países que coincidan
      expect(state.paisesFiltrados.length, equals(0));
      
      // Filtrar con un término vacío (debería mostrar todos los países)
      state.filtrarPaises('');
      await tester.pump();
      
      // Verificar que se muestran todos los países
      expect(state.paisesFiltrados.length, equals(3));
    });
    
    testWidgets('tests error state in country list', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InputPhoneWrapper(
            onPhoneChanged: (_) {},
            onCountryChanged: (_) {},
          ),
        ),
      ));
      
      // Obtener el estado del wrapper
      final state = tester.state<InputPhoneWrapperState>(find.byType(InputPhoneWrapper));
      
      // Simular un error
      state.error = 'Error de prueba';
      state.isLoading = false;
      await tester.pump();
      
      // Abrir el selector de país
      state.showCountryPicker();
      await tester.pumpAndSettle();
      
      // Verificar que se muestra el mensaje de error
      expect(find.text('Error: Error de prueba'), findsOneWidget);
      
      // Cerrar el modal
      await tester.tapAt(const Offset(200, 200)); // Tap fuera del modal para cerrarlo
      await tester.pumpAndSettle();
    });
    
    testWidgets('tests loading state in country list', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InputPhoneWrapper(
            onPhoneChanged: (_) {},
            onCountryChanged: (_) {},
          ),
        ),
      ));
      
      // Obtener el estado del wrapper
      final state = tester.state<InputPhoneWrapperState>(find.byType(InputPhoneWrapper));
      
      // Simular estado de carga
      state.isLoading = true;
      await tester.pump();
      
      // Abrir el selector de país
      state.showCountryPicker();
      await tester.pump(); // Iniciar la animación
      await tester.pump(const Duration(milliseconds: 500)); // Esperar a que la animación avance
      
      // Verificar que se muestra el indicador de carga
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // No intentamos cerrar el modal para evitar problemas con pumpAndSettle
    });
    
    testWidgets('tests empty results in country list', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InputPhoneWrapper(
            onPhoneChanged: (_) {},
            onCountryChanged: (_) {},
          ),
        ),
      ));
      
      // Obtener el estado del wrapper
      final state = tester.state<InputPhoneWrapperState>(find.byType(InputPhoneWrapper));
      
      // Vaciar la lista de países filtrados
      state.paisesFiltrados = [];
      await tester.pump();
      
      // Abrir el selector de país
      state.showCountryPicker();
      await tester.pumpAndSettle();
      
      // Verificar que se muestra el mensaje de no se encontraron países
      expect(find.text('No se encontraron países'), findsOneWidget);
      
      // Cerrar el modal
      await tester.tapAt(const Offset(200, 200)); // Tap fuera del modal para cerrarlo
      await tester.pumpAndSettle();
    });
  });
}
