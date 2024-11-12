import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 35, 142, 230),
        elevation: 5,
        toolbarHeight: 80,
        leading: Container(
          padding: const EdgeInsets.all(9),
          child: Image.asset(
            "assets/images/TranparentLogo.png",
            fit: BoxFit.cover,
          ),
        ),
        leadingWidth: 120,
      ),
      body: cuerpo(context), // Pasamos el contexto aquí
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Biblioteca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: const Color.fromARGB(255, 35, 142, 230),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

Widget cuerpo(BuildContext context) { // Recibe el contexto aquí
  return Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/images/fondoNubes.jpg"),
        fit: BoxFit.cover,
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          top: 150,
          left: 20,
          child: juego1(),
        ),
        Positioned(
          top: 300,
          right: 20,
          child: juego2(context), // Pasamos el contexto aquí
        ),
        Positioned(
          top: 450,
          left: 20,
          child: juego3(),
        ),
        Positioned(
          top: 600,
          right: 20,
          child: juego4(),
        ),
      ],
    ),
  );
}

Widget juego1() {
  return TextButton(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color.fromARGB(255, 35, 142, 230),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
    ),
    onPressed: () {},
    child: const Text(
      "Conecta palabras!",
      style: TextStyle(
        fontSize: 30,
        fontFamily: 'IntensaFuente',
      ),
    ),
  );
}

Widget juego2(BuildContext context) { // Recibe el contexto
  return TextButton(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color.fromARGB(255, 35, 142, 230),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
    ),
    onPressed: () {
      context.go('/juegoRompecabezas'); // Navegación usando go_router
    },
    child: const Text(
      "Rompecabezas",
      style: TextStyle(fontSize: 30, fontFamily: 'IntensaFuente'),
    ),
  );
}

Widget juego3() {
  return TextButton(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color.fromARGB(255, 35, 142, 230),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
    ),
    onPressed: () {},
    child: const Text(
      "Construye historias",
      style: TextStyle(fontSize: 30, fontFamily: 'IntensaFuente'),
    ),
  );
}

Widget juego4() {
  return TextButton(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color.fromARGB(255, 35, 142, 230),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
    ),
    onPressed: () {},
    child: const Text(
      "Que falta?",
      style: TextStyle(fontSize: 40, fontFamily: 'IntensaFuente'),
    ),
  );
}
