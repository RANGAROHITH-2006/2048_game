import 'dart:math';

/// Core game logic for 2048
/// Handles all tile movements, merging, and board manipulations
class GameLogic {
  static final Random _random = Random();

  /// Compress the row by removing zeros (moving all tiles to the left)
  static List<int> _compress(List<int> row) {
    List<int> newRow = row.where((val) => val != 0).toList();
    while (newRow.length < 4) {
      newRow.add(0);
    }
    return newRow;
  }

  /// Merge adjacent identical tiles in a row
  /// Returns the merged row and the score gained from merging
  static Map<String, dynamic> _merge(List<int> row) {
    // Create a copy to avoid mutations
    List<int> newRow = List<int>.from(row);
    int score = 0;
    for (int i = 0; i < newRow.length - 1; i++) {
      if (newRow[i] != 0 && newRow[i] == newRow[i + 1]) {
        newRow[i] = newRow[i] * 2;
        newRow[i + 1] = 0;
        score += newRow[i];
        // Skip the next tile to prevent double merging
        i++;
      }
    }
    return {'row': newRow, 'score': score};
  }

  /// Process a single row: compress, merge, compress again
  static Map<String, dynamic> _processRow(List<int> row) {
    // Step 1: Compress to remove gaps
    List<int> compressed = _compress(row);
    
    // Step 2: Merge identical adjacent tiles
    Map<String, dynamic> mergeResult = _merge(compressed);
    List<int> merged = mergeResult['row'];
    int score = mergeResult['score'];
    
    // Step 3: Compress again to remove new gaps created by merging
    List<int> finalRow = _compress(merged);
    
    return {'row': finalRow, 'score': score};
  }

  /// Move and merge tiles to the left
  static Map<String, dynamic> moveLeft(List<List<int>> board) {
    // Create a deep copy of the board
    List<List<int>> newBoard = board.map((row) => List<int>.from(row)).toList();
    int totalScore = 0;

    List<List<int>> result = [];
    for (var row in newBoard) {
      Map<String, dynamic> rowResult = _processRow(row);
      result.add(rowResult['row']);
      totalScore += rowResult['score'] as int;
    }

    return {'board': result, 'score': totalScore};
  }

  /// Move and merge tiles to the right
  static Map<String, dynamic> moveRight(List<List<int>> board) {
    // Create a deep copy of the board
    List<List<int>> newBoard = board.map((row) => List<int>.from(row)).toList();
    int totalScore = 0;

    List<List<int>> result = [];
    for (var row in newBoard) {
      // Reverse the row, process it, then reverse back
      List<int> reversedRow = row.reversed.toList();
      Map<String, dynamic> rowResult = _processRow(reversedRow);
      List<int> processedRow = (rowResult['row'] as List<int>).reversed.toList();
      result.add(processedRow);
      totalScore += rowResult['score'] as int;
    }

    return {'board': result, 'score': totalScore};
  }

  /// Transpose the board (swap rows and columns)
  static List<List<int>> _transpose(List<List<int>> board) {
    List<List<int>> transposed = List.generate(4, (_) => List.filled(4, 0));
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        transposed[j][i] = board[i][j];
      }
    }
    return transposed;
  }

  /// Move and merge tiles upward
  static Map<String, dynamic> moveUp(List<List<int>> board) {
    // Transpose, move left, transpose back
    List<List<int>> transposed = _transpose(board);
    Map<String, dynamic> result = moveLeft(transposed);
    List<List<int>> newBoard = _transpose(result['board']);
    
    return {'board': newBoard, 'score': result['score']};
  }

  /// Move and merge tiles downward
  static Map<String, dynamic> moveDown(List<List<int>> board) {
    // Transpose, move right, transpose back
    List<List<int>> transposed = _transpose(board);
    Map<String, dynamic> result = moveRight(transposed);
    List<List<int>> newBoard = _transpose(result['board']);
    
    return {'board': newBoard, 'score': result['score']};
  }

  /// Check if two boards are equal
  static bool _boardsEqual(List<List<int>> board1, List<List<int>> board2) {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (board1[i][j] != board2[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  /// Get all empty cell positions
  static List<List<int>> _getEmptyCells(List<List<int>> board) {
    List<List<int>> emptyCells = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (board[i][j] == 0) {
          emptyCells.add([i, j]);
        }
      }
    }
    return emptyCells;
  }

  /// Add a random tile (2 or 4) to an empty position
  /// 90% chance of 2, 10% chance of 4
  static List<List<int>> addRandomTile(List<List<int>> board) {
    List<List<int>> newBoard = board.map((row) => List<int>.from(row)).toList();
    List<List<int>> emptyCells = _getEmptyCells(newBoard);

    if (emptyCells.isEmpty) {
      return newBoard;
    }

    // Pick a random empty cell
    List<int> cell = emptyCells[_random.nextInt(emptyCells.length)];
    
    // 90% chance of 2, 10% chance of 4
    int value = _random.nextDouble() < 0.9 ? 2 : 4;
    newBoard[cell[0]][cell[1]] = value;

    return newBoard;
  }

  /// Check if any moves are possible
  static bool canMove(List<List<int>> board) {
    // Check if there are any empty cells
    if (_getEmptyCells(board).isNotEmpty) {
      return true;
    }

    // Check if any adjacent tiles can merge horizontally
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == board[i][j + 1]) {
          return true;
        }
      }
    }

    // Check if any adjacent tiles can merge vertically
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 4; j++) {
        if (board[i][j] == board[i + 1][j]) {
          return true;
        }
      }
    }

    return false;
  }

  /// Execute a move in the specified direction
  /// Returns null if the move doesn't change the board
  static Map<String, dynamic>? executeMove(
    List<List<int>> board,
    MoveDirection direction,
  ) {
    Map<String, dynamic> result;

    switch (direction) {
      case MoveDirection.left:
        result = moveLeft(board);
        break;
      case MoveDirection.right:
        result = moveRight(board);
        break;
      case MoveDirection.up:
        result = moveUp(board);
        break;
      case MoveDirection.down:
        result = moveDown(board);
        break;
    }

    // Check if the board actually changed
    if (_boardsEqual(board, result['board'])) {
      return null; // No change, invalid move
    }

    return result;
  }

  /// Initialize a new board with two random tiles
  static List<List<int>> initializeBoard() {
    List<List<int>> board = List.generate(4, (_) => List.filled(4, 0));
    board = addRandomTile(board);
    board = addRandomTile(board);
    return board;
  }
}

/// Enum for move directions
enum MoveDirection {
  left,
  right,
  up,
  down,
}
