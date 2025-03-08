import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class SoundAdditionPage extends StatefulWidget {
  const SoundAdditionPage({super.key});

  @override
  SoundAdditionPageState createState() => SoundAdditionPageState();
}

class SoundAdditionPageState extends State<SoundAdditionPage> {
  late AudioPlayer _player;
  String _currentSound = '';
  String _searchQuery = '';
  List<String> _customSoundFiles = []; // 사용자 선택 파일 리스트

  final List<String> _defaultSoundFiles = [
    'sound/alarm_cuckoo.mp3',
    'sound/alarm_sound.mp3',
    'sound/alarm_bell.mp3',
    'sound/alarm_gun.mp3',
    'sound/alarm_emergency.mp3',
  ];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _player.onPlayerComplete.listen((event) {
      setState(() {
        _currentSound = '';
      });
    });

    _loadCustomSounds(); // 앱 시작 시 사용자 사운드 파일 불러오기
  }

  Future<void> _loadCustomSounds() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customSoundFiles = prefs.getStringList('customSoundFiles') ?? [];
    });
  }

  Future<void> _saveCustomSounds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('customSoundFiles', _customSoundFiles);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playSound(String soundPath) async {
    if (_currentSound == soundPath) {
      await _player.stop();
      setState(() {
        _currentSound = '';
      });
    } else {
      await _player.stop();
      setState(() {
        _currentSound = soundPath;
      });

      if (_defaultSoundFiles.contains(soundPath)) {
        await _player.play(AssetSource(soundPath));
      } else {
        await _player.play(DeviceFileSource(soundPath)); // 로컬 파일 재생
      }
    }
  }

  Future<void> _addCustomSound() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(file.path);

      // 로컬 디렉토리에 파일 복사
      final localFile = await file.copy('${appDir.path}/$fileName');

      setState(() {
        _customSoundFiles.add(localFile.path);
      });

      await _saveCustomSounds(); // 파일 경로를 저장
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final filteredDefaultSoundFiles = _defaultSoundFiles.where((file) {
      final soundName = file.split('/').last.split('.')[0].split('_').last;
      return soundName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 사운드 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFEAD3B2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: textColor.withValues(alpha: 0.7)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '사운드 검색',
                        hintStyle:
                            TextStyle(color: textColor.withValues(alpha: 0.7)),
                        border: InputBorder.none,
                      ),
                      onChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '기본',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredDefaultSoundFiles.length,
                      itemBuilder: (context, index) {
                        final soundFile = filteredDefaultSoundFiles[index];
                        final soundName = soundFile
                            .split('/')
                            .last
                            .split('.')[0]
                            .split('_')
                            .last;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 0.0),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : const Color(0xFFEAD3B2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.music_note, color: textColor),
                            ),
                            title: Text(soundName),
                            trailing: IconButton(
                              icon: Icon(
                                _currentSound == soundFile
                                    ? Icons.stop
                                    : Icons.volume_up,
                                color: textColor,
                              ),
                              onPressed: () => _playSound(soundFile),
                            ),
                          ),
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '나만의 사운드',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _customSoundFiles.length,
                      itemBuilder: (context, index) {
                        final soundFile = _customSoundFiles[index];
                        final soundName = soundFile.split('/').last;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 0.0),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : const Color(0xFFEAD3B2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.music_note, color: textColor),
                            ),
                            title: Text(soundName),
                            trailing: IconButton(
                              icon: Icon(
                                _currentSound == soundFile
                                    ? Icons.stop
                                    : Icons.volume_up,
                                color: textColor,
                              ),
                              onPressed: () => _playSound(soundFile),
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _addCustomSound,
                            icon: Icon(Icons.add, color: textColor),
                            label: Text(
                              '추가하기',
                              style: TextStyle(color: textColor),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : const Color(0xFFEAD3B2),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
