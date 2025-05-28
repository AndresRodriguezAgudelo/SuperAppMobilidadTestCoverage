import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../inputs/input_text.dart';
import '../inputs/input_select.dart';
import '../../BLoC/document_types/document_types_bloc.dart';

class StepThree extends StatefulWidget {
  final Function(String?, String?, String?) onValidate;

  const StepThree({
    super.key,
    required this.onValidate,
  });

  @override
  State<StepThree> createState() => StepThreeState();
}

class StepThreeState extends State<StepThree> {
  late final DocumentTypesBloc _documentTypesBloc;
  String _placa = '';
  Map<String, dynamic>? _tipoDocumento;
  String _numeroDocumento = '';
  bool _isPlacaValid = false;
  bool _isNumeroDocumentoValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _documentTypesBloc = DocumentTypesBloc();
    // Usar post-frame callback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _documentTypesBloc.getDocumentTypes(
        search: '',
        order: 'ASC',
        page: 1,
        take: 50,
      );
    });
  }

  @override
  void dispose() {
    _documentTypesBloc.dispose();
    super.dispose();
  }

  void _updateValidation() {
    widget.onValidate(
      _isPlacaValid ? _placa : null,
      _tipoDocumento != null ? "${_tipoDocumento!['id']} - ${_tipoDocumento!['typeName']}" : null,
      _isNumeroDocumentoValid ? _numeroDocumento : null,
    );
  }

  void setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _documentTypesBloc,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const SizedBox(height: 50),
          const Text(
            'Asocia tu vehículo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '*Ingresa el documento del propietario tal como aparece en la tarjeta de propiedad.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          InputText(
            type: InputType.plateCar,
            label: 'Placa',
            onChanged: (value, isValid) {
              setState(() {
                _placa = value.toUpperCase();
                _isPlacaValid = isValid && value.isNotEmpty;
              });
              _updateValidation();
            },
          ),
          const SizedBox(height: 16),
          Consumer<DocumentTypesBloc>(
            builder: (context, bloc, child) {
              if (bloc.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (bloc.error != null) {
                return Center(
                  child: Text(
                    'Error: ${bloc.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final documentTypes = bloc.documentTypes;
              if (documentTypes.isEmpty) {
                return const Center(
                  child: Text('No hay tipos de documento disponibles'),
                );
              }

              return Theme(
                data: Theme.of(context).copyWith(
                  bottomSheetTheme: const BottomSheetThemeData(
                    modalBarrierColor: Colors.black54,
                  ),
                ),
                child: InputSelect(
                  label: 'Tipos de documento de propietario',
                  options: documentTypes.map((type) => type['typeName'].toString()).toList(),
                  onChanged: (value, isValid) {
                    setState(() {
                      _tipoDocumento = documentTypes.firstWhere(
                        (type) => type['typeName'].toString() == value,
                      );
                    });
                    _updateValidation();
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          InputText(
            type: InputType.id,
            label: 'Número de documento del propietario',
            onChanged: (value, isValid) {
              setState(() {
                _numeroDocumento = value;
                _isNumeroDocumentoValid = isValid && value.isNotEmpty;
              });
              _updateValidation();
            },
          ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
