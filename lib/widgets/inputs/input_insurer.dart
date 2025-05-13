import 'package:flutter/material.dart';
import '../../models/insurer_model.dart';
import '../../BLoC/insurer/insurer_bloc.dart';

class InputInsurer extends StatefulWidget {
  final String label;
  final Function(String, bool) onChanged;
  final Insurer? initialValue;

  const InputInsurer({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<InputInsurer> createState() => _InputInsurerState();
}

class _InputInsurerState extends State<InputInsurer> {
  final InsurerBloc _insurerBloc = InsurerBloc();
  List<Insurer> _insurers = [];
  List<Insurer> _filteredInsurers = [];
  Insurer? _selectedInsurer;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadInsurers();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateInitialValue();
  }
  
  @override
  void didUpdateWidget(InputInsurer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el valor inicial cambió, actualizar el estado
    if (widget.initialValue != oldWidget.initialValue) {
      print('\n🏢 INPUT_INSURER: didUpdateWidget - Valor inicial cambió');
      _updateInitialValue();
    }
  }
  
  void _updateInitialValue() {
    // Initialize with the initial value if provided
    if (widget.initialValue != null) {
      print('\n🏢 INPUT_INSURER: _updateInitialValue - Valor inicial: ${widget.initialValue!.name} (ID: ${widget.initialValue!.id})');
      _selectedInsurer = widget.initialValue;
      _searchController.text = widget.initialValue!.name;
      
      // Notificar al padre que ya tenemos un valor seleccionado, pero usando Future.microtask
      // para evitar llamar a setState durante el build
      Future.microtask(() {
        widget.onChanged(widget.initialValue!.id.toString(), true);
      });
    } else {
      print('\n🏢 INPUT_INSURER: _updateInitialValue - No se recibió valor inicial');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInsurers({String? search}) async {
    try {
      if (!_isLoading && search != null) {
        setState(() => _isSearching = true);
      }

      print('\n🏢 INPUT_INSURER: Cargando aseguradoras con búsqueda: ${search ?? "ninguna"}');
      final response = await _insurerBloc.getInsurers(search: search);
      
      if (response.containsKey('data')) {
        final List<dynamic> insurersJson = response['data'] as List<dynamic>;
        print('\n🏢 INPUT_INSURER: Se encontraron ${insurersJson.length} aseguradoras');
        
        setState(() {
          _insurers = insurersJson.map((json) => Insurer.fromJson(json)).toList();
          _filteredInsurers = List.from(_insurers);
          _isLoading = false;
          _isSearching = false;
        });
      } else {
        print('\n⚠️ INPUT_INSURER: La respuesta no contiene datos de aseguradoras');
        setState(() {
          _insurers = [];
          _filteredInsurers = [];
          _isLoading = false;
          _isSearching = false;
        });
      }
    } catch (e) {
      print('\n❌ INPUT_INSURER: Error cargando aseguradoras: $e');
      setState(() {
        _insurers = [];
        _filteredInsurers = [];
        _isLoading = false;
        _isSearching = false;
      });
    }
  }

  void _selectInsurer(Insurer insurer) {
    print('\n🏢 INPUT_INSURER: _selectInsurer - INICIANDO MÉTODO');
    print('\n🏢 INPUT_INSURER: _selectInsurer - Insurer selected: ${insurer.name} (ID: ${insurer.id})');
    
    setState(() {
      _selectedInsurer = insurer;
      _searchController.text = insurer.name;
    });
    
    print('\n🏢 INPUT_INSURER: _selectInsurer - Calling widget.onChanged()');
    widget.onChanged(insurer.id.toString(), true);
    print('\n🏢 INPUT_INSURER: _selectInsurer - Closing modal');
    Navigator.pop(context);
  }

  void _showInsurersModal() {
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
                    'Selecciona una aseguradora',
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
                      hintText: 'Buscar aseguradora...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      _loadInsurers(search: value);
                      setModalState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredInsurers.isEmpty
                          ? const Center(
                              child: Text(
                                'No se encontraron aseguradoras. Intenta con otro término de búsqueda.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredInsurers.length,
                              itemBuilder: (context, index) {
                                final insurer = _filteredInsurers[index];
                                final isSelected = _selectedInsurer?.id == insurer.id;
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
                                  title: Text(insurer.name),
                                  onTap: () => _selectInsurer(insurer),
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

  @override
  Widget build(BuildContext context) {
    // Log para depurar
    print('\n🏢 INPUT_INSURER: build - Estado actual: ${_selectedInsurer?.name ?? "No seleccionado"}');
    
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
          onTap: _showInsurersModal,
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
                    _selectedInsurer != null
                        ? _selectedInsurer!.name
                        : 'Selecciona una aseguradora',
                    style: TextStyle(
                      color: _selectedInsurer != null ? Colors.black : Colors.grey[600],
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
