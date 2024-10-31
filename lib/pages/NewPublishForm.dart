import 'package:flutter/material.dart'; // Importa widgets de Flutter
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore para guardar datos
import 'dart:io'; // Importa la clase File para manejar archivos locales
import 'package:firebase_storage/firebase_storage.dart'; // Importa Firebase Storage para subir archivos
import 'package:image_picker/image_picker.dart'; // Importa ImagePicker para seleccionar imágenes

class NewPublishForm extends StatefulWidget {
  final String? documentId; // Recibe el ID de la publicación para editar

  const NewPublishForm({Key? key, this.documentId}) : super(key: key);

  @override
  _NewPublishFormState createState() =>
      _NewPublishFormState(); // Crea el estado del widget
}

class _NewPublishFormState extends State<NewPublishForm> {
  final _formKey =
      GlobalKey<FormState>(); // Clave global para validar el formulario
  String publisher = ''; // Variable para almacenar el nombre del publicador
  String description = ''; // Variable para almacenar la descripción
  String publishimage = ''; // Variable para almacenar la URL de la imagen
  bool isLoading = false; // Variable para mostrar el estado de carga
  File? imageFile; // Variable para almacenar la imagen seleccionada

  @override
  void initState() {
    super.initState();
    if (widget.documentId != null) {
      loadPublishData(
          widget.documentId!); // Cargar datos si estamos en modo edición
    }
  }

  // Función para cargar los datos de la publicación en modo edición
  void loadPublishData(String documentId) async {
    setState(() {
      isLoading = true; // Muestra el indicador de carga
    });

    try {
      // Obtiene los datos de Firestore usando el documentId
      final doc = await FirebaseFirestore.instance
          .collection('Publication')
          .doc(documentId)
          .get();
      if (doc.exists) {
        // Asigna los valores de Firestore a las variables locales
        setState(() {
          publisher = doc['publisher'] ?? '';
          description = doc['description'] ?? '';
          publishimage = doc['publishimage'] ?? '';
        });
      }
    } catch (e) {
      print(
          "Error al cargar los datos: $e"); // Muestra un mensaje de error si falla la carga
    } finally {
      setState(() {
        isLoading = false; // Oculta el indicador de carga
      });
    }
  }

  // Método para seleccionar una imagen, subirla y obtener la URL de descarga
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path); // **Asignar imagen seleccionada**
      });

      // **Sube la imagen y asigna la URL a `publishimage`**
      publishimage = await uploadImage(imageFile!) ?? '';
      setState(() {}); // **Actualiza la interfaz para mostrar la URL**
    }
  }

  // Método para subir la imagen a Firebase Storage y obtener la URL de descarga
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Genera un nombre único para la imagen basado en la fecha y hora actuales
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Crea una referencia en Firebase Storage para la imagen
      final storageRef =
          FirebaseStorage.instance.ref().child("images/$fileName");

      // Sube el archivo a Firebase Storage
      await storageRef.putFile(imageFile);

      // Obtiene la URL de descarga de la imagen cargada
      return await storageRef.getDownloadURL();
    } catch (e) {
      print(
          "Error al subir la imagen: $e"); // Muestra un mensaje de error si falla la carga
      return null; // Retorna null en caso de error
    }
  }

  // Función para guardar o actualizar la publicación
  Future<void> savePublish() async {
    // Valida el formulario, si no es válido, se detiene
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save(); // Guarda los valores del formulario

    setState(() {
      isLoading = true; // Muestra el indicador de carga
    });

    try {
      // Si hay una imagen seleccionada, súbela a Firebase Storage
      if (imageFile != null) {
        // Llama a uploadImage y actualiza publishimage con la URL obtenida
        publishimage = await uploadImage(imageFile!) ?? publishimage;
      }
      final timestamp = Timestamp.now(); // Obtiene el timestamp actual
      // Crea un mapa con los datos de la publicación
      final publishData = {
        'publisher': publisher,
        'description': description,
        'publishimage': publishimage,
        'Date': timestamp,
      };

      if (widget.documentId != null) {
        // Si estamos en modo edición, actualizamos la publicación existente
        await FirebaseFirestore.instance
            .collection('Publication')
            .doc(widget.documentId)
            .update(publishData);
      } else {
        // Si no hay documentId, estamos creando una nueva publicación
        await FirebaseFirestore.instance
            .collection('Publication')
            .add(publishData);
      }

      Navigator.pop(
          context, true); // Vuelve a la pantalla anterior y devuelve true
    } catch (e) {
      print(
          "Error al guardar la publicación: $e"); // Muestra un mensaje de error si falla la carga
    } finally {
      setState(() {
        isLoading = false; // Oculta el indicador de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentId != null
            ? 'Editar Publicación'
            : 'Nueva Publicación'), // Título dinámico según el modo
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Muestra un indicador de carga si isLoading es verdadero
          : Padding(
              padding:
                  const EdgeInsets.all(16.0), // Padding alrededor del contenido
              child: Form(
                key: _formKey, // Asigna la clave global al formulario
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      initialValue: publisher, // Valor inicial en modo edición
                      decoration: const InputDecoration(
                          labelText: 'Nombre', prefixIcon: Icon(Icons.person)),
                      onSaved: (value) => publisher =
                          value ?? '', // Guarda el valor ingresado en publisher
                      validator: (value) => value == null || value.isEmpty
                          ? 'Por favor ingrese un nombre'
                          : null, // Validación
                    ),
                    TextFormField(
                      initialValue:
                          description, // Valor inicial en modo edición
                      decoration: const InputDecoration(
                          labelText: 'Descripción',
                          prefixIcon: Icon(Icons.text_fields)),
                      onSaved: (value) => description = value ??
                          '', // Guarda el valor ingresado en description
                    ),
                    TextFormField(
                      initialValue:
                          publishimage, // Valor inicial en modo edición
                      decoration: const InputDecoration(
                          labelText: 'URL de la Imagen',
                          prefixIcon: Icon(Icons.image)),
                      onSaved: (value) => publishimage = value ?? '',
                      enabled:
                          false, // Guarda el valor ingresado en publishimage
                      // readOnly: true,
                    ),
                    const SizedBox(height: 20), // Espacio entre los elementos
                    ElevatedButton(
                        onPressed: pickImage,
                        child: const Text(
                            "Seleccionar Imagen")), // Botón para seleccionar imagen
                    SizedBox(height: 20), // Espacio entre los elementos
                    ElevatedButton(
                      onPressed:
                          savePublish, // Llama a savePublish al presionar el botón
                      child: Text(widget.documentId != null
                          ? 'Actualizar'
                          : 'Guardar'), // Texto dinámico en el botón
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
