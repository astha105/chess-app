// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../widgets/bottom_nav_bar.dart';
import '../services/pgn_recorder.dart';
import 'analysis_screen.dart';

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
  int? hintFromRow;
  int? hintFromCol;
  int? hintToRow;
  int? hintToCol;

  final PGNRecorder pgnRecorder = PGNRecorder();

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

  // ---------------------
  // CHESS ANALYSIS (uses local backend)
  // ---------------------
  Future<Map<String, dynamic>> analyzeGameOnline() async {
    List<String> moves = [...pgnRecorder.moves];
    if (moves.isEmpty) return {};

    try {
      print("Sending ${moves.length} moves to backend for analysis");
      
      final response = await http.post(
        Uri.parse("http://localhost:3000/analyze-batch"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "moves": moves,
        }),
      ).timeout(const Duration(seconds: 180));

      print("Backend response status: ${response.statusCode}");

      if (response.statusCode != 200) {
        print("Backend error response: ${response.body}");
        throw Exception("Backend returned ${response.statusCode}");
      }

      final data = json.decode(response.body);
      final analyzedMoves = List<Map<String, dynamic>>.from(data["moves"] ?? []);

      print("Received ${analyzedMoves.length} analyzed moves");

      // Calculate accuracy
      double whiteAccLoss = 0;
      double blackAccLoss = 0;
      int whiteMoves = 0;
      int blackMoves = 0;

      for (int i = 0; i < analyzedMoves.length; i++) {
        bool isWhite = (i % 2 == 0);
        double cpl = (analyzedMoves[i]["centipawnLoss"] ?? 0).toDouble();

        if (isWhite) {
          whiteAccLoss += cpl;
          whiteMoves++;
        } else {
          blackAccLoss += cpl;
          blackMoves++;
        }
      }

      int whiteAcc = whiteMoves > 0 
        ? (100 - (whiteAccLoss / whiteMoves / 3)).round().clamp(0, 100) 
        : 100;
      int blackAcc = blackMoves > 0 
        ? (100 - (blackAccLoss / blackMoves / 3)).round().clamp(0, 100) 
        : 100;

      return {
        "moves": analyzedMoves,
        "whiteAccuracy": whiteAcc,
        "blackAccuracy": blackAcc,
      };

    } catch (e) {
      print("Error analyzing game: $e");
      // Return basic fallback data
      return {
        "moves": moves.asMap().entries.map((entry) {
          return {
            "moveNumber": (entry.key ~/ 2) + 1,
            "played": entry.value,
            "best": entry.value,
            "eval": 0,
            "centipawnLoss": 0,
            "tag": "Good",
          };
        }).toList(),
        "whiteAccuracy": 95,
        "blackAccuracy": 95,
      };
    }
  }

  // Helper function to apply a move to a FEN string
  String applyMoveToFen(String fen, String move) {
    // Parse the current FEN
    List<String> parts = fen.split(' ');
    String position = parts[0];
    String turn = parts[1];
    
    // Convert position to 2D array
    List<List<String>> board = [];
    for (String row in position.split('/')) {
      List<String> boardRow = [];
      for (int i = 0; i < row.length; i++) {
        if (int.tryParse(row[i]) != null) {
          int empty = int.parse(row[i]);
          for (int j = 0; j < empty; j++) {
            boardRow.add('');
          }
        } else {
          boardRow.add(row[i]);
        }
      }
      board.add(boardRow);
    }

    // Apply the move
    int fromCol = move.codeUnitAt(0) - 97;
    int fromRow = 8 - int.parse(move[1]);
    int toCol = move.codeUnitAt(2) - 97;
    int toRow = 8 - int.parse(move[3]);

    String piece = board[fromRow][fromCol];
    board[toRow][toCol] = piece;
    board[fromRow][fromCol] = '';

    // Convert back to FEN
    String newPosition = '';
    for (int i = 0; i < 8; i++) {
      int empty = 0;
      for (int j = 0; j < 8; j++) {
        if (board[i][j].isEmpty) {
          empty++;
        } else {
          if (empty > 0) {
            newPosition += empty.toString();
            empty = 0;
          }
          newPosition += board[i][j];
        }
      }
      if (empty > 0) newPosition += empty.toString();
      if (i < 7) newPosition += '/';
    }

    // Toggle turn
    String newTurn = turn == 'w' ? 'b' : 'w';
    
    return '$newPosition $newTurn KQkq - 0 1';
  }

  // -----------------------------

  Future<void> getHint() async {
    if (isLoadingHint || !isWhiteTurn || isThinking) return;

    setState(() {
      isLoadingHint = true;
      hintFromRow = null;
      hintFromCol = null;
      hintToRow = null;
      hintToCol = null;
    });

    try {
      String fen = boardToFen();
      final response = await http.get(
        Uri.parse(
            "https://stockfish.online/api/s/v2.php?fen=$fen&depth=12"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String bestMove = data["bestmove"]?.split(" ")[1] ?? "";

        if (bestMove.length >= 4) {
          int fc = bestMove.codeUnitAt(0) - 97;
          int fr = 8 - int.parse(bestMove[1]);
          int tc = bestMove.codeUnitAt(2) - 97;
          int tr = 8 - int.parse(bestMove[3]);

          setState(() {
            hintMove = bestMove;
            hintFromRow = fr;
            hintFromCol = fc;
            hintToRow = tr;
            hintToCol = tc;
            isLoadingHint = false;
          });
        }
      }
    } catch (e) {
      setState(() => isLoadingHint = false);
    }
  }

  String getPieceImage(String piece) {
    if (piece.isEmpty) return '';
    const Map<String, String> map = {
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
    return map[piece] ?? '';
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
      if (piece.toUpperCase() == piece && target.toUpperCase() == target)
        return false;

      if (piece.toLowerCase() == piece && target.toLowerCase() == target)
        return false;
    }

    if (piece.toLowerCase() == 'p') {
      int dir = piece == 'P' ? -1 : 1;
      int start = piece == 'P' ? 6 : 1;

      if (fromCol == toCol && target.isEmpty) {
        if (toRow == fromRow + dir) return true;
        if (fromRow == start &&
            toRow == fromRow + 2 * dir &&
            board[fromRow + dir][fromCol].isEmpty) return true;
      }

      if ((toCol == fromCol + 1 || toCol == fromCol - 1) &&
          toRow == fromRow + dir &&
          target.isNotEmpty) return true;
    }

    if (piece.toLowerCase() == 'r') {
      if (fromRow == toRow || fromCol == toCol)
        return isPathClear(fromRow, fromCol, toRow, toCol);
    }

    if (piece.toLowerCase() == 'n') {
      int r = (toRow - fromRow).abs();
      int c = (toCol - fromCol).abs();
      return (r == 2 && c == 1) || (r == 1 && c == 2);
    }

    if (piece.toLowerCase() == 'b') {
      if ((toRow - fromRow).abs() == (toCol - fromCol).abs())
        return isPathClear(fromRow, fromCol, toRow, toCol);
    }

    if (piece.toLowerCase() == 'q') {
      if (fromRow == toRow ||
          fromCol == toCol ||
          (toRow - fromRow).abs() == (toCol - fromCol).abs())
        return isPathClear(fromRow, fromCol, toRow, toCol);
    }

    if (piece.toLowerCase() == 'k') {
      return (toRow - fromRow).abs() <= 1 &&
          (toCol - fromCol).abs() <= 1;
    }

    return false;
  }

  bool isPathClear(int fr, int fc, int tr, int tc) {
    int rd = tr > fr ? 1 : (tr < fr ? -1 : 0);
    int cd = tc > fc ? 1 : (tc < fc ? -1 : 0);

    int r = fr + rd;
    int c = fc + cd;

    while (r != tr || c != tc) {
      if (board[r][c].isNotEmpty) return false;
      r += rd;
      c += cd;
    }
    return true;
  }

  void makeMove(int fr, int fc, int tr, int tc) {
    setState(() {
      board[tr][tc] = board[fr][fc];
      board[fr][fc] = "";

      String move =
          '${String.fromCharCode(97 + fc)}${8 - fr}${String.fromCharCode(97 + tc)}${8 - tr}';

      moveHistory.add(move);
      pgnRecorder.addMove(move);

      isWhiteTurn = !isWhiteTurn;
      selectedRow = null;
      selectedCol = null;
      validMoves.clear();
      hintFromRow = null;
      hintFromCol = null;
      hintToRow = null;
      hintToCol = null;
      hintMove = null;

      // Check for checkmate or stalemate
      if (isGameOver()) {
        return; // Game over, don't continue
      }

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
            "https://stockfish.online/api/s/v2.php?fen=$fen&depth=12"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String bestMove = data["bestmove"]?.split(" ")[1] ?? "";

        if (bestMove.length >= 4) {
          int fc = bestMove.codeUnitAt(0) - 97;
          int fr = 8 - int.parse(bestMove[1]);
          int tc = bestMove.codeUnitAt(2) - 97;
          int tr = 8 - int.parse(bestMove[3]);

          await Future.delayed(const Duration(milliseconds: 400));

          setState(() {
            board[tr][tc] = board[fr][fc];
            board[fr][fc] = "";

            pgnRecorder.addMove(bestMove);

            isWhiteTurn = true;
            isThinking = false;
            
            // Check for checkmate/stalemate
            if (!isGameOver()) {
              gameStatus = "Your turn (White)";
            }
          });
        }
      }
    } catch (e) {
      isThinking = false;
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
      if (i < 7) fen += "/";
    }
    fen += isWhiteTurn ? " w KQkq - 0 1" : " b KQkq - 0 1";
    return fen;
  }

  bool isGameOver() {
    // Check if current player has any legal moves
    bool hasLegalMoves = false;
    
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        String piece = board[i][j];
        if (piece.isEmpty) continue;
        
        bool isPieceWhite = piece.toUpperCase() == piece;
        if ((isWhiteTurn && !isPieceWhite) || (!isWhiteTurn && isPieceWhite)) continue;
        
        // Check if this piece has any valid moves
        for (int ti = 0; ti < 8; ti++) {
          for (int tj = 0; tj < 8; tj++) {
            if (isValidMove(i, j, ti, tj)) {
              hasLegalMoves = true;
              break;
            }
          }
          if (hasLegalMoves) break;
        }
        if (hasLegalMoves) break;
      }
      if (hasLegalMoves) break;
    }
    
    if (!hasLegalMoves) {
      // Check if in check (simplified check detection)
      bool inCheck = isInCheck();
      
      String winner = isWhiteTurn ? "Black" : "White";
      String message = inCheck 
          ? "Checkmate! $winner wins!" 
          : "Stalemate! It's a draw!";
      
      gameStatus = message;
      
      // Show dialog
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(inCheck ? '🏆 Checkmate!' : '🤝 Stalemate!'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  resetGame();
                },
                child: const Text('New Game'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  
                  // Analyze the game
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    ),
                  );

                  try {
                    final result = await analyzeGameOnline();
                    if (mounted) Navigator.pop(context);
                    
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnalysisScreen(analysisResult: result),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Analyze'),
              ),
            ],
          ),
        );
      });
      
      return true;
    }
    
    return false;
  }
  
  bool isInCheck() {
    // Find the king position for current player
    String kingPiece = isWhiteTurn ? 'K' : 'k';
    int kingRow = -1, kingCol = -1;
    
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == kingPiece) {
          kingRow = i;
          kingCol = j;
          break;
        }
      }
      if (kingRow != -1) break;
    }
    
    if (kingRow == -1) return false;
    
    // Check if any opponent piece can attack the king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        String piece = board[i][j];
        if (piece.isEmpty) continue;
        
        bool isPieceWhite = piece.toUpperCase() == piece;
        if ((isWhiteTurn && isPieceWhite) || (!isWhiteTurn && !isPieceWhite)) continue;
        
        if (isValidMove(i, j, kingRow, kingCol)) {
          return true;
        }
      }
    }
    
    return false;
  }

  void resetGame() {
    setState(() {
      initializeBoard();
      selectedRow = null;
      selectedCol = null;
      isWhiteTurn = true;
      isThinking = false;
      gameStatus = "Your turn (White)";
      validMoves.clear();
      moveHistory.clear();
      hintMove = null;
      isLoadingHint = false;
      hintFromRow = null;
      hintFromCol = null;
      hintToRow = null;
      hintToCol = null;
      pgnRecorder.moves.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/chess_pawn.png',
              height: 28,
              width: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              "Chess",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isLoadingHint ? Icons.hourglass_empty : Icons.lightbulb_outline,
              color: Colors.white,
            ),
            onPressed: getHint,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: resetGame,
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (_, c) {
                double availableWidth = c.maxWidth;
                double availableHeight = c.maxHeight;
                
                // Calculate board size to fit both width and height
                double maxBoardSize = availableWidth < availableHeight 
                    ? availableWidth - 80 
                    : availableHeight - 100;
                
                // Clamp board size between reasonable values
                double boardSize = maxBoardSize.clamp(280, 550);

                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // Top file labels (a-h)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 25),
                            SizedBox(
                              width: boardSize,
                              height: 20,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(8, (i) {
                                  return SizedBox(
                                    width: boardSize / 8,
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(97 + i),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(width: 25),
                          ],
                        ),

                        // Chess board with rank labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Left rank labels (8-1)
                            SizedBox(
                              width: 25,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(8, (i) {
                                  return SizedBox(
                                    height: boardSize / 8,
                                    child: Center(
                                      child: Text(
                                        '${8 - i}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),

                            // The chess board
                            Container(
                              width: boardSize,
                              height: boardSize,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white24, width: 2),
                              ),
                              child: GridView.builder(
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                itemCount: 64,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 8,
                                ),
                                itemBuilder: (_, index) {
                                  int row = index ~/ 8;
                                  int col = index % 8;
                                  bool isLight =
                                      (row + col) % 2 == 0;

                                  bool isSelected =
                                      selectedRow == row &&
                                          selectedCol == col;

                                  bool isValidSquare = validMoves.any(
                                      (m) =>
                                          m[0] == row &&
                                          m[1] == col);

                                  bool isHintFrom =
                                      hintFromRow == row &&
                                          hintFromCol == col;
                                  bool isHintTo =
                                      hintToRow == row &&
                                          hintToCol == col;

                                  String piece = board[row][col];
                                  String image = getPieceImage(piece);

                                  return GestureDetector(
                                    onTap: () => handleTap(row, col),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.yellow
                                                .withOpacity(0.5)
                                            : isHintFrom ||
                                                    isHintTo
                                                ? Colors.blue
                                                    .withOpacity(0.4)
                                                : (isLight
                                                    ? const Color(
                                                        0xFFEEEED2)
                                                    : const Color(
                                                        0xFF769656)),
                                      ),
                                      child: Stack(
                                        children: [
                                          if (isValidSquare)
                                            Center(
                                              child: Container(
                                                width: piece.isEmpty
                                                    ? 12
                                                    : 36,
                                                height: piece.isEmpty
                                                    ? 12
                                                    : 36,
                                                decoration:
                                                    BoxDecoration(
                                                  shape:
                                                      BoxShape.circle,
                                                  color: piece.isEmpty
                                                      ? Colors
                                                          .black26
                                                      : Colors
                                                          .transparent,
                                                  border: piece
                                                          .isNotEmpty
                                                      ? Border.all(
                                                          color: Colors
                                                              .redAccent,
                                                          width: 3,
                                                        )
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          if (image.isNotEmpty)
                                            Center(
                                              child: Image.asset(
                                                image,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Right rank labels (8-1)
                            SizedBox(
                              width: 25,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(8, (i) {
                                  return SizedBox(
                                    height: boardSize / 8,
                                    child: Center(
                                      child: Text(
                                        '${8 - i}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
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

                        // Bottom file labels (a-h)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 25),
                            SizedBox(
                              width: boardSize,
                              height: 20,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(8, (i) {
                                  return SizedBox(
                                    width: boardSize / 8,
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(97 + i),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(width: 25),
                          ],
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Game status
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                gameStatus,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Analysis button - FIXED TO AWAIT THE RESULT
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 6),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.green,
                  size: 28,
                ),
                onPressed: () async {
                  // Check if there are moves to analyze
                  if (pgnRecorder.moves.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No moves to analyze yet!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  // Show progress dialog with move count
                  int totalMoves = pgnRecorder.moves.length;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(color: Colors.green),
                              const SizedBox(height: 20),
                              const Text(
                                'Analyzing Game',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Analyzing $totalMoves moves',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This may take ${(totalMoves * 0.8).round()}-${(totalMoves * 1.5).round()} seconds',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  try {
                    // Wait for analysis to complete
                    final result = await analyzeGameOnline();

                    // Close loading dialog
                    if (mounted) Navigator.pop(context);

                    // Navigate to analysis screen with the actual result
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnalysisScreen(
                            analysisResult: result,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    // Close loading dialog on error
                    if (mounted) Navigator.pop(context);
                    
                    // Show error message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Analysis failed: ${e.toString().contains('TimeoutException') ? 'Game too long, try analyzing fewer moves' : 'Server error'}'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                },
              ),
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
            board[row][col].toUpperCase() ==
                board[row][col]) {
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