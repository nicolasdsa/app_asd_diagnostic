// lib/games/my_routine/components/objective_manager.dart

import 'package:flame/components.dart';

class ObjectiveManager extends Component {
  /// chave = id do stage (por exemplo: nome do TMX ou phrase única)
  final Map<String, bool> _completed = {};

  /// Registra um novo objetivo (chave)
  void registerObjective(String id) {
    _completed.putIfAbsent(id, () => false);
  }

  /// Marca como concluído
  void complete(String id) {
    if (_completed.containsKey(id)) {
      _completed[id] = true;
    }
  }

  /// Verifica status
  bool isComplete(String id) => _completed[id] ?? false;

  /// Retorna lista de pares (id, concluído)
  List<MapEntry<String, bool>> get all =>
      _completed.entries.toList(growable: false);
}
