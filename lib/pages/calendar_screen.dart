import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _tasksByDate = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Cargar las tareas al inicio
  }

  Future<void> _loadTasks() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    final snapshot = await FirebaseFirestore.instance.collection('Tasks').get();
    final tasksByDate = <DateTime, List<Map<String, dynamic>>>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final task = {
        'subject': data['subject'],
        'description': data['description'],
        'status': data['status'] ?? 'Pendiente',
      };

      final normalizedDate = DateTime(date.year, date.month, date.day);
      tasksByDate[normalizedDate] = (tasksByDate[normalizedDate] ?? [])
        ..add(task);
    }

    setState(() {
      _tasksByDate = tasksByDate;
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getTasksForDay(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _tasksByDate[normalizedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario de Tareas')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                this.selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              // Esto carga los eventos para un día específico
              return _getTasksForDay(day);
            },
            calendarBuilders: CalendarBuilders(
              todayBuilder: (context, day, focusedDay) {
                return _buildDayCell(context, day, focusedDay);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildDayCell(context, day, focusedDay);
              },
              defaultBuilder: (context, day, focusedDay) {
                return _buildDayCell(context, day, focusedDay);
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount:
                        _getTasksForDay(selectedDay ?? _focusedDay).length,
                    itemBuilder: (context, index) {
                      final task =
                          _getTasksForDay(selectedDay ?? _focusedDay)[index];
                      return ListTile(
                        title: Text(task['subject'] ?? 'Sin materia'),
                        subtitle:
                            Text(task['description'] ?? 'Sin descripción'),
                        trailing: Text(task['status'] ?? 'Pendiente'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget para construir el día con los puntos de eventos
  Widget _buildDayCell(
      BuildContext context, DateTime day, DateTime focusedDay) {
    final events = _getTasksForDay(day); // Obtener eventos para este día
    return Container(
      decoration: BoxDecoration(
        color: events.isNotEmpty ? Colors.pinkAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: events.isNotEmpty ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (events.isNotEmpty)
              Positioned(
                right: 2,
                top: 2,
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: Colors.pink,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
