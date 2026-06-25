import 'package:flutter/material.dart';
import 'package:generator/image_generator.dart';
import 'package:generator/music_generator.dart';
import 'package:generator/models/user_data.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import 'gallery.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const UserInputPage(),
    const MusicGeneratorPage(),
    const ImageGeneratorPage(),
    const GalleryPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksperymenty z Multimediami'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.green,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Dane',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Muzyka',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Obrazy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Galeria',
          ),
        ],
      ),
    );
  }
}

class UserInputPage extends StatelessWidget {
  const UserInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Konfiguruj swoje doświadczenie',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // Imię
          TextField(
            decoration: const InputDecoration(
              labelText: 'Twoje imię lub pseudonim',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            onChanged: userData.updateName,
          ),
          const SizedBox(height: 20),

          // Nastrój
          const Text('Nastrój:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: Mood.values.map((mood) {
              return FilterChip(
                label: Text('${mood.emoji} ${mood.displayName}'),
                selected: userData.mood == mood,
                onSelected: (_) => userData.updateMood(mood),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),

          // Ulubiony kolor
          const Text('Ulubiony kolor:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Wybierz kolor'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: userData.favoriteColor,
                        onColorChanged: userData.updateColor,
                        pickerAreaHeightPercent: 0.8,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: userData.favoriteColor.withValues(alpha: 100),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: Center(
                child: Text(
                  'Kliknij, aby zmienić kolor',
                  style: TextStyle(
                    color: userData.favoriteColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Tempo muzyki
          const Text('Tempo muzyki:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: userData.tempo.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 14,
                  label: '${userData.tempo} %',
                  onChanged: (value) {
                    userData.updateTempo(value.toInt());
                  },
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${userData.tempo} %',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Motyw obrazu
          const Text('Motyw obrazu:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: ['Abstrakcyjny', 'Natura', 'Geometria', 'Kosmos', 'Woda']
                .map((theme) {
              return FilterChip(
                label: Text(theme),
                selected: userData.imageTheme == theme,
                onSelected: (_) => userData.updateTheme(theme),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),

          // Złożoność
          const Text('Złożoność generowania:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Slider(
            value: userData.complexity,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            label: '${(userData.complexity * 100).toInt()}%',
            onChanged: userData.updateComplexity,
          ),
        ],
      ),
    );
  }
}