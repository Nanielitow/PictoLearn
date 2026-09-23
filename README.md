# PictoLearn 🧩

App móvil de pictogramas para aprender vocabulario en español, pensada para niños de kínder.

## Requisitos previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado y agregado al PATH.
- Google Chrome (para correr en web) o Android Studio (para emulador Android).
- Una cuenta de Firebase con acceso al proyecto (pídele acceso a Daniel).

## Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/Nanielitow/PictoLearn.git
cd PictoLearn

# 2. Instalar las dependencias (lee pubspec.yaml automáticamente)
flutter pub get

# 3. Verificar que todo esté bien configurado
flutter doctor
```

## Configurar Firebase (una sola vez por persona)

Este proyecto usa Firebase Authentication y Firestore. Necesitas generar tu propio
`lib/firebase_options.dart` conectado al mismo proyecto de Firebase:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Selecciona el proyecto **pictolearn-1e1c0** cuando te lo pida (te deben haber agregado
como colaborador en Firebase Console primero: Configuración del proyecto → Usuarios y permisos).

## Correr la app

```bash
flutter run -d chrome        # en el navegador
flutter run                  # en un emulador/dispositivo conectado
```

## Estructura del proyecto

```
lib/
  main.dart                  # rutas y arranque de la app
  models/                    # modelos de datos (ej. Pictogram)
  services/                  # AuthService, PictogramImageService, etc.
  pages/
    login.dart
    register.dart
    home.dart
    juegoRompecabezas.dart   # rompecabezas con pictogramas reales
    matchGame.dart           # juego de emparejar pictograma con palabra
```

## Créditos

Pictogramas por [ARASAAC](https://arasaac.org) (Gobierno de Aragón), bajo licencia
CC BY-NC-SA 4.0.
