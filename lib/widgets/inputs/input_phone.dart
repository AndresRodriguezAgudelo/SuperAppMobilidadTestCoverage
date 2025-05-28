import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../models/indicativos_model.dart';

class InputPhone extends StatefulWidget {
  final Function(String) onPhoneChanged;
  final Function(String) onCountryChanged;
  final bool enabled;

  const InputPhone({
    super.key,
    required this.onPhoneChanged,
    required this.onCountryChanged,
    this.enabled = true,
  });

  @override
  State<InputPhone> createState() => _InputPhoneState();
}

class _InputPhoneState extends State<InputPhone> {
  late TextEditingController _phoneController;
  late TextEditingController _searchController;
  Pais _selectedCountry = Pais(
    nombreES: 'Colombia',
    nombreEN: 'Colombia',
    iso2: 'CO',
    iso3: 'COL',
    phoneCode: '57',
  );
  List<Pais> _paises = [];
  List<Pais> _paisesFiltrados = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _searchController = TextEditingController();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      debugPrint('Intentando cargar el archivo JSON...');
      String jsonString = await DefaultAssetBundle.of(context)
          .loadString('lib/usefull/json/indicativos.json');
      debugPrint('JSON cargado exitosamente');

      final jsonData = json.decode(jsonString) as List<dynamic>;
      debugPrint('JSON decodificado exitosamente. Número de países: ${jsonData.length}');
      
      final paises = jsonData.map((e) => Pais.fromJson(e as Map<String, dynamic>)).toList();
      debugPrint('Países parseados exitosamente. Primer país: ${paises.first.nombreES}');

      setState(() {
        _paises = paises;
        _paisesFiltrados = paises;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error cargando países: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filtrarPaises(String query) {
    setState(() {
      if (query.isEmpty) {
        _paisesFiltrados = List.from(_paises);
      } else {
        _paisesFiltrados = _paises
            .where((pais) =>
                pais.nombreES.toLowerCase().contains(query.toLowerCase().trim()))
            .toList();
      }
    });
  }

  void _showCountryPicker() {
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
                          controller: _searchController,
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
                              _filtrarPaises(value);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Lista de países
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text('Error: $_error'))
                            : _paisesFiltrados.isEmpty
                                ? const Center(
                                    child: Text('No se encontraron países'),
                                  )
                                : ListView.builder(
                                    itemCount: _paisesFiltrados.length,
                                    itemBuilder: (context, index) {
                                      final pais = _paisesFiltrados[index];
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
                                            _selectedCountry = pais;
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
      _searchController.clear();
      _paisesFiltrados = List.from(_paises);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.enabled ? _showCountryPicker : null,
          child: Container(
            width: 100,
            height: 50,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color:const Color.fromARGB(255, 245, 245, 245),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_selectedCountry.bandera, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Text(
                  _selectedCountry.indicativo,
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
              color:const Color.fromARGB(255, 245, 245, 245),
              borderRadius: BorderRadius.circular(12),
              
            ),
            child: TextField(
              controller: _phoneController,
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
