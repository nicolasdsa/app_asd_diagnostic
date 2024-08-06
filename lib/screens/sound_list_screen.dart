import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/sound_dao.dart';
import 'package:app_asd_diagnostic/models/sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

class SoundListScreen extends StatefulWidget {
  final Function(int) onSoundSelected;

  SoundListScreen({required this.onSoundSelected});

  final _SoundListScreenState _soundListScreenState = _SoundListScreenState();

  void stopCurrentSound() {
    _soundListScreenState.stopSound();
  }

  @override
  _SoundListScreenState createState() => _soundListScreenState;
}

class _SoundListScreenState extends State<SoundListScreen>
    with WidgetsBindingObserver {
  final SoundDao _soundDao = SoundDao();
  List<Sound> _sounds = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingSound;
  String? _selectedFilePath;

  @override
  void initState() {
    super.initState();
    _fetchSounds();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      stopSound();
    }
  }

  Future<void> _fetchSounds() async {
    final sounds = await _soundDao.getAll();
    setState(() {
      _sounds = sounds;
    });
  }

  Future<void> _addSound(Sound sound) async {
    await _soundDao.insert(sound);
    _fetchSounds();
  }

  Future<void> _deleteSound(int id) async {
    await _soundDao.delete(id);
    _fetchSounds();
  }

  void _playSound(String filePath) async {
    if (_currentPlayingSound == filePath) {
      await _audioPlayer.stop();
      setState(() {
        _currentPlayingSound = null;
      });
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.setSource(UrlSource(filePath));
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(UrlSource(filePath));
      setState(() {
        _currentPlayingSound = filePath;
      });
    }
  }

  void stopSound() async {
    if (_currentPlayingSound != null) {
      await _audioPlayer.stop();
      setState(() {
        _currentPlayingSound = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _sounds.isEmpty
            ? Center(child: Text('Nenhum som adicionado'))
            : Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _sounds.length,
                  itemBuilder: (context, index) {
                    final sound = _sounds[index];
                    return ListTile(
                      leading: IconButton(
                        icon: Icon(
                          _currentPlayingSound == sound.filePath
                              ? Icons.stop
                              : Icons.play_arrow,
                        ),
                        onPressed: () => _playSound(sound.filePath),
                      ),
                      title: Text(sound.name),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteSound(sound.id!),
                      ),
                      onLongPress: () {
                        widget.onSoundSelected(sound.id!);
                      },
                    );
                  },
                ),
              ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _showAddSoundDialog,
            child: Text('Adicionar Som'),
          ),
        ),
      ],
    );
  }

  void _showAddSoundDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Som'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(type: FileType.audio);
                  if (result != null) {
                    setState(() {
                      _selectedFilePath = result.files.single.path!;
                    });
                  }
                },
                child: Text('Escolher Arquivo de Som'),
              ),
              if (_selectedFilePath != null) Text('Arquivo selecionado!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_selectedFilePath != null &&
                    nameController.text.isNotEmpty) {
                  final sound = Sound(
                    name: nameController.text,
                    filePath: _selectedFilePath!,
                  );
                  _addSound(sound);
                  Navigator.pop(context);
                }
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
