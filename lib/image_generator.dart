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

//mieszanie kolorów wykorzystane w modelu unizmitycznym
Color shade(Color color, double amount) {
  return Color.lerp(color, Colors.white, amount)!;
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
        case 'Unizm':
          _drawUnizmShape(canvas, paint, x, y, size, random,userData);
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
        ..addText('Specjalnie dla ciebie: ${userData.name}');

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

  void _drawUnizmShape(
      Canvas canvas,
      Paint paint,
      double x,
      double y,
      double size,
      Random random,
      dynamic userData,
      ) {
    // Unizm Strzemińskiego: kompozycja prostokątów bez dominanty,rytm poziomych i pionowych podziałów płaszczyzny
    // Strzeminski unikał kompozycji skupionej w centrum
    // na potrzeby projektu nie ograniczałem się tylko do bieli, czerni i szarości
    // zamiast tego podzieliłem kolor użytkownika na 6 różnych odcieni dla zachowania wierności
    // Stopień 0 - praktycznie biały
    // Stopień 5 - lekko jaśniejszy odcień koloru użytkownika
    const int width = 400;
    const int height = 400;

    // Tło prawie białe
    final bgPaint = Paint()..color = shade(userData.favoriteColor, 0.95); // stopień 0
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      bgPaint,
    );

    // Paleta unistyczna z zastosowaniem kolorów użytkownika
    final palette = [
      shade(userData.favoriteColor, 0.0), // stopień 5
      shade(userData.favoriteColor, 0.2), // stopień 4
      shade(userData.favoriteColor, 0.4), // stopień 3
      shade(userData.favoriteColor, 0.6), // stopień 2
      shade(userData.favoriteColor, 0.8), // stopień 1
    ];

    // Podział płótna na rytmiczne pasy poziome i pionowe
    final divisions = 4 + (userData.complexity * 8).toInt(); // 4–12 podziałów

    // Pionowe pasy
    double xOffset = 0;
    for (int i = 0; i < divisions; i++) {
      final stripWidth = width / divisions * (0.7 + random.nextDouble() * 0.6);
      final rectPaint = Paint()
        ..color = palette[random.nextInt(palette.length)];

      // Każdy pas może być pełnej wysokości lub częściowej
      final topOffset = random.nextDouble() * height * 0.3;
      final bottomOffset = random.nextDouble() * height * 0.3;

      canvas.drawRect(
        Rect.fromLTWH(
          xOffset,
          topOffset,
          stripWidth.clamp(10, width.toDouble()),
          height - topOffset - bottomOffset,
        ),
        rectPaint,
      );

      xOffset += width / divisions;
      if (xOffset >= width) break;
    }

    // Poziome pasy nakładające się na siebie
    double yOffset = 0;
    final hDivisions = 3 + random.nextInt(3);
    for (int i = 0; i < hDivisions; i++) {
      final stripHeight = height / hDivisions * (0.3 + random.nextDouble() * 0.5);
      final rectPaint = Paint()
        ..color = palette[random.nextInt(palette.length)].withValues(alpha: 0.4);

      canvas.drawRect(
        Rect.fromLTWH(
          0,
          yOffset,
          width.toDouble(),
          stripHeight.clamp(5, height.toDouble()),
        ),
        rectPaint,
      );

      yOffset += height / hDivisions;
      if (yOffset >= height) break;
    }

    // Mocne prostokąty bez centrum — charakterystyczny element Unizmu
    final blockCount = 5 + random.nextInt(6);
    for (int i = 0; i < blockCount; i++) {
      final bx = random.nextDouble() * width * 0.8;
      final by = random.nextDouble() * height * 0.8;
      final bw = 20.0 + random.nextDouble() * (width * 0.4);
      final bh = 10.0 + random.nextDouble() * (height * 0.25);

      final blockPaint = Paint()
        ..color = palette[random.nextInt(palette.length)].withValues(alpha: 0.85);

      canvas.drawRect(
        Rect.fromLTWH(bx, by, bw, bh),
        blockPaint,
      );
    }

    // Cienkie linie podziału
    final linePaint = Paint()
      ..color = userData.favoriteColor.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final lineCount = 3 + random.nextInt(4);
    for (int i = 0; i < lineCount; i++) {
      final lx = random.nextDouble() * width;
      canvas.drawLine(Offset(lx, 0), Offset(lx, height.toDouble()), linePaint);
      final ly = random.nextDouble() * height;
      canvas.drawLine(Offset(0, ly), Offset(width.toDouble(), ly), linePaint);
    }
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
                      backgroundColor: userData.favoriteColor,
                      foregroundColor: userData.invertedColor.withValues(alpha: 75),
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