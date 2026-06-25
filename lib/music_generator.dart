import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'models/user_data.dart';

class MusicGeneratorPage extends StatefulWidget {
  const MusicGeneratorPage({super.key});

  @override
  State<MusicGeneratorPage> createState() => _MusicGeneratorPageState();
}

class _MusicGeneratorPageState extends State<MusicGeneratorPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  List<String> _generatedNotes = [];
  int _currentNoteIndex = 0;
  Timer? _musicTimer;

  // Mapowanie nut do plików dźwiękowych
  final Map<String, String> _noteToSoundFile = {
    'C4': 'sounds/c4.wav',
    'D4': 'sounds/d4.wav',
    'E4': 'sounds/e4.wav',
    'F4': 'sounds/f4.wav',
    'G4': 'sounds/g4.wav',
    'A4': 'sounds/a4.wav',
    'B4': 'sounds/b4.wav',
    'C5': 'sounds/c5.wav',
    'D5': 'sounds/d5.wav',
    'E5': 'sounds/e5.wav',
    'F5': 'sounds/f5.wav',
    'G5': 'sounds/g5.wav',
    'A5': 'sounds/a5.wav',
    'B5': 'sounds/b5.wav',
  };

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    _musicTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playNote(String note) async {
    try {
      // Znajdź odpowiedni plik dźwiękowy dla nuty
      String soundFile = _noteToSoundFile[note] ?? 'sounds/c4.wav';
      await _audioPlayer.stop(); // Zatrzymaj poprzedni dźwięk
      await _audioPlayer.play(AssetSource(soundFile));
    } catch (e) {
      // Fallback na C4 w przypadku błędu
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/c4.wav'));
    }
  }

  Future<void> _generateAndPlayMusic(UserData userData) async {
    if (_isPlaying) {
      _stopMusic();
      return;
    }

    // Generuj nuty w zależności od nastroju
    _generatedNotes = _generateMusicNotes(userData);

    setState(() {
      _isPlaying = true;
      _currentNoteIndex = 0;
    });

    int noteDuration = (160000 / userData.tempo).round(); //długość dźwięku w ms dzielone na tępo użytkownika

    _musicTimer?.cancel();
    _musicTimer = Timer.periodic(
      Duration(milliseconds: noteDuration),
          (timer) async {
        if (_currentNoteIndex >= _generatedNotes.length || !_isPlaying) {
          _stopMusic();
          return;
        }

        String note = _generatedNotes[_currentNoteIndex];
        await _playNote(note);

        setState(() {
          _currentNoteIndex++;
        });
      },
    );
  }

  List<String> _generateMusicNotes(UserData userData) {
    Random random = Random();
    List<String> notes = [];

    // Skale dla różnych nastrojów
    Map<Mood, List<String>> moodScales = {
      Mood.happy: ['C4', 'E4', 'G4', 'C5', 'E5', 'G5'],
      Mood.sad: ['C4', 'D4', 'G4', 'C5', 'D5', 'G5'],
      Mood.energetic: ['C4', 'D4', 'E4', 'G4', 'A4', 'C5', 'D5', 'E5'],
      Mood.calm: ['C4', 'E4', 'G4', 'A4', 'C5', 'E5'],
      Mood.neutral: ['A4', 'A5', 'B4', 'B5', 'C4', 'C5', 'D4', 'D5', 'E4', 'E5' , 'F4', 'F5', 'G4', 'G5'], // Pełna skala
    };

    // Pobierz skalę dla aktualnego nastroju
    List<String> scale = moodScales[userData.mood] ?? moodScales[Mood.neutral]!;

    // Generuj 8-16 nut w zależności od złożoności
    int noteCount = 8 + (userData.complexity * 8).toInt();

    for (int i = 0; i < noteCount; i++) {
      // Wybierz losową nutę ze skali
      String note = scale[random.nextInt(scale.length)];

      // Dla większej złożoności, czasami zmienia oktawe
      if (userData.complexity > 0.5 && random.nextDouble() > 0.7) {
        if (note.contains('4')) {
          note = note.replaceAll('4', '5');
        } else if (note.contains('5') && random.nextBool()) {
          note = note.replaceAll('5', '4');
        }
      }


      notes.add(note);
    }

    return notes;
  }

  void _stopMusic() {
    _musicTimer?.cancel();
    _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _currentNoteIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Generator Muzyki',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 40),
              Icon(
                _isPlaying ? Icons.music_note : Icons.music_off,
                size: 100,
                color: userData.favoriteColor,
              ),
              const SizedBox(height: 20),

              // Status odtwarzania
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: userData.favoriteColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isPlaying ? Icons.play_arrow : Icons.pause,
                      color: userData.favoriteColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isPlaying
                          ? 'Odtwarzanie: ${userData.mood.displayName}'
                          : 'Gotowy do generowania',
                      style: TextStyle(
                        color: userData.favoriteColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Przyciski sterujące
              ElevatedButton.icon(
                onPressed: () => _generateAndPlayMusic(userData),
                icon: Icon(
                  _isPlaying ? Icons.stop : Icons.play_arrow,
                  size: 30,
                ),
                label: Text(
                  _isPlaying ? 'ZATRZYMAJ' : 'GENERUJ MUZYKĘ',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  backgroundColor: userData.favoriteColor,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // Wyświetl wygenerowane nuty
              if (_generatedNotes.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wygenerowana muzyka:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Nastrój: ${userData.mood.displayName} ${userData.mood.emoji}',
                      style: TextStyle(
                        fontSize: 16,
                        color: userData.favoriteColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _generatedNotes.asMap().entries.map((entry) {
                        int index = entry.key;
                        String note = entry.value;

                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _currentNoteIndex > index
                                ? userData.favoriteColor.withValues(alpha: 0.3)
                                : _currentNoteIndex == index
                                ? userData.favoriteColor
                                : userData.favoriteColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: userData.favoriteColor,
                              width: _currentNoteIndex == index ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            note,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _currentNoteIndex == index
                                  ? Colors.white
                                  : userData.favoriteColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}