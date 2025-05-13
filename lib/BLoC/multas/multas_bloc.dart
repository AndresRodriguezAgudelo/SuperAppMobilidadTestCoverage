import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/API.dart';
import '../auth/auth_context.dart';

class MultaDetalle {
  final String numeroMulta;
  final String fecha;
  final String codigoInfraccion;
  final String descripcionInfraccion;
  final String estado;
  final double valorPagar;
  final Map<String, dynamic> detalleValor;

  MultaDetalle({
    required this.numeroMulta,
    required this.fecha,
    required this.codigoInfraccion,
    required this.descripcionInfraccion,
    required this.estado,
    required this.valorPagar,
    required this.detalleValor,
  });

  factory MultaDetalle.fromJson(Map<String, dynamic> json) {
    return MultaDetalle(
      numeroMulta: json['numeroMulta'] ?? 'N/A',
      fecha: json['fecha'] ?? 'Sin fecha',
      codigoInfraccion: json['codigoInfraccion'] ?? 'N/A',
      descripcionInfraccion: json['descripcionInfraccion'] ?? 'Sin descripción',
      estado: json['estado'] ?? 'Sin estado',
      valorPagar: json['valorPagar']?.toDouble() ?? 0.0,
      detalleValor: json['detalleValor'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroMulta': numeroMulta,
      'fecha': fecha,
      'codigoInfraccion': codigoInfraccion,
      'descripcionInfraccion': descripcionInfraccion,
      'estado': estado,
      'valorPagar': valorPagar,
      'detalleValor': detalleValor,
    };
  }

  // Convertir a formato para HistorialVehicularCard
  Map<String, dynamic> toCardData({required String placa}) {
    return {
      'numeroMulta': numeroMulta,
      'fecha': fecha,
      'descripcionInfraccion': descripcionInfraccion,
      'estado': estado,
      'valorPagar': valorPagar,
      'placa': placa,
    };
  }
}

class MultasData {
  final int comparendosMultas;
  final double totalPagar;
  final String mensaje;
  final List<MultaDetalle> detallesComparendos;
  final DateTime ultimaActualizacion;
  final String placa;

  MultasData({
    required this.comparendosMultas,
    required this.totalPagar,
    required this.mensaje,
    required this.detallesComparendos,
    required this.ultimaActualizacion,
    required this.placa,
  });

  factory MultasData.fromJson(Map<String, dynamic> json) {
    List<MultaDetalle> detalles = [];
    if (json['detallesComparendos'] != null) {
      detalles = List<MultaDetalle>.from(
        json['detallesComparendos'].map((x) => MultaDetalle.fromJson(x))
      );
    }

    return MultasData(
      comparendosMultas: json['comparendos_multas'] ?? 0,
      totalPagar: json['totalPagar']?.toDouble() ?? 0.0,
      mensaje: json['mensaje'] ?? 'No hay información disponible',
      detallesComparendos: detalles,
      ultimaActualizacion: DateTime.now(),
      placa: json['placa'] ?? '',
    );
  }

  bool get tieneMultas => comparendosMultas > 0;
}

class MultasBloc extends ChangeNotifier {
  // Singleton
  static final MultasBloc _instance = MultasBloc._internal();
  factory MultasBloc() => _instance;
  MultasBloc._internal();

  // Estado
  bool _isLoading = false;
  String? _error;
  String? _plate;
  MultasData? _multasData;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get plate => _plate;
  MultasData? get multasData => _multasData;
  bool get tieneMultas => _multasData != null && _multasData!.tieneMultas;
  DateTime? get ultimaActualizacion => _multasData?.ultimaActualizacion;

  // Establecer placa
  void setPlate(String plate) {
    print('\n🚗 MULTAS_BLOC: setPlate - Estableciendo placa: $plate');
    _plate = plate;
    
    // Si tenemos una placa, cargamos los datos de multas
    if (_plate != null && _plate!.isNotEmpty) {
      print('\n🚗 MULTAS_BLOC: setPlate - Cargando datos de multas...');
      loadMultasData();
    } else {
      print('\n🚗 MULTAS_BLOC: setPlate - Placa vacía, no se cargarán datos');
    }
    
    notifyListeners();
  }

  // Cargar datos de multas
  Future<void> loadMultasData() async {
    if (_isLoading) {
      print('\n🚗 MULTAS_BLOC: loadMultasData - Ya hay una carga en progreso, se omite');
      return;
    }

    if (_plate == null || _plate!.isEmpty) {
      _error = 'No se ha establecido una placa';
      print('\n⚠️ MULTAS_BLOC: $_error');
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('\n🚗 MULTAS_BLOC: loadMultasData - Iniciando carga para placa: $_plate');
      final apiService = APIService();
      
      // Limpiar la placa (quitar espacios y caracteres especiales)
      String cleanPlate = _plate!.trim().replaceAll(' ', '');
      
      // Construir URL con parámetros
      final endpoint = apiService.getVehicleFinesSimitEndpoint(cleanPlate);
      final url = '${APIService.baseUrl}$endpoint';
      print('\n🚗 MULTAS_BLOC: loadMultasData - URL completa: $url');
      
      // Obtener el token de autenticación desde AuthContext
      final authContext = AuthContext();
      final token = authContext.token;
      
      // Crear headers con el token
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      // Agregar el token si está disponible
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      print('\n🚗 MULTAS_BLOC: loadMultasData - Enviando petición GET...');
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      print('\n🚗 MULTAS_BLOC: loadMultasData - Respuesta recibida con código: ${response.statusCode}');
      print('\n🚗 MULTAS_BLOC: loadMultasData - Cuerpo de la respuesta: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('\n🚗 MULTAS_BLOC: loadMultasData - Datos decodificados: $data');
        
        _multasData = MultasData.fromJson(data);
        print('\n🚗 MULTAS_BLOC: loadMultasData - Datos procesados y guardados');
        print('\n🚗 MULTAS_BLOC: loadMultasData - ¿Tiene multas? ${_multasData!.tieneMultas ? 'Sí' : 'No'}');
        if (_multasData!.tieneMultas) {
          print('\n🚗 MULTAS_BLOC: loadMultasData - Total de multas: ${_multasData!.comparendosMultas}');
          print('\n🚗 MULTAS_BLOC: loadMultasData - Total a pagar: ${_multasData!.totalPagar}');
        }
      } else if (response.statusCode == 400) {
        // Intentar parsear el mensaje de error
        try {
          final errorData = json.decode(response.body);
          _error = errorData['message'] ?? 'Error al cargar los datos de multas';
        } catch (e) {
          _error = 'Error al cargar los datos de multas: ${response.statusCode}';
        }
        print('\n⚠️ MULTAS_BLOC: $_error');
      } else {
        _error = 'Error al cargar los datos de multas: ${response.statusCode}';
        print('\n⚠️ MULTAS_BLOC: $_error');
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      print('\n⚠️ MULTAS_BLOC: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refrescar datos
  void refresh() {
    if (_plate != null && _plate!.isNotEmpty) {
      loadMultasData();
    }
  }

  // Reiniciar el estado
  void reset() {
    _isLoading = false;
    _error = null;
    _plate = null;
    _multasData = null;
    notifyListeners();
  }
}
