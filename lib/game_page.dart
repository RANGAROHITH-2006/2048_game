import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_state.dart';
import 'game_logic.dart';
import 'tile_widget.dart';
import 'help_diolog.dart';

/// Main game page with UI and input handling
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameState _gameState;
  final FocusNode _focusNode = FocusNode();
  bool _hasShownGameOverDialog = false;
  bool _hasShownWinDialog = false;

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
    
    // Listen to game state changes
    _gameState.addListener(_onGameStateChanged);
    
    // Request focus for keyboard input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }
  
  /// Handle game state changes
  void _onGameStateChanged() {
    // Check for win condition
    if (_gameState.won && !_hasShownWinDialog) {
      _hasShownWinDialog = true;
      print('DEBUG: Win condition detected, showing win dialog');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showWinDialog();
        }
      });
    }
    
    // Check for game over condition
    if (_gameState.gameOver && !_hasShownGameOverDialog) {
      _hasShownGameOverDialog = true;
      print('DEBUG: Game over detected, showing game over dialog');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showGameOverDialog();
        }
      });
    }
  }

  @override
  void dispose() {
    _gameState.removeListener(_onGameStateChanged);
    _focusNode.dispose();
    _gameState.dispose();
    super.dispose();
  }

  /// Handle keyboard arrow key events
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          _gameState.move(MoveDirection.left);
          break;
        case LogicalKeyboardKey.arrowRight:
          _gameState.move(MoveDirection.right);
          break;
        case LogicalKeyboardKey.arrowUp:
          _gameState.move(MoveDirection.up);
          break;
        case LogicalKeyboardKey.arrowDown:
          _gameState.move(MoveDirection.down);
          break;
      }
    }
  }

  // Track swipe start and end positions
  Offset? _swipeStart;
  Offset? _swipeEnd;

  /// Handle swipe start
  void _handleSwipeStart(DragStartDetails details) {
    _swipeStart = details.localPosition;
    _swipeEnd = details.localPosition;
  }

  /// Track swipe position updates
  void _handleSwipeUpdate(DragUpdateDetails details) {
    _swipeEnd = details.localPosition;
  }

  /// Handle swipe gestures using actual drag distance
  void _handleSwipeEnd(DragEndDetails details) {
    if (_swipeStart == null || _swipeEnd == null) return;

    final double dx = _swipeEnd!.dx - _swipeStart!.dx;
    final double dy = _swipeEnd!.dy - _swipeStart!.dy;
    final double threshold = 20.0; // Minimum swipe distance in pixels

    print('DEBUG: Swipe distance - dx: $dx, dy: $dy');

    // Determine swipe direction based on the larger delta
    if (dx.abs() > dy.abs() && dx.abs() > threshold) {
      // Horizontal swipe
      if (dx > 0) {
        print('DEBUG: Swiping RIGHT');
        _gameState.move(MoveDirection.right);
      } else {
        print('DEBUG: Swiping LEFT');
        _gameState.move(MoveDirection.left);
      }
    } else if (dy.abs() > dx.abs() && dy.abs() > threshold) {
      // Vertical swipe
      if (dy > 0) {
        print('DEBUG: Swiping DOWN');
        _gameState.move(MoveDirection.down);
      } else {
        print('DEBUG: Swiping UP');
        _gameState.move(MoveDirection.up);
      }
    }

    _swipeStart = null;
    _swipeEnd = null;
  }

  /// Show game over dialog
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2), width: 2),
        ),
        title: const Text(
          'Game Over!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No more moves available!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Final Score: ${_gameState.score}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _gameState.resetGame();
                _hasShownGameOverDialog = false;
              });
              _focusNode.requestFocus();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// Show win dialog
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2), width: 2),
        ),
        title: const Text(
          '🎉 You Win! 🎉',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You reached 2048!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Score: ${_gameState.score}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _gameState.continueAfterWin();
                _hasShownWinDialog = false;
              });
              _focusNode.requestFocus();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _gameState.resetGame();
                _hasShownWinDialog = false;
                _hasShownGameOverDialog = false;
              });
              _focusNode.requestFocus();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'New Game',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onPanStart: _handleSwipeStart,
        onPanUpdate: _handleSwipeUpdate,
        onPanEnd: _handleSwipeEnd,
        child: Scaffold(
          body: Stack(
            children: [
              // Background with geometric pattern
              _buildBackground(),
              // Game content
              SafeArea(
                child: Column(
                  children: [
                    // Top section with pause, level, and help
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Pause button
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.home,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                child: Image.asset(
                                  'assets/images/add.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Help icon
                              GestureDetector(
                                onTap: () {
                                  showHelpDialog(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.asset(
                                    'assets/images/help.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Game content
                    Expanded(
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Title and score header
                              _buildHeader(),
                        const SizedBox(height: 60),
                        // Game board
                        _buildGameBoard(),
                        const SizedBox(height: 30),
                        // Action buttons
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the decorative background
  Widget _buildBackground() {
    return 
    Image.asset(
        'assets/images/background.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
  }

  /// Build the header with title, score, and new game button
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title
        const Text(
          '2048',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        // Score and High Score
        Row(
          children: [
            // Score display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2d3748),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4a5568),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'SCORE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9ca3af),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  ListenableBuilder(
                    listenable: _gameState,
                    builder: (context, child) {
                      return Text(
                        '${_gameState.score}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // High Score display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2d3748),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4a5568),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'HIGH SCORE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9ca3af),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  ListenableBuilder(
                    listenable: _gameState,
                    builder: (context, child) {
                      return Text(
                        '${_gameState.highScore}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build the 4x4 game board
  Widget _buildGameBoard() {
    return ListenableBuilder(
      listenable: _gameState,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Column(
            children: List.generate(4, (row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (col) {
                    final value = _gameState.getTileValue(row, col);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: TileWidget(
                        value: value,
                        size: 65.0,
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  /// Build action buttons (undo/redo)
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircularButton(
          icon: Icons.refresh,
          onPressed: () {
            setState(() {
              _gameState.resetGame();
              _hasShownGameOverDialog = false;
              _hasShownWinDialog = false;
            });
            _focusNode.requestFocus();
          },
        ),
        const SizedBox(width: 20),
        ListenableBuilder(
          listenable: _gameState,
          builder: (context, child) {
            return _buildCircularButton(
              icon: Icons.undo,
              onPressed: _gameState.canUndo
                  ? () {
                      setState(() {
                        _gameState.undo();
                        _hasShownGameOverDialog = false;
                        _hasShownWinDialog = false;
                      });
                      _focusNode.requestFocus();
                    }
                  : null,
            );
          },
        ),
      ],
    );
  }

  /// Build circular button
  Widget _buildCircularButton({required IconData icon, required VoidCallback? onPressed}) {
    final isEnabled = onPressed != null;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isEnabled ? const Color(0xFF2d3748) : const Color(0xFF2d3748).withOpacity(0.5),
        border: Border.all(
          color: isEnabled ? const Color(0xFF4a5568) : const Color(0xFF4a5568).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              icon,
              color: isEnabled ? Colors.white : Colors.white.withOpacity(0.4),
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
