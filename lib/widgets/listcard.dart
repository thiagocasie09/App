import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore para interactuar con la base de datos en la nube
import 'package:flutter/material.dart';
import 'package:modernlogintute/widgets/card.dart'; // Importa los widgets de Flutter para construir la interfaz

class ListCard extends StatelessWidget {
  const ListCard({Key? key})
      : super(
            key:
                key); // Constructor de `ListCard`, permite recibir una `Key` opcional

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // StreamBuilder crea un widget que escucha cambios en tiempo real de un `Stream` de datos
      stream: FirebaseFirestore.instance
          .collection(
              'Publication') // Accede a la colección `Publication` en Firebase Firestore
          .orderBy('Date',
              descending:
                  true) // Ordena las publicaciones de forma descendente por el campo `timestamp`
          .snapshots(), // Genera un `Stream` que emite cambios en tiempo real en la colección

      builder: (context, snapshot) {
        // `builder` define cómo construir el widget en función del estado del `Stream`

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Muestra un indicador de carga mientras el `Stream` se conecta
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Muestra un mensaje de error si el `Stream` no pudo conectarse o recuperar datos
          return const Center(child: Text("Error al cargar los datos"));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // Muestra un mensaje si el `Stream` está vacío o no tiene datos
          return const Center(child: Text("No hay publicaciones disponibles"));
        }

        // Mapea los documentos de Firestore a una lista de `QueryDocumentSnapshot`
        List<QueryDocumentSnapshot> publish = snapshot.data!.docs;

        // Crea una lista de widgets basada en los datos de `publish`
        return ListView.builder(
          itemCount: publish.length, // Cantidad de elementos en `publish`
          itemBuilder: (context, index) {
            final documentData = publish[index].data() as Map<String, dynamic>;
            // Extrae los datos del documento actual en forma de `Map`

            final documentId = publish[index].id;
            // Obtiene el `documentId` único de cada documento en Firestore

            return card(
              data:
                  documentData, // Pasa los datos del documento al widget `card`
              documentId:
                  documentId, // Pasa el `documentId` al widget `card` para que pueda identificar el documento específico
            );
          },
        );
      },
    );
  }
}
