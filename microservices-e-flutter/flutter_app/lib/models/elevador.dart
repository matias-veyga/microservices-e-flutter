class Elevador {
  final int? id;
  final String modelo;
  final String marca;
  final int capacidad;
  final String direccion;
  final int? clienteId;

  Elevador({
    this.id,
    required this.modelo,
    required this.marca,
    required this.capacidad,
    required this.direccion,
    this.clienteId,
  });

  factory Elevador.fromJson(Map<String, dynamic> json) {
    return Elevador(
      id: json['id'],
      modelo: json['modelo'] ?? '',
      marca: json['marca'] ?? '',
      capacidad: json['capacidad'] ?? 0,
      direccion: json['direccion'] ?? '',
      clienteId: json['clienteId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'modelo': modelo,
      'marca': marca,
      'capacidad': capacidad,
      'direccion': direccion,
      if (clienteId != null) 'clienteId': clienteId,
    };
  }

  Elevador copyWith({
    int? id,
    String? modelo,
    String? marca,
    int? capacidad,
    String? direccion,
    int? clienteId,
  }) {
    return Elevador(
      id: id ?? this.id,
      modelo: modelo ?? this.modelo,
      marca: marca ?? this.marca,
      capacidad: capacidad ?? this.capacidad,
      direccion: direccion ?? this.direccion,
      clienteId: clienteId ?? this.clienteId,
    );
  }
}

