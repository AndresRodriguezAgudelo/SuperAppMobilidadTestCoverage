import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ciudad_model.dart';
import '../../BLoC/callCity/city_bloc.dart';
import '../../BLoC/pick_and_plate/pick_and_plate_bloc.dart';

class InputCity extends StatefulWidget {
  final String label;
  final Function(String, bool) onChanged;
  final String? initialCityId; // Opcional: ID de la ciudad inicial

  const InputCity({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialCityId,
  });

  @override
  State<InputCity> createState() => _InputCityState();
}

class _InputCityState extends State<InputCity> {
  final CityBloc _cityBloc = CityBloc();
  List<Ciudad> _ciudades = [];
  List<Ciudad> _ciudadesFiltradas = [];
  Ciudad? _ciudadSeleccionada;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    print('\n🚦 INPUT_CITY: initState - INICIANDO');
    
    // PASO 1: Verificar si hay un initialCityId proporcionado
    if (widget.initialCityId != null && widget.initialCityId!.isNotEmpty) {
      print('\n🚦 INPUT_CITY: initState - PASO 1: Usando initialCityId: ${widget.initialCityId}');
      
      // PASO 2: Actualizar el bloc inmediatamente con este cityId
      try {
        final peakPlateBloc = Provider.of<PeakPlateBloc>(context, listen: false);
        
        // Verificar si el bloc ya tiene una ciudad seleccionada
        if (peakPlateBloc.selectedCity != null) {
          print('\n🚦 INPUT_CITY: initState - El bloc ya tiene una ciudad seleccionada: ${peakPlateBloc.selectedCity!['cityName']}');
          // Si ya hay una ciudad seleccionada, no hacer nada para evitar sobrescribirla
          return;
        }
        
        int? cityId;
        try {
          cityId = int.parse(widget.initialCityId!);
        } catch (e) {
          print('\n⚠️ INPUT_CITY: initState - Error al convertir initialCityId a entero: $e');
        }
        
        if (cityId != null) {
          // Crear un mapa temporal para el bloc mientras se cargan las ciudades
          final Map<String, dynamic> tempCity = {
            'id': cityId,
            'cityName': 'Cargando...',
          };
          
          // Establecer la ciudad en el bloc inmediatamente solo si no hay una ciudad ya seleccionada
          if (peakPlateBloc.selectedCity == null) {
            peakPlateBloc.setCity(tempCity);
            print('\n🚦 INPUT_CITY: initState - PASO 2: Ciudad temporal establecida en el bloc con ID: $cityId');
          }
        }
      } catch (e) {
        print('\n⚠️ INPUT_CITY: initState - Error al establecer ciudad temporal en el bloc: $e');
      }
    }
    
    // PASO 3: Cargar las ciudades
    print('\n🚦 INPUT_CITY: initState - PASO 3: Cargando ciudades');
    _loadCiudades();
    
    // PASO 4: Procesar el initialCityId cuando las ciudades estén cargadas
    if (widget.initialCityId != null && widget.initialCityId!.isNotEmpty) {
      print('\n🚦 INPUT_CITY: initState - PASO 4: Configurando procesamiento de initialCityId');
      
      // Esperar a que las ciudades se carguen antes de intentar seleccionar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('\n🚦 INPUT_CITY: initState - PostFrameCallback ejecutado');
        
        if (_ciudades.isNotEmpty) {
          print('\n🚦 INPUT_CITY: initState - Ciudades ya cargadas, seleccionando ciudad');
          _loadSelectedCity(widget.initialCityId!);
        } else {
          print('\n🚦 INPUT_CITY: initState - Ciudades aún no cargadas, programando reintento');
          // Si las ciudades aún no están cargadas, intentar de nuevo después de un breve retraso
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              print('\n🚦 INPUT_CITY: initState - Primer reintento después de 500ms');
              if (_ciudades.isNotEmpty) {
                _loadSelectedCity(widget.initialCityId!);
              } else {
                // Intentar una vez más después de un retraso más largo
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    print('\n🚦 INPUT_CITY: initState - Segundo reintento después de 1s');
                    // Forzar una carga de ciudades si aún no hay datos
                    if (_ciudades.isEmpty) {
                      print('\n🚦 INPUT_CITY: initState - Forzando carga de ciudades');
                      _loadCiudades();
                    }
                    
                    // Intentar seleccionar la ciudad de nuevo
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        if (_ciudades.isNotEmpty) {
                          print('\n🚦 INPUT_CITY: initState - Tercer intento de seleccionar ciudad');
                          _loadSelectedCity(widget.initialCityId!);
                        } else {
                          print('\n⚠️ INPUT_CITY: initState - No se pudieron cargar las ciudades después de varios intentos');
                        }
                      }
                    });
                  }
                });
              }
            }
          });
        }
      });
    } else {
      // PASO 5: Si no hay initialCityId, intentar obtener la ciudad del bloc
      print('\n🚦 INPUT_CITY: initState - PASO 5: No hay initialCityId, verificando bloc');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final peakPlateBloc = Provider.of<PeakPlateBloc>(context, listen: false);
          final selectedCity = peakPlateBloc.selectedCity;
          
          if (selectedCity != null) {
            print('\n🚦 INPUT_CITY: initState - Ciudad encontrada en el bloc: ${selectedCity['cityName']}');
            // Buscar la ciudad en la lista cargada
            _loadSelectedCity(selectedCity['id'].toString());
          }
        } catch (e) {
          print('\n⚠️ INPUT_CITY: Error al obtener ciudad del bloc: $e');
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCiudades({String? search}) async {
    try {
      if (!_isLoading && search != null) {
        setState(() => _isSearching = true);
      }

      final response = await _cityBloc.getCities(search: search);
      final List<dynamic> ciudadesJson = response['data'] as List<dynamic>;
      
      setState(() {
        _ciudades = ciudadesJson.map((json) => Ciudad.fromJson(json)).toList();
        _ciudadesFiltradas = List.from(_ciudades);
        _isLoading = false;
        _isSearching = false;
      });
      
      // Si hay una ciudad seleccionada en el bloc, buscarla en la lista
      try {
        final peakPlateBloc = Provider.of<PeakPlateBloc>(context, listen: false);
        final selectedCity = peakPlateBloc.selectedCity;
        
        if (selectedCity != null && _ciudadSeleccionada == null) {
          _loadSelectedCity(selectedCity['id'].toString());
        }
      } catch (e) {
        print('\n⚠️ INPUT_CITY: Error al obtener ciudad del bloc después de cargar: $e');
      }
    } catch (e) {
      debugPrint('Error cargando ciudades: $e');
      setState(() {
        _isLoading = false;
        _isSearching = false;
      });
    }
  }

  void _selectCiudad(Ciudad ciudad) {
    print('\n🚦 INPUT_CITY: _selectCiudad - INICIANDO MÉTODO');
    print('\n🚦 INPUT_CITY: _selectCiudad - Ciudad seleccionada: ${ciudad.cityName} (ID: ${ciudad.id})');
    
    // Actualizar el estado local primero
    setState(() {
      _ciudadSeleccionada = ciudad;
      _searchController.text = ciudad.cityName;
    });
    
    // Actualizar el PeakPlateBloc con la ciudad seleccionada
    try {
      print('\n🚦 INPUT_CITY: _selectCiudad - Obteniendo instancia de PeakPlateBloc');
      final peakPlateBloc = Provider.of<PeakPlateBloc>(context, listen: false);
      print('\n🚦 INPUT_CITY: _selectCiudad - Instancia de PeakPlateBloc obtenida');
      
      // Verificar si la ciudad ya está seleccionada
      if (peakPlateBloc.selectedCity != null && peakPlateBloc.selectedCity!['id'] == ciudad.id) {
        print('\n🚦 INPUT_CITY: _selectCiudad - La ciudad ya está seleccionada, omitiendo actualización');
        widget.onChanged(ciudad.id.toString(), true);
        Navigator.pop(context);
        return;
      }
      
      // Convertir Ciudad a Map<String, dynamic>
      final Map<String, dynamic> cityMap = {
        'id': ciudad.id,
        'cityName': ciudad.cityName,
      };
      
      print('\n🚦 INPUT_CITY: _selectCiudad - cityMap creado: $cityMap');
      print('\n🚦 INPUT_CITY: Seleccionando ciudad: ${ciudad.cityName} (ID: ${ciudad.id})');
      
      // Verificar si el bloc tiene una placa establecida
      final String? currentPlate = peakPlateBloc.plate;
      print('\n🚦 INPUT_CITY: _selectCiudad - Placa actual en el bloc: $currentPlate');
      
      // Guardar el ID de la ciudad actual para verificar si cambió después
      final dynamic oldCityId = peakPlateBloc.cityId;
      print('\n🚦 INPUT_CITY: _selectCiudad - ID de ciudad actual en el bloc: $oldCityId');
      
      // Llamar a setCity en el bloc
      print('\n🚦 INPUT_CITY: _selectCiudad - Llamando a peakPlateBloc.setCity()');
      peakPlateBloc.setCity(cityMap);
      print('\n🚦 INPUT_CITY: _selectCiudad - peakPlateBloc.setCity() completado');
      
      // Verificar si el ID de la ciudad cambió correctamente
      print('\n🚦 INPUT_CITY: _selectCiudad - Nuevo ID de ciudad en el bloc: ${peakPlateBloc.cityId}');
      
      // Si el ID de la ciudad cambió pero la placa está establecida, forzar una carga de datos
      if (currentPlate != null && currentPlate.isNotEmpty) {
        print('\n🚦 INPUT_CITY: _selectCiudad - Ciudad cambió y hay placa, forzando carga de datos');
        // Pequeño retraso para asegurar que la ciudad se haya actualizado completamente
        Future.delayed(Duration(milliseconds: 300), () {
          if (!peakPlateBloc.isLoading) {
            print('\n🚦 INPUT_CITY: _selectCiudad - Forzando carga de datos de pico y placa');
            peakPlateBloc.loadPeakPlateData();
          }
        });
      }
    } catch (e) {
      print('\n⚠️ INPUT_CITY: Error al actualizar PeakPlateBloc: $e');
    }
    
    print('\n🚦 INPUT_CITY: _selectCiudad - Llamando a widget.onChanged()');
    widget.onChanged(ciudad.id.toString(), true);
    print('\n🚦 INPUT_CITY: _selectCiudad - Cerrando modal');
    Navigator.pop(context);
  }

  void _showCiudadesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Ciudad de circulación',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Escribe',
                      suffixIcon: const Icon(Icons.search),
                      filled: true,
                      
                      fillColor: const Color.fromRGBO(247, 247, 247, 1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      _loadCiudades(search: value);
                      setModalState(() {});

                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _ciudadesFiltradas.length,
                          itemBuilder: (context, index) {
                            final ciudad = _ciudadesFiltradas[index];
                            final isSelected = _ciudadSeleccionada?.id == ciudad.id;
                            return ListTile(
                              leading: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF38A8E0),
                                    width: 2,
                                  ),
                                  color: isSelected ? const Color(0xFF38A8E0) : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              title: Text(ciudad.cityName),
                              onTap: () => _selectCiudad(ciudad),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Método para buscar y establecer la ciudad seleccionada por ID
  void _loadSelectedCity(String cityId) {
    if (_ciudades.isEmpty) {
      print('\n⚠️ INPUT_CITY: _loadSelectedCity - No hay ciudades cargadas, intentando más tarde');
      // Intentar de nuevo después de un breve retraso
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _ciudades.isNotEmpty) {
          _loadSelectedCity(cityId);
        } else {
          // Si todavía no hay ciudades, intentar cargarlas de nuevo
          if (mounted) {
            _loadCiudades();
            // Intentar una vez más después de otro retraso
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted && _ciudades.isNotEmpty) {
                _loadSelectedCity(cityId);
              }
            });
          }
        }
      });
      return;
    }
    
    print('\n🚦 INPUT_CITY: _loadSelectedCity - Buscando ciudad con ID: $cityId');
    print('\n🚦 INPUT_CITY: _loadSelectedCity - Ciudades disponibles: ${_ciudades.length}');
    
    // Convertir el cityId a entero para comparación
    int? cityIdInt;
    try {
      cityIdInt = int.parse(cityId);
      print('\n🚦 INPUT_CITY: _loadSelectedCity - ID convertido a entero: $cityIdInt');
    } catch (e) {
      print('\n⚠️ INPUT_CITY: _loadSelectedCity - Error al convertir ID a entero: $e');
    }
    
    // Buscar la ciudad por ID (usando tanto comparación de string como de entero)
    Ciudad ciudad = Ciudad(id: -1, cityName: 'Ciudad no encontrada');
    
    if (cityIdInt != null) {
      // Primero intentar con comparación de enteros (más precisa)
      try {
        final foundCity = _ciudades.firstWhere(
          (c) => c.id == cityIdInt,
          orElse: () => Ciudad(id: -1, cityName: 'Ciudad no encontrada'),
        );
        if (foundCity.id != -1) {
          ciudad = foundCity;
        }
      } catch (e) {
        print('\n⚠️ INPUT_CITY: _loadSelectedCity - Error al buscar por ID entero: $e');
      }
    }
    
    // Si no se encontró con entero, intentar con string
    if (ciudad.id == -1) {
      try {
        final foundCity = _ciudades.firstWhere(
          (c) => c.id.toString() == cityId,
          orElse: () => Ciudad(id: -1, cityName: 'Ciudad no encontrada'),
        );
        if (foundCity.id != -1) {
          ciudad = foundCity;
        }
      } catch (e) {
        print('\n⚠️ INPUT_CITY: _loadSelectedCity - Error al buscar por ID string: $e');
      }
    }
    
    if (ciudad.id != -1) {
      print('\n🚦 INPUT_CITY: _loadSelectedCity - Ciudad encontrada: ${ciudad.cityName} (ID: ${ciudad.id})');
      
      // Verificar si ya tenemos esta ciudad seleccionada para evitar actualizaciones innecesarias
      if (_ciudadSeleccionada != null && _ciudadSeleccionada!.id == ciudad.id) {
        print('\n🚦 INPUT_CITY: _loadSelectedCity - Esta ciudad ya está seleccionada, omitiendo');
        return;
      }
      
      setState(() {
        _ciudadSeleccionada = ciudad;
        _searchController.text = ciudad.cityName;
      });
      
      // Actualizar el PeakPlateBloc con la ciudad seleccionada
      try {
        print('\n🚦 INPUT_CITY: _loadSelectedCity - Actualizando PeakPlateBloc');
        final peakPlateBloc = Provider.of<PeakPlateBloc>(context, listen: false);
        
        // Convertir Ciudad a Map<String, dynamic>
        final Map<String, dynamic> cityMap = {
          'id': ciudad.id,
          'cityName': ciudad.cityName,
        };
        
        // Llamar a setCity en el bloc
        peakPlateBloc.setCity(cityMap);
        
        // Notificar al callback
        widget.onChanged(ciudad.cityName, true);
      } catch (e) {
        print('\n⚠️ INPUT_CITY: _loadSelectedCity - Error al actualizar el bloc: $e');
      }
    } else {
      print('\n⚠️ INPUT_CITY: _loadSelectedCity - Ciudad con ID $cityId no encontrada');
      
      // Intentar cargar más ciudades si no se encuentra
      try {
        final peakPlateBloc = Provider.of<PeakPlateBloc>(context, listen: false);
        // Intentar cargar más ciudades desde el bloc
        if (peakPlateBloc.cities.isEmpty) {
          peakPlateBloc.loadCities();
          // Intentar de nuevo después de un breve retraso
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              // Actualizar la lista local con las ciudades del bloc
              setState(() {
                _ciudades = peakPlateBloc.cities.map((city) => 
                  Ciudad(id: city['id'], cityName: city['cityName']))
                  .toList();
              });
              
              // Intentar seleccionar la ciudad de nuevo
              if (_ciudades.isNotEmpty) {
                _loadSelectedCity(cityId);
              }
            }
          });
        }
      } catch (e) {
        print('\n⚠️ INPUT_CITY: _loadSelectedCity - Error al intentar cargar más ciudades: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener la ciudad seleccionada del bloc para mostrarla
    try {
      final peakPlateBloc = Provider.of<PeakPlateBloc>(context);
      final selectedCity = peakPlateBloc.selectedCity;
      
      if (selectedCity != null && _ciudadSeleccionada == null) {
        // Intentar cargar la ciudad seleccionada si aún no está establecida
        print('\n🚦 INPUT_CITY: build - Cargando ciudad seleccionada del bloc: ${selectedCity['id']}');
        _loadSelectedCity(selectedCity['id'].toString());
      } else if (selectedCity != null && _ciudadSeleccionada != null && selectedCity['id'] != _ciudadSeleccionada!.id) {
        // Si la ciudad en el bloc cambió, actualizar la ciudad seleccionada localmente
        print('\n🚦 INPUT_CITY: build - Actualizando ciudad seleccionada local para que coincida con el bloc');
        print('\n🚦 INPUT_CITY: build - Ciudad en bloc: ${selectedCity['id']}, Ciudad local: ${_ciudadSeleccionada!.id}');
        _loadSelectedCity(selectedCity['id'].toString());
      }
    } catch (e) {
      print('\n⚠️ INPUT_CITY: build - Error al acceder al bloc: $e');
      // Ignorar errores si no se puede acceder al bloc
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showCiudadesModal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 241, 241, 241),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _ciudadSeleccionada != null
                        ? _ciudadSeleccionada!.cityName
                        : 'Selecciona una ciudad',
                    style: TextStyle(
                      color: _ciudadSeleccionada != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
