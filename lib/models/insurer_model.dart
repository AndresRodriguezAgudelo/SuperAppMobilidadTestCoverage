class Insurer {
  final dynamic id; // Puede ser int o String
  final String name;

  Insurer({
    required this.id,
    required this.name,
  });

  factory Insurer.fromJson(Map<String, dynamic> json) {
    print('\n🏢 INSURER_MODEL: Parseando JSON: $json');
    
    // Manejar posibles valores nulos
    dynamic id = 0;
    if (json['id'] != null) {
      // Mantener el tipo original (int o String)
      id = json['id'];
      print('\n🏢 INSURER_MODEL: ID encontrado: $id (${id.runtimeType})');
    }
    
    // Usar nameInsurer en lugar de name
    String name = 'Sin nombre';
    if (json['nameInsurer'] != null) {
      name = json['nameInsurer'] as String;
    } else if (json['name'] != null) {
      name = json['name'] as String;
    }
    
    return Insurer(
      id: id,
      name: name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
  
  @override
  String toString() {
    return 'Insurer(id: $id, name: $name)';
  }
}
