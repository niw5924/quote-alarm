import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import '../utils/toast_util.dart';
import '../widgets/buttons/themed_icon_button.dart';

class SoundAdditionScreen extends StatefulWidget {
  const SoundAdditionScreen({super.key});

  @override
  SoundAdditionScreenState createState() => SoundAdditionScreenState();
}

class SoundAdditionScreenState extends State<SoundAdditionScreen> {
  late AudioPlayer _player;

  List<String> _customSoundFiles = []; // 사용자 선택 파일 리스트
  final List<String> _defaultSoundFiles = [
    'sounds/alarm_cuckoo.mp3',
    'sounds/alarm_sound.mp3',
    'sounds/alarm_bell.mp3',
    'sounds/alarm_gun.mp3',
    'sounds/alarm_emergency.mp3',
  ];

  String _currentSound = '';
  String _searchQuery = '';

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

  Future<void> _addCustomSound() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(file.path);
      final localFilePath = '${appDir.path}/$fileName';

      // 중복 확인 후 추가 (같은 파일이 있으면 추가하지 않음)
      if (!_customSoundFiles.contains(localFilePath)) {
        final localFile = await file.copy(localFilePath);

        setState(() {
          _customSoundFiles.add(localFile.path);
        });

        await _saveCustomSounds(); // 파일 경로를 저장

        ToastUtil.showSuccess(
          "'${path.basenameWithoutExtension(fileName)}'이(가) 추가되었습니다!",
        );
      } else {
        ToastUtil.showFailure("이미 추가된 파일입니다.");
      }
    }
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

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final filteredDefaultSoundFiles = _defaultSoundFiles.where((file) {
      final soundName = path.basenameWithoutExtension(file);
      return soundName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final filteredCustomSoundFiles = _customSoundFiles.where((file) {
      final soundName = path.basenameWithoutExtension(file);
      return soundName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('사운드 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                prefixIcon:
                    Icon(Icons.search, color: textColor.withValues(alpha: 0.7)),
                hintText: '사운드 검색',
                hintStyle: TextStyle(color: textColor.withValues(alpha: 0.7)),
                filled: true,
                fillColor:
                    isDarkMode ? Colors.grey[850] : const Color(0xFFEAD3B2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '기본',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredDefaultSoundFiles.length,
                      itemBuilder: (context, index) {
                        final soundFile = filteredDefaultSoundFiles[index];
                        final soundName =
                            path.basenameWithoutExtension(soundFile);

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[850]
                                  : const Color(0xFFEAD3B2),
                              borderRadius: BorderRadius.circular(10.0),
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
                        );
                      },
                    ),
                    Divider(
                      color: isDarkMode
                          ? Colors.grey[850]
                          : const Color(0xFFEAD3B2),
                    ),
                    const Text(
                      '나만의 사운드',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredCustomSoundFiles.length,
                      itemBuilder: (context, index) {
                        final soundFile = filteredCustomSoundFiles[index];
                        final soundName =
                            path.basenameWithoutExtension(soundFile);

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[850]
                                  : const Color(0xFFEAD3B2),
                              borderRadius: BorderRadius.circular(10.0),
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
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    ThemedIconButton(
                      width: double.infinity,
                      icon: Icons.add,
                      label: '추가하기',
                      onPressed: _addCustomSound,
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
