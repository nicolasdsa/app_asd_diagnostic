import 'package:app_asd_diagnostic/db/sound_dao.dart';
import 'package:app_asd_diagnostic/screens/components/my_app_bar.dart';
import 'package:app_asd_diagnostic/screens/components/sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({Key? key}) : super(key: key);

  @override
  SoundsScreenState createState() => SoundsScreenState();
}

class SoundsScreenState extends State<SoundsScreen>
    with WidgetsBindingObserver {
  final SoundDao _soundDao = SoundDao();
  final ValueNotifier<List<Map<String, dynamic>>> _soundsNotifier =
      ValueNotifier([]);
  final ValueNotifier<String> _currentSoundNotifier = ValueNotifier('');
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSounds();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _loadSounds() async {
    List<Map<String, dynamic>> soundsAll = await _soundDao.index();
    _soundsNotifier.value = soundsAll;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Meus Sons'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _currentSoundNotifier,
                builder: (context, currentSound, child) {
                  return ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: _soundsNotifier,
                    builder: (context, value, child) {
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return SoundComponent(
                            soundId: value[index]['id'],
                            name: value[index]['name'],
                            showPadding: false,
                            showEditDeleteButtons: true,
                            notifier: _soundsNotifier,
                            audioPlayer: _audioPlayer,
                            currentPlaying: _currentSoundNotifier,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _currentSoundNotifier.value =
                      ''; // Define o som atual como vazio
                  _audioPlayer.stop(); // Para o áudio atual
                  Navigator.pushNamed(context, '/createSound', arguments: {
                    'notifier': _soundsNotifier,
                  });
                },
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _currentSoundNotifier.value = '';
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _soundsNotifier.dispose();
    _currentSoundNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _audioPlayer.stop();
      _currentSoundNotifier.value = '';
    }
  }
}
