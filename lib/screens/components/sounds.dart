import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/sound_dao.dart';
import 'package:app_asd_diagnostic/models/sound.dart';

class Sounds extends StatefulWidget {
  final List<dynamic> analiseInfoElements;
  final Function(String, dynamic) addElementToAnaliseInfo;
  final ValueNotifier<String?> currentPlaying;
  final AudioPlayer soundPlayer;

  const Sounds({
    super.key,
    required this.analiseInfoElements,
    required this.addElementToAnaliseInfo,
    required this.currentPlaying,
    required this.soundPlayer,
  });

  @override
  State<Sounds> createState() => SoundsState();
}

class SoundsState extends State<Sounds> with WidgetsBindingObserver {
  final SoundDao _soundDao = SoundDao();
  List<Sound> _sounds = [];
  String? _selectedFilePath;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchSounds();
  }

  @override
  void dispose() {
    stopSound();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      stopSound();
    }
  }

  void _showAddSoundDialog() {
    final nameController = TextEditingController();
    stopSound();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Som'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
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
                child: const Text('Escolher Arquivo de Som'),
              ),
              if (_selectedFilePath != null) const Text('Arquivo selecionado!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
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
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addSound(Sound sound) async {
    await _soundDao.insert(sound);
    _fetchSounds();
  }

  Future<void> _fetchSounds() async {
    final sounds = await _soundDao.getAll();
    widget.currentPlaying.value = null; // Atualiza o ValueNotifier
    setState(() {
      _sounds = sounds;
    });
  }

  void stopSound() async {
    if (widget.currentPlaying.value != null) {
      await widget.soundPlayer.stop();
      widget.currentPlaying.value = null; // Atualiza o ValueNotifier
    }
  }

  Future<void> _deleteSound(int id) async {
    await _soundDao.delete(id);
    _fetchSounds();
  }

  void _playSound(String filePath) async {
    if (widget.currentPlaying.value == filePath) {
      await widget.soundPlayer.stop();
      widget.currentPlaying.value = null;
    } else {
      await widget.soundPlayer.stop();
      await widget.soundPlayer.setSource(UrlSource(filePath));
      widget.soundPlayer.setReleaseMode(ReleaseMode.loop);
      await widget.soundPlayer.play(UrlSource(filePath));
      widget.currentPlaying.value = filePath;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<List<Sound>>(
          future: SoundDao().getAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final sounds = snapshot.data ?? [];
              return Column(
                children: sounds.map((sound) {
                  ValueNotifier<bool> isIncludedInAnalysis = ValueNotifier(
                    widget.analiseInfoElements.any((element) =>
                        element[1] == sound.id && element[0] == 'sounds'),
                  );

                  return GestureDetector(
                    onTap: () {
                      widget.addElementToAnaliseInfo('sounds', sound.id);
                      isIncludedInAnalysis.value = !isIncludedInAnalysis.value;
                    },
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isIncludedInAnalysis,
                      builder: (context, isIncluded, _) {
                        return ValueListenableBuilder<String?>(
                          valueListenable: widget.currentPlaying,
                          builder: (context, currentPlayingSound, _) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: ListTile(
                                  leading: IconButton(
                                    icon: Icon(
                                      currentPlayingSound == sound.filePath
                                          ? Icons.stop
                                          : Icons.play_arrow,
                                    ),
                                    onPressed: () => _playSound(sound.filePath),
                                  ),
                                  title: Text(sound.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium),
                                  tileColor:
                                      isIncluded ? Colors.grey : Colors.white,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteSound(sound.id!),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            }
          },
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showAddSoundDialog,
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            label: Text(
              'Adicionar Som',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        )
      ],
    );
  }
}
