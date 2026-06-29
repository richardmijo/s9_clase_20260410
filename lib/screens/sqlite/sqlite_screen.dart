import 'package:flutter/material.dart';

class SqliteScreen extends StatefulWidget {
  const SqliteScreen({super.key});

  @override
  State<SqliteScreen> createState() => _SqliteScreenState();
}

class _SqliteScreenState extends State<SqliteScreen> {
  final List<String> _mockItems = [
    'Juan Pérez - juan.perez@uide.edu.ec',
    'María López - maria.lopez@uide.edu.ec',
  ];

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Registro (Simulado)'),
          content: const TextField(
            decoration: InputDecoration(labelText: 'Nombre y Correo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Guardado en SQLite (Simulado)'),
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Módulo SQLite')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'SQLite: Persistencia Local',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'En esta sección se conectará el código con el helper de SQLite para realizar inserciones, lecturas, ediciones y eliminaciones.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _mockItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(_mockItems[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Eliminado de SQLite (Simulado)'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/**

 import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';
import '../../models/carrera.dart';
import '../../models/estudiante.dart';

class SqliteScreen extends StatefulWidget {
  const SqliteScreen({super.key});

  @override
  State<SqliteScreen> createState() => _SqliteScreenState();
}

class _SqliteScreenState extends State<SqliteScreen> {
  // Instancia del helper de base de datos
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Carrera> _carreras = [];
  List<Estudiante> _estudiantes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData(); // Cargar los datos iniciales
  }

  // Refresca la información leyendo la base de datos
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    final carreras = await _dbHelper.getCarreras();
    final estudiantes = await _dbHelper.getEstudiantes();
    setState(() {
      _carreras = carreras;
      _estudiantes = estudiantes;
      _isLoading = false;
    });
  }

  // Muestra diálogo para agregar una nueva carrera al catálogo
  void _showAddCarreraDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Carrera'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nombre de la Carrera',
              hintText: 'Ej. Ingeniería Civil',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  // Guardar carrera en SQLite
                  await _dbHelper.insertCarrera(
                    Carrera(nombre: controller.text.trim()),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _refreshData(); // Refrescar listas
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // Muestra diálogo para agregar un estudiante y asociarlo a una carrera
  void _showAddEstudianteDialog() {
    if (_carreras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, agrega una carrera primero.')),
      );
      return;
    }

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    int? selectedCarreraId = _carreras.first.id;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Agregar Estudiante'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre Completo',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Dropdown dinámico alimentado por la tabla 'carreras'
                  DropdownButtonFormField<int>(
                    initialValue: selectedCarreraId,
                    decoration: const InputDecoration(labelText: 'Carrera'),
                    items: _carreras.map((carrera) {
                      return DropdownMenuItem<int>(
                        value: carrera.id,
                        child: Text(carrera.nombre),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        selectedCarreraId = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isNotEmpty &&
                        emailController.text.trim().isNotEmpty &&
                        selectedCarreraId != null) {
                      // Insertar nuevo estudiante en SQLite con FK carrera_id
                      await _dbHelper.insertEstudiante(
                        Estudiante(
                          nombre: nameController.text.trim(),
                          email: emailController.text.trim(),
                          carreraId: selectedCarreraId!,
                        ),
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _refreshData(); // Refrescar pantallas
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Elimina un estudiante de la base de datos
  Future<void> _deleteEstudiante(int id) async {
    await _dbHelper.deleteEstudiante(id);
    _refreshData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estudiante eliminado correctamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite: Universidad'),
        actions: [
          // Botón para agregar carrera al catálogo
          IconButton(
            icon: const Icon(Icons.school),
            tooltip: 'Agregar Carrera',
            onPressed: _showAddCarreraDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Listado de Estudiantes (INNER JOIN)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                Expanded(
                  child: _estudiantes.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay estudiantes registrados.\nPresiona el botón + para añadir uno.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _estudiantes.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final estudiante = _estudiantes[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.blue,
                                ),
                              ),
                              title: Text(
                                estudiante.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(estudiante.email),
                                  Text(
                                    'Carrera: ${estudiante.carreraNombre ?? "Sin Carrera"}',
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _deleteEstudiante(estudiante.id!),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEstudianteDialog,
        tooltip: 'Agregar Estudiante',
        child: const Icon(Icons.add),
      ),
    );
  }
}
 
 
 */
