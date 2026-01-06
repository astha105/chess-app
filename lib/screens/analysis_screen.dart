// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AnalysisScreen extends StatefulWidget {
  final Map<String, dynamic> analysisResult;

  const AnalysisScreen({super.key, required this.analysisResult});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int currentMoveIndex = -1; // -1 means starting position
  List<List<String>> currentBoard = [];
  bool showEvalGraph = false;

  @override
  void initState() {
    super.initState();
    _initializeStartingPosition();
  }

  void _initializeStartingPosition() {
    currentBoard = [
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

  void _goToMove(int index) {
    setState(() {
      currentMoveIndex = index;
      _updateBoardToMove(index);
    });
  }

  void _updateBoardToMove(int targetIndex) {
    // Reset to starting position
    _initializeStartingPosition();

    if (targetIndex < 0) return;

    // Apply all moves up to targetIndex
    final moves = List<Map<String, dynamic>>.from(widget.analysisResult["moves"] ?? []);
    for (int i = 0; i <= targetIndex && i < moves.length; i++) {
      String move = moves[i]["played"];
      _applyMove(move);
    }
  }

  void _applyMove(String move) {
    if (move.length < 4) return;
    int fromCol = move.codeUnitAt(0) - 97;
    int fromRow = 8 - int.parse(move[1]);
    int toCol = move.codeUnitAt(2) - 97;
    int toRow = 8 - int.parse(move[3]);

    if (fromRow >= 0 && fromRow < 8 && fromCol >= 0 && fromCol < 8 &&
        toRow >= 0 && toRow < 8 && toCol >= 0 && toCol < 8) {
      currentBoard[toRow][toCol] = currentBoard[fromRow][fromCol];
      currentBoard[fromRow][fromCol] = "";
    }
  }

  void _nextMove() {
    final moves = List<Map<String, dynamic>>.from(widget.analysisResult["moves"] ?? []);
    if (currentMoveIndex < moves.length - 1) {
      _goToMove(currentMoveIndex + 1);
    }
  }

  void _previousMove() {
    if (currentMoveIndex >= 0) {
      _goToMove(currentMoveIndex - 1);
    }
  }

  void _firstMove() {
    _goToMove(-1);
  }

  void _lastMove() {
    final moves = List<Map<String, dynamic>>.from(widget.analysisResult["moves"] ?? []);
    if (moves.isNotEmpty) {
      _goToMove(moves.length - 1);
    }
  }

  String _getPieceImage(String piece) {
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

  @override
  Widget build(BuildContext context) {
    final moves = List<Map<String, dynamic>>.from(widget.analysisResult["moves"] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Row(
          children: [
            // Left side: Board with evaluation bar
            Expanded(
              flex: 3,
              child: _buildBoardSection(moves),
            ),
            // Right side: Analysis panel
            Expanded(
              flex: 2,
              child: _buildAnalysisPanel(moves),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardSection(List<Map<String, dynamic>> moves) {
    double currentEval = 0.0;
    if (currentMoveIndex >= 0 && currentMoveIndex < moves.length) {
      currentEval = (moves[currentMoveIndex]["eval"] as num).toDouble();
    } else if (moves.isNotEmpty) {
      currentEval = (moves[0]["eval"] as num).toDouble();
    }

    return Container(
      color: const Color(0xFF1a1a1a),
      child: Column(
        children: [
          // Player name (Black)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: const [
                Icon(Icons.person, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text(
                  "Black",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Board with evaluation bar
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Evaluation bar
                  _buildEvaluationBar(currentEval),
                  // Board
                  _buildBoard(),
                ],
              ),
            ),
          ),
          // Player name (White)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: const [
                Icon(Icons.person, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text(
                  "White",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationBar(double eval) {
    // Clamp evaluation to reasonable range
    eval = eval.clamp(-10.0, 10.0);
    
    // Convert eval to percentage (0 to 1, where 0.5 is equal)
    double normalizedEval = (eval + 10) / 20; // 0 to 1
    double whitePercentage = normalizedEval; // Higher eval = more white
    
    return LayoutBuilder(
      builder: (context, constraints) {
        double barHeight = constraints.maxHeight * 0.6;
        double whiteHeight = barHeight * whitePercentage;
        double blackHeight = barHeight * (1 - whitePercentage);
        
        return Container(
          width: 24,
          margin: const EdgeInsets.only(right: 0),
          decoration: BoxDecoration(
            color: const Color(0xFF262421),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Stack(
            children: [
              // Black portion (bottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: blackHeight,
                child: Container(
                  color: const Color(0xFF2c2c2c),
                ),
              ),
              // White portion (top)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: whiteHeight,
                child: Container(
                  color: const Color(0xFFf0f0f0),
                ),
              ),
              // Evaluation text
              Center(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    eval.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double boardSize = constraints.maxHeight * 0.6;
        return Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Stack(
            children: [
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 64,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemBuilder: (_, index) {
                  int row = index ~/ 8;
                  int col = index % 8;
                  bool isLight = (row + col) % 2 == 0;
                  String piece = currentBoard[row][col];
                  String image = _getPieceImage(piece);

                  return Container(
                    decoration: BoxDecoration(
                      color: isLight ? const Color(0xFFEEEED2) : const Color(0xFF769656),
                    ),
                    child: Stack(
                      children: [
                        if (image.isNotEmpty)
                          Center(
                            child: Image.asset(
                              image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        // Rank numbers (left edge)
                        if (col == 0)
                          Positioned(
                            left: 4,
                            top: 4,
                            child: Text(
                              "${8 - row}",
                              style: TextStyle(
                                color: isLight ? const Color(0xFF769656) : const Color(0xFFEEEED2),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        // File letters (bottom edge)
                        if (row == 7)
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Text(
                              String.fromCharCode(97 + col),
                              style: TextStyle(
                                color: isLight ? const Color(0xFF769656) : const Color(0xFFEEEED2),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalysisPanel(List<Map<String, dynamic>> moves) {
    return Container(
      color: const Color(0xFF262421),
      child: Column(
        children: [
          // Header with title and settings
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white12, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  "Analysis",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white70, size: 20),
                  onPressed: () {
                    // Settings action
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Move list or evaluation graph
          Expanded(
            child: showEvalGraph
                ? _buildEvaluationGraph(moves)
                : _buildMoveList(moves),
          ),
          // Navigation controls
          _buildNavigationControls(moves),
        ],
      ),
    );
  }

  Widget _buildNavigationControls(List<Map<String, dynamic>> moves) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Navigation buttons
          Row(
            children: [
              _navButton(Icons.skip_previous, _firstMove, currentMoveIndex > -1),
              const SizedBox(width: 8),
              _navButton(Icons.chevron_left, _previousMove, currentMoveIndex >= 0),
              const SizedBox(width: 8),
              _navButton(Icons.chevron_right, _nextMove, currentMoveIndex < moves.length - 1),
              const SizedBox(width: 8),
              _navButton(Icons.skip_next, _lastMove, currentMoveIndex < moves.length - 1),
            ],
          ),
          // Action buttons
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    currentMoveIndex = -1;
                    _initializeStartingPosition();
                  });
                },
                child: const Text(
                  "New",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Save action
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Review action
                },
                child: const Text(
                  "Review",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
                onPressed: () {
                  // More options
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback? onPressed, bool enabled) {
    return IconButton(
      icon: Icon(icon, color: enabled ? Colors.white70 : Colors.white24, size: 20),
      onPressed: enabled ? onPressed : null,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildMoveList(List<Map<String, dynamic>> moves) {
    if (moves.isEmpty) {
      return const Center(
        child: Text(
          "No moves to display",
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: moves.length,
      itemBuilder: (_, i) {
        final m = moves[i];
        final isSelected = i == currentMoveIndex;
        final isWhite = i % 2 == 0;

        return InkWell(
          onTap: () => _goToMove(i),
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF3a3a3a) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                // Move number
                SizedBox(
                  width: 35,
                  child: Text(
                    isWhite ? "${(i ~/ 2) + 1}." : "",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ),
                // Move notation
                Expanded(
                  child: Text(
                    m["played"],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                // Tag chip
                if (m["tag"] != "Good")
                  _tagChip(m["tag"]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEvaluationGraph(List<Map<String, dynamic>> moves) {
    if (moves.isEmpty) {
      return const Center(
        child: Text(
          "No moves to analyze",
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.show_chart, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                "Evaluation",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: EvaluationGraphPainter(moves, currentMoveIndex),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _tagColor(tag),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case "Good":
        return Colors.green;
      case "Inaccuracy":
        return Colors.orange;
      case "Mistake":
        return Colors.deepOrange;
      case "Blunder":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class EvaluationGraphPainter extends CustomPainter {
  final List<Map<String, dynamic>> moves;
  final int currentMoveIndex;

  EvaluationGraphPainter(this.moves, this.currentMoveIndex);

  @override
  void paint(Canvas canvas, Size size) {
    if (moves.isEmpty) return;

    final gridPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;

    final centerLinePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2;

    // Draw grid lines (horizontal)
    for (int i = 0; i <= 10; i++) {
      double y = size.height * i / 10;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw center line (equal position)
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerLinePaint,
    );

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < moves.length; i++) {
      double eval = (moves[i]["eval"] as num).toDouble();
      
      // Clamp evaluation to reasonable range for display
      eval = eval.clamp(-10.0, 10.0);
      
      // Convert eval to y position (flip so positive is up for white)
      double normalizedEval = (eval + 10) / 20; // 0 to 1
      double y = size.height * (1 - normalizedEval);
      double x = size.width * i / (moves.length > 1 ? moves.length - 1 : 1);
      
      points.add(Offset(x, y));
    }

    // Draw the evaluation curve with gradient
    for (int i = 0; i < points.length - 1; i++) {
      final paint = Paint()
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      
      // Get color based on evaluation
      double eval = (moves[i]["eval"] as num).toDouble();
      paint.color = _getEvalColor(eval);
      
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // Draw markers for mistakes and blunders
    for (int i = 0; i < moves.length; i++) {
      String tag = moves[i]["tag"];
      if (tag != "Good" && i < points.length) {
        Color tagColor = _getTagColor(tag);
        
        // Draw outer circle with glow
        canvas.drawCircle(
          points[i],
          8,
          Paint()
            ..color = tagColor.withOpacity(0.3)
            ..style = PaintingStyle.fill,
        );
        
        // Draw main circle
        canvas.drawCircle(
          points[i],
          5,
          Paint()
            ..color = tagColor
            ..style = PaintingStyle.fill,
        );
        
        // Draw border
        canvas.drawCircle(
          points[i],
          5,
          Paint()
            ..color = Colors.white
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke,
        );
      }
    }

    // Draw current position indicator
    if (currentMoveIndex >= 0 && currentMoveIndex < points.length) {
      final currentPoint = points[currentMoveIndex];
      
      // Outer glow
      canvas.drawCircle(
        currentPoint,
        12,
        Paint()
          ..color = const Color(0xFF81b64c).withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
      
      // Main circle
      canvas.drawCircle(
        currentPoint,
        8,
        Paint()
          ..color = const Color(0xFF81b64c)
          ..style = PaintingStyle.fill,
      );
      
      // Border
      canvas.drawCircle(
        currentPoint,
        8,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    // Draw labels for y-axis
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw +10, 0, -10 labels
    _drawLabel(canvas, textPainter, "+10", 10, size.height * 0.05);
    _drawLabel(canvas, textPainter, "0", 10, size.height * 0.5);
    _drawLabel(canvas, textPainter, "-10", 10, size.height * 0.95);
  }

  void _drawLabel(Canvas canvas, TextPainter textPainter, String text, double x, double y) {
    textPainter.text = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y - textPainter.height / 2));
  }

  Color _getEvalColor(double eval) {
    if (eval > 3) return const Color(0xFF81b64c); // Green (winning for white)
    if (eval > 1) return const Color(0xFFa0c964);
    if (eval > -1) return const Color(0xFFc4c4c4); // Gray (equal)
    if (eval > -3) return const Color(0xFFd4a574);
    return const Color(0xFFb33430); // Red (winning for black)
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case "Inaccuracy":
        return Colors.orange;
      case "Mistake":
        return Colors.deepOrange;
      case "Blunder":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
