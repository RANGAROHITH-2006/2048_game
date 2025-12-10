import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'game_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the game state including board, score, and game status
class GameState extends ChangeNotifier {
  List<List<int>> _board = [];
  int _score = 0;
  int _highScore = 0;
  bool _gameOver = false;
  bool _won = false;
  bool _hasShownWinDialog = false; // Track if win dialog has been shown

  // Undo functionality - store only one previous state
  List<List<int>>? _previousBoard;
  int? _previousScore;
  bool _canUndo = false;

  GameState() {
    _initializeGame();
    _loadHighScore();
  }

  /// Getters
  List<List<int>> get board => _board;
  int get score => _score;
  int get highScore => _highScore;
  bool get gameOver => _gameOver;
  bool get won => _won;
  bool get canUndo => _canUndo;

  /// Load high score from local storage
  Future<void> _loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _highScore = prefs.getInt('highScore') ?? 0;
      notifyListeners();
    } catch (e) {
      print('Error loading high score: $e');
    }
  }

  /// Save high score to local storage
  Future<void> _saveHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', _highScore);
    } catch (e) {
      print('Error saving high score: $e');
    }
  }

  /// Save current game state to local storage
  Future<void> saveGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Only save if game is in progress (not finished)
      if (!_gameOver && !_won) {
        await prefs.setString('savedBoard', jsonEncode(_board));
        await prefs.setInt('savedScore', _score);
        await prefs.setBool('gameInProgress', true);
      } else {
        // Clear saved game if game is finished
        await clearSavedGame();
      }
    } catch (e) {
      print('Error saving game state: $e');
    }
  }

  /// Load saved game state from local storage
  Future<bool> loadGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gameInProgress = prefs.getBool('gameInProgress') ?? false;

      if (!gameInProgress) {
        return false;
      }

      final savedBoardJson = prefs.getString('savedBoard');
      final savedScore = prefs.getInt('savedScore');

      if (savedBoardJson != null && savedScore != null) {
        final decoded = jsonDecode(savedBoardJson) as List;
        _board = decoded.map((row) => List<int>.from(row)).toList();
        _score = savedScore;
        _gameOver = false;
        _won = false;
        _hasShownWinDialog = false;
        _previousBoard = null;
        _previousScore = null;
        _canUndo = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error loading game state: $e');
      return false;
    }
  }

  /// Clear saved game from local storage
  Future<void> clearSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('savedBoard');
      await prefs.remove('savedScore');
      await prefs.setBool('gameInProgress', false);
    } catch (e) {
      print('Error clearing saved game: $e');
    }
  }

  /// Initialize a new game
  void _initializeGame() {
    _board = GameLogic.initializeBoard();
    _score = 0;
    _gameOver = false;
    _won = false;
    _hasShownWinDialog = false;
    _previousBoard = null;
    _previousScore = null;
    _canUndo = false;
    notifyListeners();
  }

  /// Reset the game
  void resetGame() {
    _initializeGame();
    clearSavedGame();
  }

  /// Undo the last move (only one step)
  void undo() {
    if (_canUndo && _previousBoard != null && _previousScore != null) {
      _board = _previousBoard!;
      _score = _previousScore!;
      _gameOver = false;
      _won = false;
      _hasShownWinDialog = false;
      _previousBoard = null;
      _previousScore = null;
      _canUndo = false;
      notifyListeners();
    }
  }

  /// Execute a move in the specified direction
  void move(MoveDirection direction) {
    if (_gameOver) return;

    // Execute the move
    Map<String, dynamic>? result = GameLogic.executeMove(_board, direction);

    // If the move didn't change the board, do nothing
    if (result == null) {
      return;
    }

    // Save current state for undo (only one step)
    _previousBoard = _board.map((row) => List<int>.from(row)).toList();
    _previousScore = _score;
    _canUndo = true;

    // Update the board and score
    _board = result['board'];
    _score += result['score'] as int;

    // Update high score if needed
    if (_score > _highScore) {
      _highScore = _score;
      _saveHighScore();
    }

    // Add a new random tile
    _board = GameLogic.addRandomTile(_board);

    // Check for win condition (2048 tile)
    if (!_hasShownWinDialog && _hasWinningTile()) {
      _won = true;
      _hasShownWinDialog = true;
    }

    // Check if the game is over
    bool canStillMove = GameLogic.canMove(_board);
    if (!canStillMove) {
      _gameOver = true;
    }

    // Save game state after every move
    saveGameState();

    notifyListeners();
  }

  /// Check if there's a 2048 tile on the board
  bool _hasWinningTile() {
    for (var row in _board) {
      if (row.contains(2048)) {
        return true;
      }
    }
    return false;
  }

  /// Continue playing after winning
  void continueAfterWin() {
    _won = false;
    notifyListeners();
  }

  /// Get the value at a specific position
  int getTileValue(int row, int col) {
    if (row < 0 || row >= 4 || col < 0 || col >= 4) {
      return 0;
    }
    return _board[row][col];
  }
}
