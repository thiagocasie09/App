import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modernlogintute/pages/newtask_screen.dart';
import 'package:modernlogintute/pages/calendar_screen.dart';
import 'package:modernlogintute/pages/profile_screen.dart';
import 'activities_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _paginaActual = 0;
  final GlobalKey<ActivitiesScreenState> _activitiesScreenKey =
      GlobalKey<ActivitiesScreenState>();
  final GlobalKey<CalendarScreenState> _calendarKey =
      GlobalKey<CalendarScreenState>();
  late List<Widget> _paginas;

  @override
  void initState() {
    super.initState();
    _paginas = [
      Column(
        children: [
          Expanded(child: CalendarScreen(key: _calendarKey)),
          Expanded(child: ActivitiesScreen(key: _activitiesScreenKey)),
        ],
      ),
      ProfileScreen(),
    ];
  }

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
    if (_paginaActual == 0) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewTaskScreen(
            selectedDate:
                _calendarKey.currentState?.selectedDay ?? DateTime.now(),
          ),
        ),
      );

      if (result == true) {
        await _activitiesScreenKey.currentState?.reloadActivities();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
              icon: Icon(Icons.settings), label: 'Configuraciones'),
        ],
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        selectedItemColor: Colors.pink,
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}
