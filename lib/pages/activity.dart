import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  String subject;
  String description;
  bool isCompleted; // Indica si la actividad está completada
  String? comment; // Comentario de la actividad cuando se marca como completada
  DateTime? date; // Fecha de la actividad
  String? status; // El estado de la actividad (e.g. 'Completada', 'Pendiente')

  Activity({
    required this.id,
    required this.subject,
    required this.description,
    this.isCompleted = false,
    this.comment,
    this.date,
    this.status = 'Pendiente',
  });

  factory Activity.fromMap(Map<String, dynamic> data) {
    DateTime? activityDate;
    if (data['date'] is Timestamp) {
      activityDate = (data['date'] as Timestamp)
          .toDate(); // Convierte Timestamp a DateTime
    }

    return Activity(
      id: data['id'] ?? '',
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      isCompleted: data['status'] == 'Completada',
      comment: data['comment'],
      date: activityDate,
      status: data['status'] ?? 'Pendiente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'description': description,
      'status': isCompleted ? 'Completada' : 'Pendiente',
      'comment': comment,
      'date': date != null ? Timestamp.fromDate(date!) : null,
    };
  }
}
