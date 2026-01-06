// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  int currentPuzzleIndex = 0;
  int score = 0;
  int hintsUsed = 0;
  bool showHint = false;
  bool puzzleSolved = false;
  bool showExplanation = false;
  int timeElapsed = 0;
  Timer? timer;
  String? selectedSquare;
  String? hoveredSquare;
  List<String> userMoves = [];
  Map<String, String> currentPuzzlePieces = {};

  final List<ChessPuzzle> puzzles = [
    ChessPuzzle(
      id: 1,
      name: "Back Rank Mate",
      difficulty: "Beginner",
      fen: "6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1",
      solution: ["Ra8"],
      hint: "The king is trapped on the back rank. How can you use your rook?",
      explanation:
          "This is a classic back rank mate! When a king is trapped on its back rank by its own pawns, a rook or queen can deliver checkmate. Always watch for this pattern in your games.",
      theme: "Back Rank",
      rating: 800,
    ),
    ChessPuzzle(
      id: 2,
      name: "Fork Attack",
      difficulty: "Beginner",
      fen: "r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4",
      solution: ["Nxe5"],
      hint: "Your knight can capture the pawn and attack two pieces at once!",
      explanation:
          "A fork is when one piece attacks two or more enemy pieces simultaneously. Knights are especially good at forking because they can jump over other pieces. Here, Nxe5 attacks both the king and the rook!",
      theme: "Fork",
      rating: 900,
    ),
    ChessPuzzle(
      id: 3,
      name: "Pin Tactic",
      difficulty: "Intermediate",
      fen: "r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3",
      solution: ["Nf6"],
      hint: "Move your knight to attack White's center pawn while developing.",
      explanation:
          "This move develops your knight while attacking the e4 pawn. The bishop on c4 is now pinning the f7 pawn to your king, which is why f7 is a weak square. Be aware of pins in your position!",
      theme: "Pin",
      rating: 1100,
    ),
    ChessPuzzle(
      id: 4,
      name: "Discovered Attack",
      difficulty: "Intermediate",
      fen: "r1bqkb1r/pppp1ppp/2n2n2/4p3/2BPP3/5N2/PPP2PPP/RNBQK2R b KQkq d3 0 4",
      solution: ["Nxe4"],
      hint: "You can capture the pawn because moving your knight discovers an attack!",
      explanation:
          "This is a discovered attack! When your knight takes on e4, it moves away from the d-file, allowing your queen to attack White's queen on d1. White must deal with this threat instead of recapturing your knight.",
      theme: "Discovered Attack",
      rating: 1200,
    ),
    ChessPuzzle(
      id: 5,
      name: "Double Attack",
      difficulty: "Advanced",
      fen: "r2qkb1r/ppp2ppp/2n2n2/3pp3/2B1P3/2N2N2/PPPP1PPP/R1BQK2R w KQkq - 0 6",
      solution: ["Bxf7+"],
      hint: "Sacrifice your bishop with check to win material!",
      explanation:
          "Bxf7+ is a classic bishop sacrifice! After the king takes (forced), Nxe5 attacks the queen and threatens the knight on c6. This wins at least a pawn and damages Black's king safety. Look for forcing moves like checks!",
      theme: "Sacrifice",
      rating: 1400,
    ),
    ChessPuzzle(
      id: 6,
      name: "Skewer Tactic",
      difficulty: "Advanced",
      fen: "6k1/5ppp/8/8/8/8/5PPP/R4RK1 w - - 0 1",
      solution: ["Ra8+"],
      hint: "Check the king and win the other rook!",
      explanation:
          "A skewer is like a pin, but in reverse! Here, Ra8+ forces the king to move, and then you capture the rook on f8. The valuable piece (king) is in front, and must move, exposing the less valuable piece (rook) behind it.",
      theme: "Skewer",
      rating: 1300,
    ),
    ChessPuzzle(
      id: 7,
      name: "Clearance Sacrifice",
      difficulty: "Expert",
      fen: "r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQK2R w KQkq - 0 6",
      solution: ["Bxf7+", "Kxf7", "Nxe5+"],
      hint: "Sacrifice your bishop to clear the way for your knight!",
      explanation:
          "This is a clearance sacrifice! By giving up your bishop with Bxf7+, you clear the e5 square for your knight. After Kxf7 Nxe5+, you fork the king and queen, winning the queen! This pattern appears in many games.",
      theme: "Clearance",
      rating: 1600,
    ),
    ChessPuzzle(
      id: 8,
      name: "Smothered Mate",
      difficulty: "Expert",
      fen: "6k1/5ppp/8/8/8/8/5PPP/5RKN w - - 0 1",
      solution: ["Nf7"],
      hint: "The knight can deliver checkmate when the king is trapped by its own pieces!",
      explanation:
          "This is a smothered mate! The king is completely trapped by its own pieces (smothered), and your knight on f7 gives checkmate. The rook on f1 controls the escape squares. This beautiful pattern is named after Philidor, an 18th-century chess master!",
      theme: "Checkmate Pattern",
      rating: 1700,
    ),
  ];

  ChessPuzzle get currentPuzzle => puzzles[currentPuzzleIndex];

  @override
  void initState() {
    super.initState();
    currentPuzzlePieces = _parseFEN(currentPuzzle.fen);
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer?.cancel();
    timeElapsed = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !puzzleSolved) {
        setState(() {
          timeElapsed++;
        });
      }
    });
  }

  void checkSolution(String move) {
    setState(() {
      userMoves.add(move);

      if (currentPuzzle.solution.length == userMoves.length) {
        bool correct = true;
        for (int i = 0; i < userMoves.length; i++) {
          if (userMoves[i] != currentPuzzle.solution[i]) {
            correct = false;
            break;
          }
        }

        if (correct) {
          puzzleSolved = true;
          score += (100 - hintsUsed * 20 - (timeElapsed > 60 ? 20 : 0));
          timer?.cancel();
          showExplanation = true;
        } else {
          userMoves.clear();
          selectedSquare = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Not quite! Try again.'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    });
  }

  void nextPuzzle() {
    if (currentPuzzleIndex < puzzles.length - 1) {
      setState(() {
        currentPuzzleIndex++;
        puzzleSolved = false;
        showHint = false;
        showExplanation = false;
        hintsUsed = 0;
        userMoves.clear();
        selectedSquare = null;
        hoveredSquare = null;
        currentPuzzlePieces = _parseFEN(currentPuzzle.fen);
      });
      startTimer();
    } else {
      showCompletionDialog();
    }
  }

  void showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎉 All Puzzles Complete!',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Final Score: $score',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You completed ${puzzles.length} puzzles!',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentPuzzleIndex = 0;
                score = 0;
                puzzleSolved = false;
                showHint = false;
                showExplanation = false;
                hintsUsed = 0;
                userMoves.clear();
                selectedSquare = null;
                hoveredSquare = null;
                currentPuzzlePieces = _parseFEN(currentPuzzle.fen);
              });
              startTimer();
            },
            child: const Text('Play Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Solve Puzzles',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final isCompact = availableHeight < 700;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isCompact ? 8 : 16,
                ),
                child: Column(
                  children: [
                    SizedBox(height: isCompact ? 24 : 32),

                    // Puzzle Info Header
                    Container(
                      padding: EdgeInsets.all(isCompact ? 12 : 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1F1F),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getDifficultyColor(currentPuzzle.difficulty),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentPuzzle.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isCompact ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color:
                                            _getDifficultyColor(currentPuzzle.difficulty)
                                                .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        currentPuzzle.difficulty,
                                        style: TextStyle(
                                          color: _getDifficultyColor(
                                              currentPuzzle.difficulty),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '⭐ ${currentPuzzle.rating}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.school,
                                        color: Colors.blueAccent, size: 14),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        currentPuzzle.theme,
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${currentPuzzleIndex + 1}/${puzzles.length}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _formatTime(timeElapsed),
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isCompact ? 16 : 20),

                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, boardConstraints) {
                          final size =
                              boardConstraints.maxWidth < boardConstraints.maxHeight
                                  ? boardConstraints.maxWidth
                                  : boardConstraints.maxHeight;

                          return Center(
                            child: Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      _getDifficultyColor(currentPuzzle.difficulty),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        _getDifficultyColor(currentPuzzle.difficulty)
                                            .withOpacity(0.3),
                                    blurRadius: 16,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: _buildChessBoard(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: isCompact ? 6 : 8),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: puzzleSolved
                                  ? null
                                  : () {
                                      setState(() {
                                        showHint = !showHint;
                                        if (showHint && hintsUsed == 0) {
                                          hintsUsed++;
                                        }
                                      });
                                    },
                              icon: const Icon(Icons.lightbulb_outline, size: 18),
                              label: const Text('Hint'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                    vertical: isCompact ? 10 : 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  userMoves.clear();
                                  selectedSquare = null;
                                  hoveredSquare = null;
                                  showHint = false;
                                });
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Reset'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1F1F1F),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: isCompact ? 10 : 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (showHint)
                      Container(
                        margin: EdgeInsets.only(top: isCompact ? 8 : 12),
                        padding: EdgeInsets.all(isCompact ? 10 : 12),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.orangeAccent, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb,
                                color: Colors.orangeAccent, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                currentPuzzle.hint,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (showExplanation)
                      Container(
                        margin: EdgeInsets.only(top: isCompact ? 8 : 12),
                        padding: EdgeInsets.all(isCompact ? 10 : 12),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.greenAccent, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.greenAccent, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Puzzle Solved!',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentPuzzle.explanation,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: nextPuzzle,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent,
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(
                                      vertical: isCompact ? 10 : 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  currentPuzzleIndex < puzzles.length - 1
                                      ? 'Next Puzzle →'
                                      : 'Complete! 🎉',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
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
        },
      ),
    );
  }

  Widget _buildChessBoard() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
      itemCount: 64,
      itemBuilder: (context, index) {
        int row = index ~/ 8;
        int col = index % 8;
        bool isLight = (row + col) % 2 == 0;
        String square = '${String.fromCharCode(97 + col)}${8 - row}';
        bool isHovered = hoveredSquare == square;
        bool isSelected = selectedSquare == square;

        return MouseRegion(
          onEnter: (_) {
            if (!puzzleSolved) {
              setState(() {
                hoveredSquare = square;
              });
            }
          },
          onExit: (_) {
            setState(() {
              hoveredSquare = null;
            });
          },
          cursor: puzzleSolved
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          child: GestureDetector(
            onTapDown: puzzleSolved
                ? null
                : (_) {
                    setState(() {
                      hoveredSquare = square;
                    });
                  },
            onTapUp: puzzleSolved
                ? null
                : (_) {
                    setState(() {
                      hoveredSquare = null;
                    });
                  },
            onTapCancel: puzzleSolved
                ? null
                : () {
                    setState(() {
                      hoveredSquare = null;
                    });
                  },
            onTap: puzzleSolved
                ? null
                : () {
                    _handleSquareTap(square);
                  },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? (isLight
                        ? const Color(0xFFF6F669)
                        : const Color(0xFFBACA44))
                    : (isHovered
                        ? (isLight
                            ? const Color(0xFFF6F669).withOpacity(0.7)
                            : const Color(0xFFBACA44).withOpacity(0.7))
                        : (isLight
                            ? const Color(0xFFEEEED2)
                            : const Color(0xFF769656))),
              ),
              child: _getPieceWidget(square),
            ),
          ),
        );
      },
    );
  }

  void _handleSquareTap(String square) {
    if (selectedSquare == null) {
      // First click - select piece
      if (currentPuzzlePieces.containsKey(square)) {
        String piece = currentPuzzlePieces[square]!;
        // Check if it's the right color's turn
        bool isWhiteTurn = currentPuzzle.fen.contains(' w ');
        bool isWhitePiece = piece.startsWith('white');
        
        if (isWhiteTurn == isWhitePiece) {
          setState(() {
            selectedSquare = square;
          });
        }
      }
    } else {
      // Second click - try to move
      if (square == selectedSquare) {
        // Clicked same square, deselect
        setState(() {
          selectedSquare = null;
        });
      } else {
        // Try to make the move
        String from = selectedSquare!;
        String to = square;
        String move = _constructMove(from, to);
        
        setState(() {
          selectedSquare = null;
        });
        
        if (move.isNotEmpty) {
          checkSolution(move);
        }
      }
    }
  }

  String _constructMove(String from, String to) {
    if (!currentPuzzlePieces.containsKey(from)) return '';
    
    String piece = currentPuzzlePieces[from]!;
    String pieceType = piece.split('_')[1]; // e.g., 'rook', 'knight'
    
    bool isCapture = currentPuzzlePieces.containsKey(to);
    
    // Construct move in algebraic notation
    String move = '';
    
    switch (pieceType) {
      case 'pawn':
        if (isCapture) {
          move = '${from[0]}x$to';
        } else {
          move = to;
        }
        break;
      case 'knight':
        move = 'N${isCapture ? 'x' : ''}$to';
        break;
      case 'bishop':
        move = 'B${isCapture ? 'x' : ''}$to';
        break;
      case 'rook':
        move = 'R${isCapture ? 'x' : ''}$to';
        break;
      case 'queen':
        move = 'Q${isCapture ? 'x' : ''}$to';
        break;
      case 'king':
        move = 'K${isCapture ? 'x' : ''}$to';
        break;
    }
    
    // Check if move gives check (simplified - just add + if targeting near enemy king)
    if (_wouldGiveCheck(to)) {
      move += '+';
    }
    
    return move;
  }

  bool _wouldGiveCheck(String square) {
    // Simplified check detection
    // In a real implementation, you'd properly check if the king is in check
    return false; // Placeholder
  }

  Map<String, String> _parseFEN(String fen) {
    Map<String, String> pieces = {};
    List<String> rows = fen.split(' ')[0].split('/');

    for (int i = 0; i < rows.length; i++) {
      String row = rows[i];
      int col = 0;

      for (int j = 0; j < row.length; j++) {
        String char = row[j];

        if (int.tryParse(char) != null) {
          col += int.parse(char);
        } else {
          String square = '${String.fromCharCode(97 + col)}${8 - i}';
          String pieceName = _getPieceName(char);
          if (pieceName.isNotEmpty) {
            pieces[square] = pieceName;
          }
          col++;
        }
      }
    }

    return pieces;
  }

  String _getPieceName(String fenChar) {
    Map<String, String> pieceMap = {
      'r': 'black_rook',
      'n': 'black_knight',
      'b': 'black_bishop',
      'q': 'black_queen',
      'k': 'black_king',
      'p': 'black_pawn',
      'R': 'white_rook',
      'N': 'white_knight',
      'B': 'white_bishop',
      'Q': 'white_queen',
      'K': 'white_king',
      'P': 'white_pawn',
    };

    return pieceMap[fenChar] ?? '';
  }

  Widget? _getPieceWidget(String square) {
    if (currentPuzzlePieces.containsKey(square)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset(
            'assets/images/chess/${currentPuzzlePieces[square]}.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
          ),
        ),
      );
    }
    return null;
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.greenAccent;
      case 'Intermediate':
        return Colors.blueAccent;
      case 'Advanced':
        return Colors.orangeAccent;
      case 'Expert':
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class ChessPuzzle {
  final int id;
  final String name;
  final String difficulty;
  final String fen;
  final List<String> solution;
  final String hint;
  final String explanation;
  final String theme;
  final int rating;

  ChessPuzzle({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.fen,
    required this.solution,
    required this.hint,
    required this.explanation,
    required this.theme,
    required this.rating,
  });
}