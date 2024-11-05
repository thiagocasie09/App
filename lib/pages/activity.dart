import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  String subject;
  String description;
  bool isCompleted;
  DateTime? date;

  Activity({
    required this.id,
    required this.subject,
    required this.description,
    this.isCompleted = false,
    this.date,
  });

  factory Activity.fromMap(Map<String, dynamic> data) {
    DateTime? activityDate;
    if (data['date'] is Timestamp) {
      activityDate = (data['date'] as Timestamp)
          .toDate(); // Convierte Timestamp a DateTime
    }

    return Activity(
      id: data['id'] ?? '', // Asegurarse de que 'id' nunca sea null
      subject: data['subject'] ?? '', // Default vacío si es null
      description: data['description'] ?? '', // Default vacío si es null
      isCompleted: data['status'] == 'Completada',
      date: activityDate, // Asignamos la fecha si existe
    );
  }
}
