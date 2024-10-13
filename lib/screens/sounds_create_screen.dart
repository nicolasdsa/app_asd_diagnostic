import 'package:app_asd_diagnostic/db/sound_dao.dart';
import 'package:app_asd_diagnostic/screens/components/my_app_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SoundCreateEditScreen extends StatefulWidget {
  final int? soundId; // Parâmetro opcional para edição
  final ValueNotifier<List<Map<String, dynamic>>>?
      notifier; // Notifier para atualizar a lista de sons

  const SoundCreateEditScreen({super.key, this.soundId, this.notifier});

  @override
  State<SoundCreateEditScreen> createState() => _SoundCreateEditScreenState();
}

class _SoundCreateEditScreenState extends State<SoundCreateEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _filePathController = TextEditingController();
  String? _selectedFilePath;
  bool _isEditing = false; // Flag para indicar se estamos editando ou criando

  @override
  void initState() {
    super.initState();

    if (widget.soundId != null) {
      _isEditing = true;
      _loadSoundData(widget.soundId!);
    }
  }

  Future<void> _loadSoundData(int soundId) async {
    final soundDao = SoundDao();
    final sound = await soundDao.getOne(soundId);
    if (sound != null) {
      _nameController.text = sound['name'];
      _filePathController.text = sound['filePath'];
    }
    setState(() {});
  }

  Future<void> _selectFile() async {
    String? filePath =
        await FilePicker.platform.pickFiles(type: FileType.audio).then((value) {
      if (value != null) {
        return value.files.single.path;
      } else {
        return null;
      }
    });

    if (filePath != null) {
      setState(() {
        _selectedFilePath = filePath;
        _filePathController.text = filePath;
      });
    }
  }

  Future<void> _saveSound() async {
    if (_formKey.currentState!.validate()) {
      final soundDao = SoundDao();

      if (_isEditing) {
        await soundDao.update(
            widget.soundId!, _nameController.text, _filePathController.text);

        if (widget.notifier != null) {
          var sounds = widget.notifier!.value;
          int index = sounds.indexWhere((s) => s['id'] == widget.soundId);
          if (index != -1) {
            sounds[index]['name'] = _nameController.text;
            sounds[index]['filePath'] = _filePathController.text;
            widget.notifier!.value = [...sounds];
          }
        }
      } else {
        int newSoundId = await soundDao.insert(
            _nameController.text, _filePathController.text);
        // Adicione o novo som ao notifier
        if (widget.notifier != null) {
          var sounds = widget.notifier!.value;
          sounds.add({
            'id': newSoundId,
            'name': _nameController.text,
            'filePath': _filePathController.text,
          });
          widget.notifier!.value = [...sounds];
        }
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _isEditing ? 'Editar Som' : 'Criar Som'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nome', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(fontSize: 12),
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22.0),
              Text(
                'Clique no campo abaixo para selecionar o arquivo de som',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _filePathController,
                decoration: const InputDecoration(
                  labelText: 'Caminho do arquivo',
                  labelStyle: TextStyle(fontSize: 12),
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                ),
                readOnly: true,
                onTap: _selectFile,
              ),
              const SizedBox(height: 22.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveSound,
                  icon: const Icon(Icons.save, color: Colors.white, size: 20),
                  label: Text(
                    _isEditing ? 'Atualizar Som' : 'Criar Som',
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
      ),
    );
  }
}
