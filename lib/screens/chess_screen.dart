// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/bottom_nav_bar.dart';

class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key});

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  List<List<String>> board = [];
  int? selectedRow;
  int? selectedCol;
  bool isWhiteTurn = true;
  bool isThinking = false;
  String gameStatus = "Your turn (White)";
  List<String> moveHistory = [];
  List<List<int>> validMoves = [];
  bool isLoadingHint = false;
  String? hintMove;

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }

  void initializeBoard() {
    board = [
      ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'],
      ['p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'],
      ['R', 'N', 'B', 'Q', 'K', 'B', 'N', 'R'],
    ];
  }

  String getPieceImage(String piece) {
    if (piece.isEmpty) return '';
    
    const Map<String, String> pieceImages = {
      'K': 'assets/images/chess/white_king.png',
      'Q': 'assets/images/chess/white_queen.png',
      'R': 'assets/images/chess/white_rook.png',
      'B': 'assets/images/chess/white_bishop.png',
      'N': 'assets/images/chess/white_knight.png',
      'P': 'assets/images/chess/white_pawn.png',
      'k': 'assets/images/chess/black_king.png',
      'q': 'assets/images/chess/black_queen.png',
      'r': 'assets/images/chess/black_rook.png',
      'b': 'assets/images/chess/black_bishop.png',
      'n': 'assets/images/chess/black_knight.png',
      'p': 'assets/images/chess/black_pawn.png',
    };
    
    return pieceImages[piece] ?? '';
  }

  void calculateValidMoves(int row, int col) {
    validMoves.clear();
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (isValidMove(row, col, i, j)) {
          validMoves.add([i, j]);
        }
      }
    }
  }

  bool isValidMove(int fromRow, int fromCol, int toRow, int toCol) {
    if (toRow < 0 || toRow > 7 || toCol < 0 || toCol > 7) return false;

    String piece = board[fromRow][fromCol];
    String target = board[toRow][toCol];

    if (target.isNotEmpty) {
      if (piece.toUpperCase() == piece && target.toUpperCase() == target) return false;
      if (piece.toLowerCase() == piece && target.toLowerCase() == target) return false;
    }

    if (piece.toLowerCase() == 'p') {
      int direction = piece == 'P' ? -1 : 1;
      int startRow = piece == 'P' ? 6 : 1;

      if (fromCol == toCol && target.isEmpty) {
        if (toRow == fromRow + direction) return true;
        if (fromRow == startRow &&
            toRow == fromRow + 2 * direction &&
            board[fromRow + direction][fromCol].isEmpty) {
          return true;
        }
      }

      if ((toCol == fromCol + 1 || toCol == fromCol - 1) &&
          toRow == fromRow + direction &&
          target.isNotEmpty) {
        return true;
      }
    }

    if (piece.toLowerCase() == 'r') {
      if (fromRow == toRow || fromCol == toCol) {
        return isPathClear(fromRow, fromCol, toRow, toCol);
      }
    }

    if (piece.toLowerCase() == 'n') {
      int rowDiff = (toRow - fromRow).abs();
      int colDiff = (toCol - fromCol).abs();
      return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2);
    }

    if (piece.toLowerCase() == 'b') {
      if ((toRow - fromRow).abs() == (toCol - fromCol).abs()) {
        return isPathClear(fromRow, fromCol, toRow, toCol);
      }
    }

    if (piece.toLowerCase() == 'q') {
      if (fromRow == toRow ||
          fromCol == toCol ||
          (toRow - fromRow).abs() == (toCol - fromCol).abs()) {
        return isPathClear(fromRow, fromCol, toRow, toCol);
      }
    }

    if (piece.toLowerCase() == 'k') {
      return (toRow - fromRow).abs() <= 1 && (toCol - fromCol).abs() <= 1;
    }

    return false;
  }

  bool isPathClear(int fromRow, int fromCol, int toRow, int toCol) {
    int rowDir = toRow > fromRow ? 1 : (toRow < fromRow ? -1 : 0);
    int colDir = toCol > fromCol ? 1 : (toCol < fromCol ? -1 : 0);

    int currentRow = fromRow + rowDir;
    int currentCol = fromCol + colDir;

    while (currentRow != toRow || currentCol != toCol) {
      if (board[currentRow][currentCol].isNotEmpty) return false;
      currentRow += rowDir;
      currentCol += colDir;
    }

    return true;
  }

  void makeMove(int fromRow, int fromCol, int toRow, int toCol) {
    setState(() {
      String piece = board[fromRow][fromCol];
      board[toRow][toCol] = piece;
      board[fromRow][fromCol] = '';

      String move =
          '${String.fromCharCode(97 + fromCol)}${8 - fromRow}${String.fromCharCode(97 + toCol)}${8 - toRow}';
      moveHistory.add(move);

      isWhiteTurn = !isWhiteTurn;
      selectedRow = null;
      selectedCol = null;
      validMoves.clear();

      if (!isWhiteTurn) {
        gameStatus = "Computer is thinking...";
        getComputerMove();
      } else {
        gameStatus = "Your turn (White)";
      }
    });
  }

  Future<void> getComputerMove() async {
    setState(() => isThinking = true);
    try {
      String fen = boardToFen();
      final response = await http.get(
        Uri.parse(
            'https://stockfish.online/api/s/v2.php?fen=$fen&depth=10'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String bestMove = data['bestmove']?.split(' ')[1] ?? '';

        if (bestMove.length >= 4) {
          int fromCol = bestMove.codeUnitAt(0) - 97;
          int fromRow = 8 - int.parse(bestMove[1]);
          int toCol = bestMove.codeUnitAt(2) - 97;
          int toRow = 8 - int.parse(bestMove[3]);

          await Future.delayed(const Duration(milliseconds: 500));

          setState(() {
            board[toRow][toCol] = board[fromRow][fromCol];
            board[fromRow][fromCol] = '';
            moveHistory.add(bestMove);
            isWhiteTurn = true;
            gameStatus = "Your turn (White)";
            isThinking = false;
          });
        }
      }
    } catch (e) {
      makeRandomMove();
    }
  }

  void makeRandomMove() {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        String piece = board[i][j];
        if (piece.isNotEmpty && piece.toLowerCase() == piece) {
          for (int ti = 0; ti < 8; ti++) {
            for (int tj = 0; tj < 8; tj++) {
              if (isValidMove(i, j, ti, tj)) {
                setState(() {
                  board[ti][tj] = board[i][j];
                  board[i][j] = '';
                  isWhiteTurn = true;
                  gameStatus = "Your turn (White)";
                  isThinking = false;
                });
                return;
              }
            }
          }
        }
      }
    }
  }

  String boardToFen() {
    String fen = '';
    for (int i = 0; i < 8; i++) {
      int empty = 0;
      for (int j = 0; j < 8; j++) {
        if (board[i][j].isEmpty) {
          empty++;
        } else {
          if (empty > 0) {
            fen += empty.toString();
            empty = 0;
          }
          fen += board[i][j];
        }
      }
      if (empty > 0) fen += empty.toString();
      if (i < 7) fen += '/';
    }

    fen += isWhiteTurn ? ' w KQkq - 0 1' : ' b KQkq - 0 1';
    return fen;
  }

  Future<void> getHint() async {
    if (!isWhiteTurn || isThinking) return;
    
    setState(() => isLoadingHint = true);
    try {
      String fen = boardToFen();
      final response = await http.get(
        Uri.parse(
            'https://stockfish.online/api/s/v2.php?fen=$fen&depth=10'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String bestMove = data['bestmove']?.split(' ')[1] ?? '';

        if (bestMove.length >= 4) {
          setState(() {
            hintMove = bestMove;
            isLoadingHint = false;
          });
          
          showDialog(
            context: context,
            builder: (BuildContext context) {
              int fromCol = bestMove.codeUnitAt(0) - 97;
              int fromRow = 8 - int.parse(bestMove[1]);
              int toCol = bestMove.codeUnitAt(2) - 97;
              int toRow = 8 - int.parse(bestMove[3]);
              
              String fromSquare = '${String.fromCharCode(97 + fromCol)}${8 - fromRow}';
              String toSquare = '${String.fromCharCode(97 + toCol)}${8 - toRow}';
              String piece = board[fromRow][fromCol];
              String pieceName = {
                'P': 'Pawn',
                'N': 'Knight',
                'B': 'Bishop',
                'R': 'Rook',
                'Q': 'Queen',
                'K': 'King',
              }[piece] ?? 'Piece';
              
              return AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                title: const Text(
                  '💡 Hint',
                  style: TextStyle(color: Colors.white),
                ),
                content: Text(
                  'Best move: $pieceName from $fromSquare to $toSquare',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Got it!',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      setState(() => isLoadingHint = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get hint. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void resetGame() {
    setState(() {
      initializeBoard();
      selectedRow = null;
      selectedCol = null;
      isWhiteTurn = true;
      isThinking = false;
      gameStatus = "Your turn (White)";
      moveHistory = [];
      validMoves.clear();
      hintMove = null;
      isLoadingHint = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

     appBar: AppBar(
  backgroundColor: const Color(0xFF1E1E1E),
  centerTitle: true,

  title: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/images/chess_pawn.png',
        height: 25,
        width: 25,
      ),
      const SizedBox(width: 8),
      const Text(
        'Chess',
        style: TextStyle(
          color: Colors.white,
          fontSize: 25
          ,
          fontWeight: FontWeight.bold,   // ⭐ BOLD
        ),
      ),
    ],
  ),

  actions: [
    IconButton(
      icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
      onPressed: isLoadingHint ? null : getHint,
    ),
    IconButton(
      icon: const Icon(Icons.refresh, color: Colors.white),
      onPressed: resetGame,
    ),
  ],
),


      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 36),  
            child: Text(
              gameStatus,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double availableHeight = constraints.maxHeight;
                double availableWidth = constraints.maxWidth;
                double boardSize = availableWidth < availableHeight 
                    ? availableWidth - 16 
                    : availableHeight - 16;
                
                return Center(
                  child: SizedBox(
                    width: boardSize,
                    height: boardSize,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                          child: Row(
                            children: [
                              const SizedBox(width: 20),
                              ...List.generate(8, (index) {
                                return Expanded(
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(97 + index),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(width: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),

                        Expanded(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                child: Column(
                                  children: List.generate(8, (index) {
                                    return Expanded(
                                      child: Center(
                                        child: Text(
                                          '${8 - index}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white24, width: 2),
                                  ),
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 8,
                                    ),
                                    itemCount: 64,
                                    itemBuilder: (context, index) {
                                      int row = index ~/ 8;
                                      int col = index % 8;

                                      bool isLight = (row + col) % 2 == 0;
                                      bool isSelected = selectedRow == row && selectedCol == col;
                                      bool isValidMoveSquare = validMoves.any(
                                        (m) => m[0] == row && m[1] == col,
                                      );

                                      String piece = board[row][col];
                                      String pieceImage = getPieceImage(piece);

                                      return GestureDetector(
                                        onTap: isThinking ? null : () => handleTap(row, col),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.yellow.withOpacity(0.5)
                                                : (isLight
                                                    ? const Color(0xFFEEEED2)
                                                    : const Color(0xFF769656)),
                                          ),
                                          child: Stack(
                                            children: [
                                              if (isValidMoveSquare)
                                                Center(
                                                  child: Container(
                                                    width: piece.isEmpty ? 12 : 38,
                                                    height: piece.isEmpty ? 12 : 38,
                                                    decoration: BoxDecoration(
                                                      color: piece.isEmpty
                                                          ? Colors.black.withOpacity(0.2)
                                                          : Colors.transparent,
                                                      shape: BoxShape.circle,
                                                      border: piece.isNotEmpty
                                                          ? Border.all(
                                                              color: Colors.red.withOpacity(0.6),
                                                              width: 2.5,
                                                            )
                                                          : null,
                                                    ),
                                                  ),
                                                ),

                                              if (pieceImage.isNotEmpty)
                                                Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(3.0),
                                                    child: Image.asset(
                                                      pieceImage,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              
                              SizedBox(
                                width: 20,
                                child: Column(
                                  children: List.generate(8, (index) {
                                    return Expanded(
                                      child: Center(
                                        child: Text(
                                          '${8 - index}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 2),

                        SizedBox(
                          height: 20,
                          child: Row(
                            children: [
                              const SizedBox(width: 20),
                              ...List.generate(8, (index) {
                                return Expanded(
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(97 + index),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(width: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  void handleTap(int row, int col) {
    if (!isWhiteTurn || isThinking) return;

    if (selectedRow == null) {
      if (board[row][col].isNotEmpty &&
          board[row][col].toUpperCase() == board[row][col]) {
        setState(() {
          selectedRow = row;
          selectedCol = col;
          calculateValidMoves(row, col);
        });
      }
    } else {
      if (isValidMove(selectedRow!, selectedCol!, row, col)) {
        makeMove(selectedRow!, selectedCol!, row, col);
      } else {
        if (board[row][col].isNotEmpty &&
            board[row][col].toUpperCase() == board[row][col]) {
          setState(() {
            selectedRow = row;
            selectedCol = col;
            calculateValidMoves(row, col);
          });
        } else {
          setState(() {
            selectedRow = null;
            selectedCol = null;
            validMoves.clear();
          });
        }
      }
    }
  }
}
