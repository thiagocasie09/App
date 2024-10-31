import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modernlogintute/pages/newtask_screen.dart';
import 'package:modernlogintute/widgets/listcard.dart';
import 'package:modernlogintute/pages/NewPublishForm.dart';
import 'package:modernlogintute/pages/calendar_screen.dart';
import 'package:modernlogintute/pages/settings.dart';
import 'package:modernlogintute/pages/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _paginaActual = 0;
  Key _listKey = UniqueKey();

  // Modificamos las páginas para incluir el calendario en la pestaña principal
  final List<Widget> _paginas = [
    Column(
      children: [
        Expanded(child: CalendarScreen(key: CalendarScreen.calendarKey)),
        Expanded(child: ListCard(key: UniqueKey())),
      ],
    ),
    ProfileScreen(),
    Settings_screen(),
  ];

  // Método para cerrar sesión con confirmación
  void signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar sesión'),
        content: Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Aceptar'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  void _onFloatingActionButtonPressed() async {
    print("Botón flotante presionado en página $_paginaActual");

    if (_paginaActual == 0) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewTaskScreen(selectedDate: DateTime.now()),
        ),
      );

      if (result == true && CalendarScreen.calendarKey.currentState != null) {
        CalendarScreen.calendarKey.currentState!.reloadTasks();
      }
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewPublishForm()),
      );

      if (result == true) {
        setState(() {
          _listKey = UniqueKey();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Santiago'),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: Icon(Icons.logout),
          ),
        ],
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _paginaActual,
        children: _paginas,
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        heroTag: _paginaActual == 0 ? "calendar_fab" : "home_fab",
        onPressed: _onFloatingActionButtonPressed,
        child: const Icon(Icons.add),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (index) {
          setState(() {
            _paginaActual = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        selectedItemColor: Colors.pink,
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}
