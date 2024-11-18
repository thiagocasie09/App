import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modernlogintute/pages/newtask_screen.dart';
import 'activity.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  @override
  ActivitiesScreenState createState() => ActivitiesScreenState();
}

class ActivitiesScreenState extends State<ActivitiesScreen> {
  List<Activity> activities = [];
  List<String> subjects = [];

  @override
  void initState() {
    super.initState();
    loadActivities();
    _loadSubjects();
  }

  void loadActivities() {
    FirebaseFirestore.instance
        .collection('Tasks')
        .snapshots()
        .listen((snapshot) {
      final loadedActivities = snapshot.docs.map((doc) {
        return Activity.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();

      setState(() {
        activities = loadedActivities;
      });
    });
  }

  Future<void> _loadSubjects() async {
    FirebaseFirestore.instance
        .collection('Subjects')
        .snapshots()
        .listen((snapshot) {
      final loadedSubjects = snapshot.docs.map((doc) {
        return doc['name'] as String;
      }).toList();

      setState(() {
        subjects = loadedSubjects;
      });
    });
  }

  Future<void> _deleteSubject(String subject) async {
    try {
      final subjectDoc = await FirebaseFirestore.instance
          .collection('Subjects')
          .where('name', isEqualTo: subject)
          .get();
      if (subjectDoc.docs.isNotEmpty) {
        final subjectId = subjectDoc.docs.first.id;
        final activitiesSnapshot = await FirebaseFirestore.instance
            .collection('Subjects')
            .doc(subjectId)
            .collection('Activities')
            .get();

        for (var activity in activitiesSnapshot.docs) {
          await activity.reference.delete();
        }

        await subjectDoc.docs.first.reference.delete();
        setState(() {
          subjects.remove(subject);
        });
      }
    } catch (e) {
      print("Error al eliminar la materia: $e");
    }
  }

  Future<void> _deleteActivity(String activityId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Tasks')
          .doc(activityId)
          .delete();
      setState(() {
        activities.removeWhere((activity) => activity.id == activityId);
      });
    } catch (e) {
      print("Error al eliminar la actividad: $e");
    }
  }

  void _createSubject(BuildContext context) async {
    final subject = await _showCreateSubjectDialog(context);
    if (subject != null) {
      await FirebaseFirestore.instance.collection('Subjects').add({
        'name': subject['name'],
      });
      _loadSubjects();
    }
  }

  Future<Map<String, String>?> _showCreateSubjectDialog(
      BuildContext context) async {
    String subjectName = '';

    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Crear Nueva Materia'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Nombre de la materia'),
            onChanged: (value) {
              subjectName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'name': subjectName,
                });
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToNewTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTaskScreen(
          selectedDate: DateTime.now(),
          subjects: subjects,
        ),
      ),
    );

    if (result == true) {
      loadActivities();
      _loadSubjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materias'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: _buildSubjectList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        heroTag: 'create_subjects_fab',
        onPressed: () => _createSubject(context),
        child: Icon(Icons.book),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSubjectList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Subjects').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final subjects = snapshot.data?.docs
                .map((doc) {
                  return doc['name'] as String;
                })
                .toSet()
                .toList() ??
            [];

        return ListView.builder(
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];

            final subjectsActivities = activities.where((activity) {
              return activity.subject == subject;
            }).toList();

            final completionPercentage =
                _getCompletionPercentage(subjectsActivities);

            return Dismissible(
              key: Key(subject),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) async {
                await _deleteSubject(subject);
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 5,
                child: ExpansionTile(
                  title: Text(subject),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: completionPercentage,
                        backgroundColor: Colors.grey[200],
                        color: Colors.pink,
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${(completionPercentage * 100).toStringAsFixed(0)}% completado',
                        style:
                            TextStyle(fontSize: 12, color: Colors.pinkAccent),
                      ),
                    ],
                  ),
                  children: subjectsActivities
                      .map((activity) => Dismissible(
                            key: Key(activity.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) async {
                              await _deleteActivity(activity.id);
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: _buildActivityTile(activity),
                          ))
                      .toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _getCompletionPercentage(List<Activity> activities) {
    if (activities.isEmpty) return 0;
    int completedCount =
        activities.where((activity) => activity.isCompleted).length;
    return completedCount / activities.length;
  }

  Widget _buildActivityTile(Activity activity) {
    return ListTile(
      title: Text(activity.description),
      subtitle: Text(
        activity.isCompleted ? 'Completado' : 'Pendiente',
        style: TextStyle(
          color: activity.isCompleted ? Colors.pinkAccent : Colors.red,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          activity.isCompleted
              ? Icons.check_box
              : Icons.check_box_outline_blank,
          color: activity.isCompleted ? Colors.pinkAccent : Colors.grey,
        ),
        onPressed: () => _toggleActivityCompletion(activity),
      ),
    );
  }

  void _toggleActivityCompletion(Activity activity) async {
    try {
      final activityRef =
          FirebaseFirestore.instance.collection('Tasks').doc(activity.id);
      final updatedStatus = !activity.isCompleted;

      await activityRef.update({
        'isCompleted': updatedStatus,
        'status': updatedStatus ? 'Completada' : 'Pendiente',
      });

      setState(() {
        activity.isCompleted = updatedStatus;
        activity.status = updatedStatus ? 'Completada' : 'Pendiente';
      });
    } catch (e) {
      print("Error al actualizar el estado de la actividad: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al actualizar la actividad")),
      );
    }
  }
}
