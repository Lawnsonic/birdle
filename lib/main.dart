import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Birdle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

/// A single letter tile in the guess grid.
class Tile extends StatelessWidget {
  const Tile(this.letter, this.hitType, {super.key, this.isActive = false});

  final String letter;
  final HitType hitType;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNone = hitType == HitType.none;

    final borderColor = isNone
        ? (isActive ? theme.colorScheme.primary : Colors.grey.shade400)
        : Colors.transparent;

    final backgroundColor = switch (hitType) {
      HitType.hit => const Color(0xFF538D4E),
      HitType.partial => const Color(0xFFB59F3B),
      HitType.miss => const Color(0xFF6B7280),
      HitType.none => Colors.white,
    };

    final textColor = isNone ? Colors.black87 : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: isActive ? 2.2 : 1.5),
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// The main game page: grid of guesses, on-screen keyboard, and controls.
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Game _game;
  String _currentInput = '';
  String? _message;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _keyboardFocusNode = FocusNode();
  final FocusNode _inputFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _game = Game();
  }

  @override
  void dispose() {
    _textController.dispose();
    _keyboardFocusNode.dispose();
    _inputFieldFocusNode.dispose();
    super.dispose();
  }

  void _syncInput(String value) {
    _currentInput = value.toLowerCase();
    if (_textController.text != _currentInput) {
      _textController.text = _currentInput;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _currentInput.length),
      );
    }
  }

  void _handleKeyPress(String key) {
    if (_game.didWin || _game.didLose) return;
    if (_currentInput.length >= 5) return;

    setState(() {
      _currentInput += key.toLowerCase();
      _syncInput(_currentInput);
      _message = null;
    });
  }

  void _handleBackspace() {
    if (_game.didWin || _game.didLose) return;
    if (_currentInput.isNotEmpty) {
      setState(() {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        _syncInput(_currentInput);
        _message = null;
      });
    }
  }

  void _handleGuess([String? text]) {
    if (_game.didWin || _game.didLose) return;

    final guess = (text ?? _currentInput).trim().toLowerCase();

    if (guess.length != 5) {
      setState(() => _message = 'Enter a 5-letter word.');
      return;
    }

    if (!_game.isLegalGuess(guess)) {
      setState(() => _message = 'Not in word list.');
      return;
    }

    setState(() {
      _game.guess(guess);
      _currentInput = '';
      _syncInput('');
      _message = null;
    });

    if (_game.didWin) {
      _showEndDialog(
        'You won! 🎉',
        'Splendid! You guessed "${_game.hiddenWord}" in ${_game.guesses.where((w) => w.isNotEmpty).length} tries.',
      );
    } else if (_game.didLose) {
      _showEndDialog(
        'Game over',
        'The bird was "${_game.hiddenWord}". Better luck next round!',
      );
    }
  }

  void _resetGame() {
    setState(() {
      _game.resetGame();
      _currentInput = '';
      _syncInput('');
      _message = null;
    });
  }

  Map<String, HitType> get _keyHits {
    final map = <String, HitType>{};
    for (final word in _game.guesses) {
      if (word.isEmpty) continue;
      for (final letter in word) {
        final current = map[letter.char];
        if (letter.type == HitType.hit) {
          map[letter.char] = HitType.hit;
        } else if (letter.type == HitType.partial && current != HitType.hit) {
          map[letter.char] = HitType.partial;
        } else if (letter.type == HitType.miss && current == null) {
          map[letter.char] = HitType.miss;
        }
      }
    }
    return map;
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.flutter_dash, color: Color(0xFF0D9488)),
            SizedBox(width: 8),
            Text('How to Play Birdle'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Guess the 5-letter word in 6 attempts.\n'),
            Text('Each guess must be a valid 5-letter word.'),
            Text('Tile colors show how close your guess was:\n'),
            Row(
              children: [
                Icon(Icons.square, color: Color(0xFF538D4E), size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Green: Correct letter & position.')),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.square, color: Color(0xFFB59F3B), size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Yellow: In word, wrong position.')),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.square, color: Color(0xFF6B7280), size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Grey: Letter is not in word.')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Play'),
          ),
        ],
      ),
    );
  }

  void _showEndDialog(String title, String body) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('Play again'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGameOver = _game.didWin || _game.didLose;
    final activeRowIndex = _game.activeIndex;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flutter_dash, color: Color(0xFF0D9488)),
            SizedBox(width: 8),
            Text('Birdle', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'How to play',
            onPressed: _showHelpDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'New game',
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Focus(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (isGameOver) return KeyEventResult.ignored;
          if (_inputFieldFocusNode.hasFocus) return KeyEventResult.ignored;

          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              _handleGuess();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
              _handleBackspace();
              return KeyEventResult.handled;
            } else {
              final char = event.character?.toLowerCase();
              if (char != null && RegExp(r'^[a-z]$').hasMatch(char)) {
                _handleKeyPress(char);
                return KeyEventResult.handled;
              }
            }
          }
          return KeyEventResult.ignored;
        },
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 5x6 Tile Grid
                    for (var row = 0; row < _game.maxGuesses; row++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var col = 0; col < 5; col++) ...[
                              if (col > 0) const SizedBox(width: 6),
                              _buildTileFor(row, col, activeRowIndex),
                            ],
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Status / Warning message banner
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 28,
                      alignment: Alignment.center,
                      child: _message != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _message!,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(height: 8),

                    // Interactive on-screen keyboard
                    Keyboard(
                      onKeyPressed: _handleKeyPress,
                      onEnterPressed: () => _handleGuess(),
                      onBackspacePressed: _handleBackspace,
                      keyHits: _keyHits,
                      disabled: isGameOver,
                    ),

                    const SizedBox(height: 8),

                    // Optional synchronized input bar
                    GuessInput(
                      controller: _textController,
                      focusNode: _inputFieldFocusNode,
                      onChanged: (val) {
                        setState(() {
                          _currentInput = val.toLowerCase();
                          _message = null;
                        });
                      },
                      onSubmitGuess: () => _handleGuess(),
                      disabled: isGameOver,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTileFor(int row, int col, int activeRowIndex) {
    if (activeRowIndex != -1 && row == activeRowIndex) {
      final char = col < _currentInput.length ? _currentInput[col] : '';
      return Tile(char, HitType.none, isActive: char.isNotEmpty);
    } else if (activeRowIndex != -1 && row < activeRowIndex ||
        activeRowIndex == -1 &&
            row < _game.guesses.length &&
            _game.guesses[row].isNotEmpty) {
      final letter = _game.guesses[row][col];
      return Tile(letter.char, letter.type);
    } else {
      return const Tile('', HitType.none);
    }
  }
}

/// On-screen keyboard with hit-state colors, Enter, and Backspace keys.
class Keyboard extends StatelessWidget {
  const Keyboard({
    super.key,
    required this.onKeyPressed,
    required this.onEnterPressed,
    required this.onBackspacePressed,
    required this.keyHits,
    required this.disabled,
  });

  final void Function(String) onKeyPressed;
  final VoidCallback onEnterPressed;
  final VoidCallback onBackspacePressed;
  final Map<String, HitType> keyHits;
  final bool disabled;

  static const List<String> _row1 = [
    'q',
    'w',
    'e',
    'r',
    't',
    'y',
    'u',
    'i',
    'o',
    'p',
  ];
  static const List<String> _row2 = [
    'a',
    's',
    'd',
    'f',
    'g',
    'h',
    'j',
    'k',
    'l',
  ];
  static const List<String> _row3 = ['z', 'x', 'c', 'v', 'b', 'n', 'm'];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final char in _row1)
              _KeyButton(
                char: char,
                hitType: keyHits[char],
                onPressed: disabled ? null : () => onKeyPressed(char),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final char in _row2)
              _KeyButton(
                char: char,
                hitType: keyHits[char],
                onPressed: disabled ? null : () => onKeyPressed(char),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SpecialKeyButton(
              label: 'ENTER',
              width: 54,
              onPressed: disabled ? null : onEnterPressed,
            ),
            for (final char in _row3)
              _KeyButton(
                char: char,
                hitType: keyHits[char],
                onPressed: disabled ? null : () => onKeyPressed(char),
              ),
            _SpecialKeyButton(
              icon: Icons.backspace_outlined,
              width: 44,
              onPressed: disabled ? null : onBackspacePressed,
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.char, this.hitType, this.onPressed});

  final String char;
  final HitType? hitType;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = switch (hitType) {
      HitType.hit => (const Color(0xFF538D4E), Colors.white),
      HitType.partial => (const Color(0xFFB59F3B), Colors.white),
      HitType.miss => (const Color(0xFF6B7280), Colors.white),
      null || HitType.none => (Colors.grey.shade300, Colors.black87),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: onPressed,
          child: SizedBox(
            width: 32,
            height: 46,
            child: Center(
              child: Text(
                char.toUpperCase(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecialKeyButton extends StatelessWidget {
  const _SpecialKeyButton({
    this.label,
    this.icon,
    required this.width,
    this.onPressed,
  });

  final String? label;
  final IconData? icon;
  final double width;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Material(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: onPressed,
          child: SizedBox(
            width: width,
            height: 46,
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 19, color: Colors.black87)
                  : Text(
                      label!,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Text field for entering guesses (synchronized with on-screen keyboard).
class GuessInput extends StatelessWidget {
  const GuessInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitGuess,
    this.disabled = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitGuess;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLength: 5,
                enabled: !disabled,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Type or tap keyboard...',
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onChanged: onChanged,
                onSubmitted: (_) => onSubmitGuess(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.arrow_upward),
              onPressed: disabled ? null : onSubmitGuess,
              tooltip: 'Submit guess',
            ),
          ],
        ),
      ),
    );
  }
}
