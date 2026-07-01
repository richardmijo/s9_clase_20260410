class Carrera {
  final int? id;
  final String nombre;

  const Carrera({
    this.id,
    required this.nombre,
  });

  // Convertir una Carrera en un Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  // Crear una Carrera a partir de un Map de SQLite
  factory Carrera.fromMap(Map<String, dynamic> map) {
    return Carrera(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
    );
  }
}
