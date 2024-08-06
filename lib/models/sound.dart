// sound.dart
class Sound {
  final int? id;
  final String name;
  final String filePath;

  Sound({this.id, required this.name, required this.filePath});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'filePath': filePath,
    };
  }

  factory Sound.fromMap(Map<String, dynamic> map) {
    return Sound(
      id: map['id'],
      name: map['name'],
      filePath: map['filePath'],
    );
  }
}
