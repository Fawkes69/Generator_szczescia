import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<File> _imageFiles = [];
  bool _isLoading = true;
  bool _isEmpty = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final myImagesFolder = Directory('${directory.path}/my_generated_images');

      if (!await myImagesFolder.exists()) {
        setState(() {
          _isLoading = false;
          _isEmpty = true;
        });
        return;
      }

      // Wczytaj listę obrazów
      final listFile = File('${myImagesFolder.path}/_images_list.txt');
      List<File> images = [];

      if (await listFile.exists()) {
        final content = await listFile.readAsString();
        final paths = content.split('\n').where((path) => path.isNotEmpty).toList();

        for (var path in paths) {
          final file = File(path);
          if (await file.exists()) {
            images.add(file);
          }
        }
      } else {
        final files = await myImagesFolder.list().toList();
        for (var entity in files) {
          if (entity is File && entity.path.endsWith('.png')) {
            images.add(entity);
          }
        }
      }

      // Posortuj od najnowszych
      images.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      setState(() {
        _imageFiles = images;
        _isLoading = false;
        _isEmpty = images.isEmpty;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Błąd ładowania galerii: $e');
      }
      setState(() {
        _isLoading = false;
        _isEmpty = true;
      });
    }
  }

  Future<void> _deleteImage(int index, BuildContext context) async {
    final file = _imageFiles[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń obraz'),
        content: const Text('Czy na pewno chcesz usunąć ten obraz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANULUJ'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await file.delete();

                final directory = await getApplicationDocumentsDirectory();
                final listFile = File('${directory.path}/my_generated_images/_images_list.txt');
                if (await listFile.exists()) {
                  final content = await listFile.readAsString();
                  final newContent = content.replaceAll('${file.path}\n', '');
                  await listFile.writeAsString(newContent);
                }

                setState(() {
                  _imageFiles.removeAt(index);
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Obraz usunięty'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Błąd usuwania: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('USUŃ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(int index, BuildContext context) {
    final file = _imageFiles[index];
    final fileName = file.path.split('/').last;
    final fileSize = (file.lengthSync() / 1024).toStringAsFixed(2);
    final modifiedDate = file.lastModifiedSync();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 76),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          height: 300,
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.withValues(alpha: 100)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(file, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rozmiar: ${fileSize} KB',
                          style: TextStyle(
                            color: Colors.grey.withValues(alpha: 150),
                          ),
                        ),
                        Text(
                          'Data: ${modifiedDate.day}.${modifiedDate.month}.${modifiedDate.year}',
                          style: TextStyle(
                            color: Colors.grey.withValues(alpha: 150),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('ZAMKNIJ'),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 48,
                        color: Colors.grey.withValues(alpha: 100),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteImage(index, context);
                          },
                          child: const Text(
                            'USUŃ',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 128),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withValues(alpha: 200),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshGallery() async {
    setState(() {
      _isLoading = true;
    });
    await _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor.withValues(alpha: 200),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ładowanie galerii...',
              style: TextStyle(
                color: Colors.grey.withValues(alpha: 150),
              ),
            ),
          ],
        ),
      )
          : _isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library,
              size: 80,
              color: Colors.grey.withValues(alpha: 100),
            ),
            const SizedBox(height: 20),
            Text(
              'Brak zapisanych obrazów',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.withValues(alpha: 150),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Wygeneruj obraz w Generatorze',
              style: TextStyle(
                color: Colors.grey.withValues(alpha: 120),
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _refreshGallery,
        color: Theme.of(context).primaryColor.withValues(alpha: 200),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: _imageFiles.length,
          itemBuilder: (context, index) {
            final file = _imageFiles[index];
            final fileName = file.path.split('/').last;

            return GestureDetector(
              onTap: () => _showImagePreview(index, context),
              onLongPress: () => _deleteImage(index, context),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.file(
                          file,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.withValues(alpha: 50),
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey.withValues(alpha: 100),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName.length > 20
                                ? '${fileName.substring(0, 20)}...'
                                : fileName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.withValues(alpha: 150),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: _imageFiles.isNotEmpty
          ? FloatingActionButton(
        onPressed: () {
          if (_imageFiles.isNotEmpty) {
            _showImagePreview(0, context);
          }
        },
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 200),
        child: Icon(
          Icons.slideshow,
          color: Colors.white.withValues(alpha: 200),
        ),
      )
          : null,
    );
  }
}