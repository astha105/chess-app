// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../widgets/bottom_nav_bar.dart';
import '../services/pgn_recorder.dart';
import '../services/engine_service.dart';
import 'game_review_screen.dart'; // ← ADDED THIS IMPORT

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
  bool _isAnalyzing = false; // Add flag to prevent multiple analysis calls

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
  // FIXED: Use backend batch analysis instead of calling API for each move
  // ---------------------
  Future<void> analyzeAndNavigate() async {
    // Prevent multiple simultaneous analysis calls
    if (_isAnalyzing) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analysis already in progress')),
        );
      }
      return;
    }

    List<String> moves = [...pgnRecorder.moves];
    if (moves.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No moves to analyze')),
        );
      }
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analyzing game...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Call backend batch analysis - ONE CALL for all moves
      final result = await EngineService.analyzeGame(moves);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to analysis screen - FIXED: Changed to GameReviewScreen
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameReviewScreen(
              analysisResult: result,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
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
      ).timeout(const Duration(seconds: 10));

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
      ).timeout(const Duration(seconds: 15));

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
            gameStatus = "Your turn (White)";
            isThinking = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isThinking = false;
          gameStatus = "Your turn (White)";
        });
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
      if (i < 7) fen += "/";
    }
    fen += isWhiteTurn ? " w KQkq - 0 1" : " b KQkq - 0 1";
    return fen;
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
      _isAnalyzing = false;
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

          // Analysis button - FIXED: calls analyzeAndNavigate() once
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 6),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  _isAnalyzing ? Icons.hourglass_empty : Icons.analytics_outlined,
                  color: _isAnalyzing ? Colors.orange : Colors.green,
                  size: 28,
                ),
                onPressed: _isAnalyzing ? null : analyzeAndNavigate,
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