class Estudiante {
  final int? id;
  final String nombre;
  final String email;
  final int carreraId;
  final String? carreraNombre; // Campo auxiliar para el INNER JOIN

  const Estudiante({
    this.id,
    required this.nombre,
    required this.email,
    required this.carreraId,
    this.carreraNombre,
  });

  // Convertir un Estudiante en un Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'carrera_id': carreraId,
    };
  }

  // Crear un Estudiante a partir de un Map de SQLite
  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      email: map['email'] as String,
      carreraId: map['carrera_id'] as int,
      carreraNombre: map['carrera_nombre'] as String?,
    );
  }
}
