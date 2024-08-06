import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/sound_dao.dart';
import 'package:app_asd_diagnostic/models/sound.dart';

class SoundComponent extends StatefulWidget {
  final int soundId;

  SoundComponent({required this.soundId});

  final TextEditingController textController = TextEditingController();

  @override
  _SoundComponentState createState() => _SoundComponentState();
}

class _SoundComponentState extends State<SoundComponent>
    with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Sound? soundData;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    widget.textController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (isPlaying) {
        _audioPlayer.stop();
        setState(() {
          isPlaying = false;
        });
      }
    }
  }

  void _togglePlay() {
    if (isPlaying) {
      _audioPlayer.stop();
    } else {
      _audioPlayer.play(UrlSource(soundData!.filePath));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (soundData != null)
          Row(
            children: [
              IconButton(
                icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                onPressed: _togglePlay,
              ),
              Text(soundData!.name),
            ],
          ),
        TextField(
          controller: widget.textController,
          decoration: InputDecoration(
            labelText: 'Observações',
          ),
        ),
      ],
    );
  }
}
