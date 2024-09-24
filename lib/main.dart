import 'package:flutter/material.dart';

void main() => runApp(const MiApp());

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'mi app',
      home: Inicio(),
    );
  }
}

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        toolbarHeight: 80,
        leading: Container(
          padding: const EdgeInsets.all(10),
          child: Image.network(
            "https://image.tuasaude.com/media/article/gf/wa/autismo_24801_l.jpg",
            fit: BoxFit.cover,
          ),
        ),
        leadingWidth: 150,
      ),
      body: cuerpo(),
    );
  }
}

Widget cuerpo() {
  return Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: NetworkImage("https://static.vecteezy.com/system/resources/previews/015/310/018/non_2x/children-s-drawing-background-hand-drawn-style-for-children-free-vector.jpg"),
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
          child: juego2(),
        ),
        Positioned(
          bottom: 370,
          left: 20,
          child: juego3(),
        ),
        Positioned(
          bottom: 200,
          right: 30,
          child: juego4(),
        )
      ],
    ),
  );
}

Widget juego1() {
  return TextButton(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.green,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    ),
    onPressed: () {},
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.network(
          "https://api.placeholder.com/400/320", // Reemplaza con la URL de tu imagen
          width: 50,
          height: 50,
        ),
        const SizedBox(width: 10),
        const Text("Juego 1", style: TextStyle(fontSize: 25)),
      ],
    ),
  );
}

Widget juego2() {
  return TextButton(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.green,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    ),
    onPressed: () {},
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.network(
          "https://api.placeholder.com/400/320", // Reemplaza con la URL de tu imagen
          width: 50,
          height: 50,
        ),
        const SizedBox(width: 10),
        const Text("Juego 2", style: TextStyle(fontSize: 25)),
      ],
    ),
  );
}

Widget juego3() {
  return TextButton(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.green,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    ),
    onPressed: () {},
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.network(
          "https://api.placeholder.com/400/320", // Reemplaza con la URL de tu imagen
          width: 50,
          height: 50,
        ),
        const SizedBox(width: 10),
        const Text("Juego 3", style: TextStyle(fontSize: 25)),
      ],
    ),
  );
}

Widget juego4() {
  return TextButton(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.green,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    ),
    onPressed: () {},
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.network(
          "https://api.placeholder.com/400/320", // Reemplaza con la URL de tu imagen
          width: 50,
          height: 50,
        ),
        const SizedBox(width: 10),
        const Text("Juego 4", style: TextStyle(fontSize: 25)),
      ],
    ),
  );
}