import 'package:flutter/material.dart';

/// Representa un pictograma: una palabra en inglés (lo que se enseña),
/// su traducción en español (para la instrucción hablada al niño),
/// y un ícono que lo representa visualmente.
///
/// Cuando tengas imágenes reales de pictogramas, agrega un campo
/// `imagePath` opcional aquí y úsalo en vez del ícono en
/// PictogramCard (mira el comentario en matchGame.dart).
class Pictogram {
  final String word; // palabra en inglés, lo que se enseña
  final String translation; // traducción en español, para instrucciones
  final IconData icon;
  final Color color;

  const Pictogram({
    required this.word,
    required this.translation,
    required this.icon,
    required this.color,
  });
}

/// Banco de pictogramas de ejemplo — vocabulario básico para kínder.
/// Agrega más aquí simplemente añadiendo otro Pictogram a la lista.
const List<Pictogram> pictogramBank = [
  Pictogram(word: 'Cat', translation: 'Gato', icon: Icons.pets, color: Color(0xFFFFA726)),
  Pictogram(word: 'Dog', translation: 'Perro', icon: Icons.cruelty_free, color: Color(0xFF8D6E63)),
  Pictogram(word: 'Apple', translation: 'Manzana', icon: Icons.apple, color: Color(0xFFE53935)),
  Pictogram(word: 'Sun', translation: 'Sol', icon: Icons.wb_sunny, color: Color(0xFFFBC02D)),
  Pictogram(word: 'Ball', translation: 'Pelota', icon: Icons.sports_soccer, color: Color(0xFF43A047)),
  Pictogram(word: 'House', translation: 'Casa', icon: Icons.home, color: Color(0xFF1E88E5)),
  Pictogram(word: 'Book', translation: 'Libro', icon: Icons.menu_book, color: Color(0xFF6D4C41)),
  Pictogram(word: 'Star', translation: 'Estrella', icon: Icons.star, color: Color(0xFFFFD54F)),
  Pictogram(word: 'Fish', translation: 'Pez', icon: Icons.set_meal, color: Color(0xFF00ACC1)),
  Pictogram(word: 'Flower', translation: 'Flor', icon: Icons.local_florist, color: Color(0xFFEC407A)),
  Pictogram(word: 'Car', translation: 'Carro', icon: Icons.directions_car, color: Color(0xFF3949AB)),
  Pictogram(word: 'Milk', translation: 'Leche', icon: Icons.local_drink, color: Color(0xFF90A4AE)),
  Pictogram(word: 'Bird', translation: 'Pájaro', icon: Icons.flutter_dash, color: Color(0xFF29B6F6)),
  Pictogram(word: 'Chair', translation: 'Silla', icon: Icons.chair, color: Color(0xFF795548)),
  Pictogram(word: 'Moon', translation: 'Luna', icon: Icons.nightlight_round, color: Color(0xFF5C6BC0)),

  // Animales
  Pictogram(word: 'Horse', translation: 'Caballo', icon: Icons.pets, color: Color(0xFF8D6E63)),
  Pictogram(word: 'Cow', translation: 'Vaca', icon: Icons.pets, color: Color(0xFF6D4C41)),
  Pictogram(word: 'Duck', translation: 'Pato', icon: Icons.pets, color: Color(0xFFFDD835)),
  Pictogram(word: 'Rabbit', translation: 'Conejo', icon: Icons.cruelty_free, color: Color(0xFFBCAAA4)),
  Pictogram(word: 'Butterfly', translation: 'Mariposa', icon: Icons.emoji_nature, color: Color(0xFFAB47BC)),
  Pictogram(word: 'Elephant', translation: 'Elefante', icon: Icons.pets, color: Color(0xFF90A4AE)),
  Pictogram(word: 'Lion', translation: 'León', icon: Icons.pets, color: Color(0xFFFFA000)),

  // Comida
  Pictogram(word: 'Banana', translation: 'Banano', icon: Icons.emoji_food_beverage, color: Color(0xFFFFEB3B)),
  Pictogram(word: 'Bread', translation: 'Pan', icon: Icons.bakery_dining, color: Color(0xFFD7A86E)),
  Pictogram(word: 'Egg', translation: 'Huevo', icon: Icons.egg, color: Color(0xFFFFF3E0)),
  Pictogram(word: 'Cheese', translation: 'Queso', icon: Icons.lunch_dining, color: Color(0xFFFFCA28)),
  Pictogram(word: 'Cake', translation: 'Pastel', icon: Icons.cake, color: Color(0xFFF06292)),
  Pictogram(word: 'Water', translation: 'Agua', icon: Icons.water_drop, color: Color(0xFF29B6F6)),

  // Cuerpo y familia
  Pictogram(word: 'Hand', translation: 'Mano', icon: Icons.back_hand, color: Color(0xFFFFAB91)),
  Pictogram(word: 'Eye', translation: 'Ojo', icon: Icons.visibility, color: Color(0xFF4FC3F7)),
  Pictogram(word: 'Mom', translation: 'Mamá', icon: Icons.face_3, color: Color(0xFFEC407A)),
  Pictogram(word: 'Dad', translation: 'Papá', icon: Icons.face, color: Color(0xFF42A5F5)),
  Pictogram(word: 'Baby', translation: 'Bebé', icon: Icons.child_care, color: Color(0xFFFFCC80)),

  // Escuela y objetos
  Pictogram(word: 'Pencil', translation: 'Lápiz', icon: Icons.edit, color: Color(0xFFFFC107)),
  Pictogram(word: 'Scissors', translation: 'Tijeras', icon: Icons.content_cut, color: Color(0xFF78909C)),
  Pictogram(word: 'Table', translation: 'Mesa', icon: Icons.table_bar, color: Color(0xFF8D6E63)),
  Pictogram(word: 'Bed', translation: 'Cama', icon: Icons.bed, color: Color(0xFF7986CB)),
  Pictogram(word: 'Clock', translation: 'Reloj', icon: Icons.access_time, color: Color(0xFF26A69A)),
  Pictogram(word: 'Umbrella', translation: 'Paraguas', icon: Icons.beach_access, color: Color(0xFF5C6BC0)),

  // Naturaleza y clima
  Pictogram(word: 'Tree', translation: 'Árbol', icon: Icons.park, color: Color(0xFF66BB6A)),
  Pictogram(word: 'Rain', translation: 'Lluvia', icon: Icons.grain, color: Color(0xFF64B5F6)),
  Pictogram(word: 'Cloud', translation: 'Nube', icon: Icons.cloud, color: Color(0xFFB0BEC5)),
  Pictogram(word: 'Mountain', translation: 'Montaña', icon: Icons.terrain, color: Color(0xFF8D6E63)),

  // Transporte
  Pictogram(word: 'Boat', translation: 'Barco', icon: Icons.directions_boat, color: Color(0xFF0288D1)),
  Pictogram(word: 'Bicycle', translation: 'Bicicleta', icon: Icons.pedal_bike, color: Color(0xFF43A047)),
  Pictogram(word: 'Airplane', translation: 'Avión', icon: Icons.flight, color: Color(0xFF42A5F5)),
];