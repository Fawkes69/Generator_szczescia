import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_data.dart';

class ImageGeneratorPage extends StatefulWidget {
  const ImageGeneratorPage({super.key});

  @override
  State<ImageGeneratorPage> createState() => _ImageGeneratorPageState();
}

class _ImageGeneratorPageState extends State<ImageGeneratorPage> {
  ui.Image? _generatedImage;
  bool _isGenerating = false;
  bool _isSaving = false;
  Uint8List? _imageBytes;

  Future<void> _generateImage(UserData userData) async {
    setState(() {
      _isGenerating = true;
    });

    // Symuluj czas generowania
    await Future.delayed(const Duration(seconds: 1));

    final image = await _createGeneratedImage(userData);

    // KONWERSJA OBRAZU NA BYTES
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    setState(() {
      _generatedImage = image;
      _imageBytes = bytes;
      _isGenerating = false;
    });
  }

  Future<ui.Image> _createGeneratedImage(UserData userData) async {
    const int width = 400;
    const int height = 400;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();
    final random = Random();

    // Tło
    paint.color = userData.favoriteColor.withValues(alpha: 25);
    canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);

    // Generuj wzory na podstawie danych użytkownika
    int shapeCount = (userData.complexity * 50 + 10).toInt();

    for (int i = 0; i < shapeCount; i++) {
      final x = random.nextDouble() * width;
      final y = random.nextDouble() * height;
      final size = random.nextDouble() * 50 + 10;

      // Dostosuj kolor na podstawie nastroju
      Color shapeColor;
      switch (userData.mood) {
        case Mood.happy:
          shapeColor = Colors.yellow.withValues(alpha: 178);
          break;
        case Mood.sad:
          shapeColor = Colors.blue.withValues(alpha: 178);
          break;
        case Mood.energetic:
          shapeColor = Colors.red.withValues(alpha: 178);
          break;
        case Mood.calm:
          shapeColor = Colors.green.withValues(alpha: 178);
          break;
        default:
          shapeColor = userData.favoriteColor.withValues(alpha: 178);
      }

      paint.color = shapeColor;

      // Różne kształty na podstawie motywu
      switch (userData.imageTheme) {
        case 'Geometria':
          _drawGeometricShape(canvas, paint, x, y, size, random);
          break;
        case 'Natura':
          _drawNatureShape(canvas, paint, x, y, size, random);
          break;
        case 'Kosmos':
          _drawSpaceShape(canvas, paint, x, y, size, random);
          break;
        case 'Woda':
          _drawWaterShape(canvas, paint, x, y, size, random);
          break;
        default:
          _drawAbstractShape(canvas, paint, x, y, size, random);
      }
    }

    // Dodaj tekst z imieniem użytkownika jeśli podane
    if (userData.name.isNotEmpty) {
      final textStyle = ui.TextStyle(
        color: userData.invertedColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );
      final paragraphBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: TextAlign.center,
        ),
      )
        ..pushStyle(textStyle)
        ..addText('Dla: ${userData.name}');

      final paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: width.toDouble()));

      canvas.drawParagraph(
        paragraph,
        Offset(
          (width - paragraph.width) / 2,
          height - 50,
        ),
      );
    }

    final picture = recorder.endRecording();
    return await picture.toImage(width, height);
  }

  void _drawGeometricShape(Canvas canvas, Paint paint, double x, double y, double size, Random random) {
    final shapeType = random.nextInt(4);

    switch (shapeType) {
      case 0:
        canvas.drawCircle(Offset(x, y), size / 2, paint);
        break;
      case 1:
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y),
            width: size,
            height: size,
          ),
          paint,
        );
        break;
      case 2:
        final path = Path()
          ..moveTo(x, y - size / 2)
          ..lineTo(x + size / 2, y + size / 2)
          ..lineTo(x - size / 2, y + size / 2)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case 3:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y),
            width: size,
            height: size * 0.6,
          ),
          paint,
        );
        break;
    }
  }

  void _drawAbstractShape(Canvas canvas, Paint paint, double x, double y, double size, Random random) {
    final path = Path();
    path.moveTo(x, y);

    for (int i = 0; i < 5; i++) {
      final angle = 2 * pi * i / 5;
      final dx = size * cos(angle) * random.nextDouble();
      final dy = size * sin(angle) * random.nextDouble();
      path.lineTo(x + dx, y + dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawNatureShape(Canvas canvas, Paint paint, double x, double y, double size, Random random) {
    final shapeType = random.nextInt(3);

    if (shapeType == 0) {
      // Drzewo
      final treePaint = Paint()..color = paint.color;
      canvas.drawCircle(Offset(x, y - size / 3), size / 2, treePaint);

      final trunkPaint = Paint()..color = Colors.brown;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y + size / 3),
          width: size / 3,
          height: size / 2,
        ),
        trunkPaint,
      );
    } else {
      // Kwiat
      final flowerPaint = Paint()..color = paint.color;
      for (int i = 0; i < 6; i++) {
        final angle = 2 * pi * i / 6;
        final dx = size / 3 * cos(angle);
        final dy = size / 3 * sin(angle);
        canvas.drawCircle(Offset(x + dx, y + dy), size / 4, flowerPaint);
      }
    }
  }

  void _drawSpaceShape(Canvas canvas, Paint paint, double x, double y, double size, Random random) {
    // Gwiazda
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 229);
    canvas.drawCircle(Offset(x, y), size / 4, starPaint);

    // Promienie
    final rayPaint = Paint()
      ..color = Colors.white.withValues(alpha: 178)
      ..strokeWidth = 2;

    for (int i = 0; i < 8; i++) {
      final angle = 2 * pi * i / 8;
      final dx = size / 1.5 * cos(angle);
      final dy = size / 1.5 * sin(angle);
      canvas.drawLine(
        Offset(x, y),
        Offset(x + dx, y + dy),
        rayPaint,
      );
    }
  }

  void _drawWaterShape(Canvas canvas, Paint paint, double x, double y, double size, Random random) {
    // Fala
    final wavePaint = Paint()
      ..color = Colors.blue.withValues(alpha: 178)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(x - size / 2, y);

    for (int i = 0; i < 4; i++) {
      final controlX = x - size / 2 + (i + 0.5) * size / 2;
      final controlY = y + (i % 2 == 0 ? -size / 4 : size / 4);
      final endX = x - size / 2 + (i + 1) * size / 2;
      path.quadraticBezierTo(controlX, controlY, endX, y);
    }

    canvas.drawPath(path, wavePaint);
  }

  Future<void> _saveImageLocally(UserData userData) async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Najpierw wygeneruj obraz'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Pobierz folder dokumentów aplikacji
      final directory = await getApplicationDocumentsDirectory();

      // 2. Utwórz folder dla obrazów
      final myImagesFolder = Directory('${directory.path}/my_generated_images');
      if (!await myImagesFolder.exists()) {
        await myImagesFolder.create(recursive: true);
      }

      // 3. Stwórz nazwę pliku
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeName = userData.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final fileName = '${safeName.isNotEmpty ? '${safeName}_' : ''}${userData.imageTheme}_$timestamp.png';
      final filePath = '${myImagesFolder.path}/$fileName';

      // 4. Zapisz plik
      final file = File(filePath);
      await file.writeAsBytes(_imageBytes!);

      // 5. Zapisz ścieżkę
      final prefs = await SharedPreferences.getInstance();
      final savedImages = prefs.getStringList('saved_images') ?? [];
      savedImages.add(filePath);
      await prefs.setStringList('saved_images', savedImages);

      // 6. Pokaż sukces
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Obraz zapisany! $fileName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd zapisu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Generator Obrazów',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Motyw: ${userData.imageTheme}',
                style: TextStyle(
                  fontSize: 16,
                  color: userData.favoriteColor.withValues(alpha: 100),
                ),
              ),

              const SizedBox(height: 40),

              // Wyświetl wygenerowany obraz
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: userData.favoriteColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: userData.favoriteColor.withValues(alpha: 76),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _isGenerating
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(userData.favoriteColor),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Generowanie obrazu...',
                        style: TextStyle(
                          color: userData.favoriteColor.withValues(alpha: 100),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                    : _generatedImage != null
                    ? RawImage(image: _generatedImage, fit: BoxFit.cover)
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        size: 60,
                        color: userData.invertedColor.withValues(alpha: 100),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Kliknij poniżej, aby wygenerować',
                        style: TextStyle(
                          color: userData.invertedColor.withValues(alpha: 100),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Przyciski sterujące
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : () => _generateImage(userData),
                    icon: Icon(
                      _isGenerating ? Icons.hourglass_top : Icons.auto_awesome,
                    ),
                    label: Text(_isGenerating ? 'Generowanie...' : 'Generuj obraz'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      backgroundColor: userData.favoriteColor,
                      foregroundColor: userData.invertedColor.withValues(alpha: 100),
                    ),
                  ),
                  const SizedBox(width: 20),
                  OutlinedButton.icon(
                    onPressed: _imageBytes == null || _isSaving
                        ? null
                        : () => _saveImageLocally(userData),
                    icon: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.download),
                    label: Text(_isSaving ? 'ZAPISYWANIE...' : 'Zapisz lokalnie'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      side: BorderSide(color: userData.favoriteColor),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Informacje o generowanym obrazie
              Card(
                color: userData.invertedColor.withValues(alpha: 100),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.palette, color: userData.favoriteColor.withValues(alpha: 100)),
                        title: const Text('Dominujący kolor'),
                        trailing: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: userData.favoriteColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: userData.invertedColor.withValues(alpha: 100)),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.category, color: userData.favoriteColor.withValues(alpha: 100)),
                        title: const Text('Motyw'),
                        trailing: Chip(
                          label: Text(
                            userData.imageTheme,
                            style: TextStyle(
                              color: userData.favoriteColor.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          backgroundColor: userData.favoriteColor.withValues(alpha: 100),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.mood, color: userData.favoriteColor.withValues(alpha: 100)),
                        title: const Text('Nastrój'),
                        trailing: Text(
                          '${userData.mood.emoji} ${userData.mood.displayName}',
                          style: TextStyle(color: userData.favoriteColor.withValues(alpha: 100)),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.layers, color: userData.favoriteColor.withValues(alpha: 100)),
                        title: const Text('Złożoność'),
                        trailing: Text(
                          '${(userData.complexity * 100).toInt()}%',
                          style: TextStyle(
                            color: userData.favoriteColor.withValues(alpha: 100),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}