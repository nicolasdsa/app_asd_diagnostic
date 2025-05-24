import 'dart:async';
import 'package:flutter/material.dart';

class StageMenuWidget extends StatefulWidget {
  final String phaseText;
  final List<String> iconNames;
  final List<String> correctIcons;
  final String id;
  final bool immediateFeedback;
  final void Function(List<String> selected) onComplete;

  const StageMenuWidget({
    super.key,
    required this.phaseText,
    required this.iconNames,
    required this.correctIcons,
    required this.id,
    this.immediateFeedback = false,
    required this.onComplete,
  });

  @override
  _StageMenuWidgetState createState() => _StageMenuWidgetState();
}

class _StageMenuWidgetState extends State<StageMenuWidget> {
  final List<String> _selected = [];
  Timer? _hintTimer;
  String? _hintingIcon;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startHintTimer();
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 5), _showHint);
  }

  void _showHint() {
    final missing =
        widget.correctIcons.where((i) => !_selected.contains(i)).toList();
    if (missing.isNotEmpty) {
      setState(() => _hintingIcon = missing.first);
    }
    _startHintTimer();
  }

  void _onTapIcon(String name) {
    // 1) feedback imediato?
    if (widget.immediateFeedback && !widget.correctIcons.contains(name)) {
      setState(() {
        _errorMessage = 'Esse não é o item correto!';
      });
      return;
    }

    // 2) altera seleção
    setState(() {
      _errorMessage = null; // limpa qualquer erro anterior
      _hintingIcon = null; // reseta dica
      _startHintTimer(); // reinicia timer de dica

      if (_selected.contains(name)) {
        _selected.remove(name);
      } else {
        if (_selected.length == 3) {
          _selected.removeAt(0);
        }
        _selected.add(name);
      }
    });
  }

  void _onContinue() {
    final sel = _selected.toSet();
    final corr = widget.correctIcons.toSet();
    if (sel.length == 3 &&
        sel.difference(corr).isEmpty &&
        corr.difference(sel).isEmpty) {
      widget.onComplete(_selected);
    } else {
      setState(() {
        _errorMessage = 'Resposta incorreta. Tente novamente!';
      });
    }
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        _buildBackgroundGradient(),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.lightBlue, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Texto da fase
                      Text(widget.phaseText,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 16),

                      // Grid de ícones
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: widget.iconNames.map((name) {
                          final sel = _selected.contains(name);
                          final hint = name == _hintingIcon;
                          return GestureDetector(
                            onTap: () => _onTapIcon(name),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: sel
                                      ? Colors.green
                                      : hint
                                          ? Colors.orange
                                          : Colors.grey,
                                  width: sel ? 4 : 2,
                                ),
                                boxShadow: sel
                                    ? [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.5),
                                          blurRadius: 8,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Image.asset(
                                'assets/images/my_routine/icons/$name.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),
                      // Chips dos selecionados
                      Wrap(
                        spacing: 8,
                        children: _selected
                            .map((name) => Chip(label: Text(name)))
                            .toList(),
                      ),

                      const SizedBox(height: 8),
                      Text('Total: ${_selected.length} itens'),

                      // Mensagem de erro inline
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],

                      const SizedBox(height: 24),
                      // Botão continuar
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          backgroundColor: Colors.deepOrange,
                        ),
                        icon: const Icon(Icons.rocket_launch),
                        label: const Text('Continuar Aventura!'),
                        onPressed: _selected.length == 3 ? _onContinue : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildBackgroundGradient() {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // OKLCH(94.5% 0.129 101.54) → aprox. sRGB #FFF085
              Color(0xFFFFF085),
              // OKLCH(82.7% 0.119 306.383) → aprox. sRGB #DAB2FF
              Color(0xFFDAB2FF),
            ],
          ),
        ),
      ),
    );
  }
}
