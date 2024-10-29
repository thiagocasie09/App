import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getPublish() async {
  List publish = [];

  CollectionReference collectionReferencePublish = db.collection('Publication');

  QuerySnapshot queryPublish = await collectionReferencePublish.get();

  queryPublish.docs.forEach((documento) {
    publish.add(documento.data());
  });

  return publish;
}

// Función para agregar una nueva publicación
Future<void> addPublish(Map<String, dynamic> newPublish) async {
  try {
    CollectionReference collectionReferencePublish =
        db.collection('Publication');
    await collectionReferencePublish
        .add(newPublish); // Añadir el nuevo documento a la colección
  } catch (e) {
    print("Error al agregar publicación: $e");
  }
}
