class Cliente {
  final int? id;
  final String nombre;
  final String apellido;
  final String dni;
  final String telefono;
  final String direccion;
  final int? elevadorId;

  Cliente({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.dni,
    required this.telefono,
    required this.direccion,
    this.elevadorId,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      dni: json['DNI'] ?? '',
      telefono: json['telefono'] ?? '',
      direccion: json['direccion'] ?? '',
      elevadorId: json['elevadorId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'DNI': dni,
      'telefono': telefono,
      'direccion': direccion,
      if (elevadorId != null) 'elevadorId': elevadorId,
    };
  }

  Cliente copyWith({
    int? id,
    String? nombre,
    String? apellido,
    String? dni,
    String? telefono,
    String? direccion,
    int? elevadorId,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      dni: dni ?? this.dni,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      elevadorId: elevadorId ?? this.elevadorId,
    );
  }
}

