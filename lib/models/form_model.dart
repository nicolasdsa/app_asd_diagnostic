class FormModel {
  int id;
  String name;

  FormModel({required this.name, this.id = 0});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  static FormModel fromMap(Map<String, dynamic> map) {
    return FormModel(
      id: map['id'],
      name: map['name'],
    );
  }
}
