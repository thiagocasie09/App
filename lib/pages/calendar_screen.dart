// Importa la pantalla `NewTaskScreen` que se usará para agregar nuevas tareas
import 'package:modernlogintute/pages/newtask_screen.dart';

// Importa el paquete Flutter para los widgets básicos de la interfaz de usuario
import 'package:flutter/material.dart';

// Importa `TableCalendar`, una biblioteca que facilita la creación de calendarios en Flutter
import 'package:table_calendar/table_calendar.dart';

// Importa `cloud_firestore` para interactuar con la base de datos Firebase Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

// Define el widget `CalendarScreen` como un `StatefulWidget` para gestionar el estado
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  // Define una clave global para acceder al estado del widget desde otros lugares
  static final GlobalKey<_CalendarScreenState> calendarKey = GlobalKey();

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

// Clase privada `_CalendarScreenState` que contiene el estado del `CalendarScreen`
class _CalendarScreenState extends State<CalendarScreen> {
  // Formato del calendario, inicializado a mostrar el mes
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Fecha actualmente enfocada en el calendario
  DateTime _focusedDay = DateTime.now();

  // Día seleccionado en el calendario (puede ser `null` si no hay selección)
  DateTime? _selectedDay;

  // Mapa que almacena tareas agrupadas por fecha
  Map<DateTime, List<Map<String, dynamic>>> _tasksByDate = {};

  // Bandera para controlar el estado de carga de las tareas
  bool isLoading = false;

  // Método que se ejecuta al inicializar el estado del widget
  @override
  void initState() {
    super.initState();
    _loadTasks(); // Carga las tareas desde Firebase al iniciar
  }

  // Método privado para cargar tareas desde Firebase
  Future<void> _loadTasks() async {
    if (isLoading) return; // Prevenir múltiples llamadas simultáneas
    setState(() {
      isLoading = true; // Activa la bandera de carga
    });

    // Obtiene todas las tareas de la colección 'Tasks' en Firestore
    final snapshot = await FirebaseFirestore.instance.collection('Tasks').get();
    final tasksByDate = <DateTime, List<Map<String, dynamic>>>{};

    // Itera sobre cada documento en la colección de tareas
    for (var doc in snapshot.docs) {
      final data = doc.data(); // Obtiene los datos de cada documento
      final date = (data['date'] as Timestamp)
          .toDate(); // Convierte la fecha de Firebase
      final task = {
        'subject': data['subject'], // Materia o asunto de la tarea
        'description': data['description'], // Descripción de la tarea
        'status': data['status'] ??
            'Pendiente', // Estado de la tarea (por defecto 'Pendiente')
      };

      // Normaliza la fecha (solo año, mes y día) para evitar problemas de comparación
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Agrupa las tareas por fecha en el mapa `tasksByDate`
      if (tasksByDate[normalizedDate] == null) {
        tasksByDate[normalizedDate] = [task];
      } else {
        tasksByDate[normalizedDate]!.add(task);
      }
    }

    // Actualiza el estado del widget con las tareas agrupadas por fecha y desactiva la carga
    setState(() {
      _tasksByDate = tasksByDate;
      isLoading = false;
    });
  }

  // Método público para recargar las tareas, puede ser llamado desde `HomeScreen`
  void reloadTasks() => _loadTasks();

  // Función que devuelve las tareas correspondientes a una fecha específica
  List<Map<String, dynamic>> _getTasksForDay(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _tasksByDate[normalizedDate] ?? [];
  }

  // Navega a la pantalla `NewTaskScreen` para agregar una nueva tarea
  Future<void> _navigateToNewTaskScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NewTaskScreen(selectedDate: _selectedDay ?? _focusedDay),
      ),
    );

    // Si se agregó una nueva tarea, recarga las tareas
    if (result == true) {
      _loadTasks();
    }
  }

  // Método `build` que define la interfaz de usuario del widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Calendario de Tareas')), // Título de la pantalla
      body: Column(
        children: [
          // Widget `TableCalendar` para mostrar el calendario
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1), // Primer día del calendario
            lastDay: DateTime.utc(2030, 12, 31), // Último día del calendario
            focusedDay: _focusedDay, // Día actualmente enfocado
            calendarFormat: _calendarFormat, // Formato del calendario
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format; // Cambia el formato del calendario
              });
            },
            selectedDayPredicate: (day) =>
                isSameDay(_selectedDay, day), // Define el día seleccionado
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay; // Actualiza el día seleccionado
                _focusedDay = focusedDay; // Actualiza el día enfocado
              });
            },
            eventLoader:
                _getTasksForDay, // Carga eventos para los días con tareas
          ),
          const SizedBox(
              height: 10), // Espacio entre el calendario y la lista de tareas
          Expanded(
            child:
                isLoading // Muestra un indicador de carga si `isLoading` es true
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount:
                            _getTasksForDay(_selectedDay ?? _focusedDay).length,
                        itemBuilder: (context, index) {
                          final task = _getTasksForDay(
                              _selectedDay ?? _focusedDay)[index];
                          return ListTile(
                            title: Text(task['subject'] ??
                                'Sin materia'), // Muestra la materia de la tarea
                            subtitle: Text(task['description'] ??
                                'Sin descripción'), // Muestra la descripción de la tarea
                            trailing: Text(task['status'] ??
                                'Pendiente'), // Muestra el estado de la tarea
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
