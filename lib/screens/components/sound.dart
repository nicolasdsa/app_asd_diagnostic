import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/sound_dao.dart';
import 'package:app_asd_diagnostic/models/sound.dart';

class SoundComponent extends StatefulWidget {
  final int soundId;
  final String? initialText;
  final String? name;
  final bool showPadding;
  final bool showEditDeleteButtons;
  final ValueNotifier<List<Map<String, dynamic>>>? notifier;
  final AudioPlayer? audioPlayer;
  final ValueNotifier<String?>? currentPlaying;

  SoundComponent({
    super.key,
    required this.soundId,
    this.name,
    this.initialText,
    this.showPadding = true,
    this.showEditDeleteButtons = false,
    this.notifier,
    this.audioPlayer,
    this.currentPlaying,
  });

  final TextEditingController textController = TextEditingController();

  @override
  SoundComponentState createState() => SoundComponentState();
}

class SoundComponentState extends State<SoundComponent>
    with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;
  Sound? soundData;

  @override
  void initState() {
    super.initState();
    _audioPlayer = widget.audioPlayer ?? AudioPlayer();
    widget.textController.text = widget.initialText ?? '';
    _loadSoundData();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _loadSoundData() async {
    final soundDao = SoundDao();
    soundData = await soundDao.getSoundById(widget.soundId);

    if (soundData != null) {
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    }
    setState(() {});
  }

  Future<void> _deleteSound() async {
    final soundDao = SoundDao();
    _audioPlayer.stop();
    widget.currentPlaying!.value = '';
    bool isUse = await soundDao.checkSoundIsInForm(widget.soundId);
    if (isUse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Esse som não pode ser excluído pois já foi adicionado em um formulário')),
      );
      return;
    }

    await soundDao.delete(widget.soundId);

    if (widget.notifier != null) {
      var sounds = widget.notifier!.value;
      sounds.removeWhere((s) => s['id'] == widget.soundId);
      widget.notifier!.value = [...sounds];
    }
  }

  void _togglePlay() {
    if (widget.currentPlaying!.value == soundData!.filePath) {
      _audioPlayer.stop();
      widget.currentPlaying!.value = '';
    } else {
      _audioPlayer.play(UrlSource(soundData!.filePath));
      widget.currentPlaying!.value = soundData!.filePath;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.currentPlaying!,
      builder: (context, currentSound, child) {
        bool isCurrentPlaying = (currentSound == soundData?.filePath) ||
            (widget.currentPlaying!.value == soundData?.filePath);

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (soundData != null)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                          isCurrentPlaying ? Icons.stop : Icons.play_arrow),
                      onPressed: _togglePlay,
                    ),
                    Expanded(
                      child: Text(
                        widget.name ?? '',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    if (widget.showEditDeleteButtons)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final soundDao = SoundDao();

                              bool isUse = await soundDao
                                  .checkSoundIsInForm(widget.soundId);
                              if (isUse) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Esse som não pode ser editado pois já foi adicionado em um formulário')),
                                );
                                return;
                              }

                              widget.currentPlaying!.value = '';
                              _audioPlayer.stop();
                              Navigator.pushNamed(context, '/createSound',
                                  arguments: {
                                    "idSound": widget.soundId,
                                    "notifier": widget.notifier
                                  });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: _deleteSound,
                          ),
                        ],
                      ),
                  ],
                ),
              if (widget.showPadding)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: widget.textController,
                    decoration: const InputDecoration(
                      labelText: 'Observações',
                      labelStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
