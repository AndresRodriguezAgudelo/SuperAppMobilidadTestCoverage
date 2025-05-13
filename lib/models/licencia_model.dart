class LicenciaCategoria {
  final String categoria;
  final String servicio;

  LicenciaCategoria({
    required this.categoria,
    required this.servicio,
  });
}

class LicenciaModel {
  final List<LicenciaCategoria> categorias;
  final DateTime fechaVencimiento;
  final String status;
  final bool puedeRenovar;
  final DateTime? fechaRenovacionDisponible;

  LicenciaModel({
    required this.categorias,
    required this.fechaVencimiento,
    required this.status,
    required this.puedeRenovar,
    this.fechaRenovacionDisponible,
  });
}
