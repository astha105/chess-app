// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/pgn_exporter.dart';

class GameReviewScreen extends StatefulWidget {
  final Map<String, dynamic> analysisResult;

  const GameReviewScreen({super.key, required this.analysisResult});

  @override
  State<GameReviewScreen> createState() => _GameReviewScreenState();
}

class _GameReviewScreenState extends State<GameReviewScreen> {
  int? selectedMoveIndex;

  @override
  Widget build(BuildContext context) {
    final moves = List<Map<String, dynamic>>.from(
        widget.analysisResult["moves"] ?? []);

    final whiteAccuracy = _calculateAccuracy(moves, true);
    final blackAccuracy = _calculateAccuracy(moves, false);
    final whiteStats = _getMoveStats(moves, true);
    final blackStats = _getMoveStats(moves, false);
    final whiteAvgCPL = _getAverageCPL(moves, true);
    final blackAvgCPL = _getAverageCPL(moves, false);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1e1e),
        elevation: 0,
        title: const Text(
          "Game Review",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        // ⭐ PGN EXPORT BUTTON ADDED HERE
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Colors.white),
            onPressed: () {
              PGNExporter.showExportDialog(context, moves);
            },
            tooltip: 'Export PGN',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Accuracy section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1e1e1e),
                    Color(0xFF2a2a2a),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF333333), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAccuracyCard("White", whiteAccuracy, true),
                  Container(
                    width: 1,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  _buildAccuracyCard("Black", blackAccuracy, false),
                ],
              ),
            ),

            // Evaluation Graph
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1a1a1a),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF333333), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.show_chart,
                          color: Colors.white.withOpacity(0.7), size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        "Evaluation",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${moves.length} moves",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 140,
                    child: CustomPaint(
                      painter: EvaluationGraphPainter(moves, selectedMoveIndex),
                      child: Container(),
                    ),
                  ),
                ],
              ),
            ),

            // Stats section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1a1a1a),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF333333), width: 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: _buildStatsColumn(
                          "WHITE", whiteStats, whiteAvgCPL)),
                  const SizedBox(width: 24),
                  Expanded(
                      child: _buildStatsColumn(
                          "BLACK", blackStats, blackAvgCPL)),
                ],
              ),
            ),

            // Moves list
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(moves.length, (i) {
                  return _buildMoveCard(moves[i], i);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyCard(String player, int accuracy, bool isWhite) {
    Color accentColor = _getAccuracyColor(accuracy);
    
    return Column(
      children: [
        Text(
          player,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Accuracy text
            Text(
              "$accuracy%",
              style: TextStyle(
                color: accentColor,
                fontSize: 44,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getAccuracyColor(int accuracy) {
    if (accuracy >= 95) return const Color(0xFF67C23A); // Brilliant green
    if (accuracy >= 90) return const Color(0xFF85CE61); // Excellent green
    if (accuracy >= 80) return const Color(0xFF95D475); // Good green
    if (accuracy >= 70) return const Color(0xFFE6A23C); // Inaccuracy yellow
    if (accuracy >= 60) return const Color(0xFFF56C6C); // Mistake orange
    return const Color(0xFFE84545); // Blunder red
  }

  Widget _buildStatsColumn(
      String label, Map<String, int> stats, double avgCPL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        _buildStatRow("Best", stats["Best"] ?? 0, const Color(0xFF67C23A)),
        _buildStatRow("Excellent", stats["Excellent"] ?? 0, const Color(0xFF85CE61)),
        _buildStatRow("Good", stats["Good"] ?? 0, const Color(0xFF95D475)),
        _buildStatRow("Inaccuracy", stats["Inaccuracy"] ?? 0, const Color(0xFFE6A23C)),
        _buildStatRow("Mistake", stats["Mistake"] ?? 0, const Color(0xFFF56C6C)),
        _buildStatRow("Blunder", stats["Blunder"] ?? 0, const Color(0xFFE84545)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "Avg CPL: ${avgCPL.toStringAsFixed(1)}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "$label:",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Text(
            "$count",
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveCard(Map<String, dynamic> move, int index) {
    final tag = move["tag"] ?? "Good";
    final played = move["played"] ?? "";
    final best = move["best"] ?? "";
    final cpl = move["centipawnLoss"] ?? 0;
    final eval = (move["eval"] as num?)?.toDouble() ?? 0.0;
    final isWhite = index % 2 == 0;
    final moveNumber = (index ~/ 2) + 1;

    final isSelected = selectedMoveIndex == index;
    final tagColor = _getTagColor(tag);

    // Get move explanation
    final explanation = _getMoveExplanation(tag, cpl, played, best);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMoveIndex = isSelected ? null : index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2a2a2a)
              : const Color(0xFF1e1e1e),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? tagColor
                : tagColor.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tagColor.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Move number
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isWhite ? "$moveNumber." : "$moveNumber...",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Spacer(),
                // Eval badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getEvalColor(eval).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getEvalColor(eval).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _formatEval(eval),
                    style: TextStyle(
                      color: _getEvalColor(eval),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Moves row
            Row(
              children: [
                // Played move
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Played",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        played,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (played != best) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white.withOpacity(0.3),
                      size: 20,
                    ),
                  ),
                  // Best move
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Best",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          best,
                          style: const TextStyle(
                            color: Color(0xFF67C23A),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            
            // CPL and explanation
            if (cpl > 0 || explanation.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cpl > 0)
                      Row(
                        children: [
                          Icon(
                            Icons.trending_down_rounded,
                            color: tagColor,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Centipawn loss:",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "$cpl",
                            style: TextStyle(
                              color: tagColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    if (cpl > 0 && explanation.isNotEmpty)
                      const SizedBox(height: 8),
                    if (explanation.isNotEmpty)
                      Text(
                        explanation,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMoveExplanation(String tag, int cpl, String played, String best) {
    switch (tag) {
      case "Best":
        return "This is the best move in this position!";
      case "Excellent":
        return "Very strong move with minimal loss of advantage.";
      case "Good":
        return "Solid move that maintains your position.";
      case "Inaccuracy":
        return "A slightly inaccurate move. Consider $best for better position.";
      case "Mistake":
        return "This move loses significant advantage. $best was much stronger.";
      case "Blunder":
        return "Critical error! This move severely damages your position. $best was essential.";
      default:
        return "";
    }
  }

  String _formatEval(double eval) {
    if (eval.abs() > 100) {
      return eval > 0 ? "+M" : "-M";
    }
    if (eval.abs() < 0.1) {
      return "0.0";
    }
    return "${eval > 0 ? '+' : ''}${eval.toStringAsFixed(1)}";
  }

  Color _getEvalColor(double eval) {
    if (eval > 3) return const Color(0xFF67C23A);
    if (eval > 1) return const Color(0xFF85CE61);
    if (eval > -1) return Colors.white70;
    if (eval > -3) return const Color(0xFFF56C6C);
    return const Color(0xFFE84545);
  }

  int _calculateAccuracy(List<Map<String, dynamic>> moves, bool isWhite) {
    double totalPenalty = 0;
    int count = 0;

    for (int i = 0; i < moves.length; i++) {
      if ((i % 2 == 0) == isWhite) {
        final cpl = (moves[i]["centipawnLoss"] ?? 0).toDouble();
        totalPenalty += (cpl / 300).clamp(0.0, 1.0);
        count++;
      }
    }

    if (count == 0) return 100;
    return (100 * (1 - totalPenalty / count)).round().clamp(0, 100);
  }

  Map<String, int> _getMoveStats(
      List<Map<String, dynamic>> moves, bool isWhite) {
    final stats = {
      "Best": 0,
      "Excellent": 0,
      "Good": 0,
      "Inaccuracy": 0,
      "Mistake": 0,
      "Blunder": 0,
    };

    for (int i = 0; i < moves.length; i++) {
      if ((i % 2 == 0) == isWhite) {
        final tag = moves[i]["tag"] ?? "Good";
        if (stats.containsKey(tag)) {
          stats[tag] = (stats[tag] ?? 0) + 1;
        }
      }
    }

    return stats;
  }

  double _getAverageCPL(List<Map<String, dynamic>> moves, bool isWhite) {
    double totalCPL = 0;
    int count = 0;

    for (int i = 0; i < moves.length; i++) {
      if ((i % 2 == 0) == isWhite) {
        totalCPL += (moves[i]["centipawnLoss"] ?? 0).toDouble();
        count++;
      }
    }

    return count > 0 ? totalCPL / count : 0;
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case "Best":
        return const Color(0xFF67C23A); // Brilliant green
      case "Excellent":
        return const Color(0xFF85CE61); // Excellent green
      case "Good":
        return const Color(0xFF95D475); // Good green
      case "Inaccuracy":
        return const Color(0xFFE6A23C); // Warning yellow
      case "Mistake":
        return const Color(0xFFF56C6C); // Error orange
      case "Blunder":
        return const Color(0xFFE84545); // Critical red
      default:
        return Colors.grey;
    }
  }
}

class EvaluationGraphPainter extends CustomPainter {
  final List<Map<String, dynamic>> moves;
  final int? selectedMoveIndex;

  EvaluationGraphPainter(this.moves, this.selectedMoveIndex);

  @override
  void paint(Canvas canvas, Size size) {
    if (moves.isEmpty) return;

    // Background
    final bgPaint = Paint()..color = const Color(0xFF0a0a0a);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      double y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Center line
    final centerLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerLinePaint,
    );

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < moves.length; i++) {
      double eval = (moves[i]["eval"] as num?)?.toDouble() ?? 0.0;
      eval = eval.clamp(-10.0, 10.0);

      double normalizedEval = (eval + 10) / 20;
      double y = size.height * (1 - normalizedEval);
      double x = size.width * i / math.max(1, moves.length - 1);

      points.add(Offset(x, y));
    }

    // Draw gradient area
    for (int i = 0; i < points.length - 1; i++) {
      final path = Path();
      path.moveTo(points[i].dx, size.height / 2);
      path.lineTo(points[i].dx, points[i].dy);
      path.lineTo(points[i + 1].dx, points[i + 1].dy);
      path.lineTo(points[i + 1].dx, size.height / 2);
      path.close();

      double eval = (moves[i]["eval"] as num?)?.toDouble() ?? 0.0;
      final fillPaint = Paint()
        ..color = eval > 0
            ? const Color(0xFF67C23A).withOpacity(0.25)
            : const Color(0xFFE84545).withOpacity(0.25)
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, fillPaint);
    }

    // Draw line
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(points[i].dx, points[i].dy);
      } else {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }
    canvas.drawPath(path, linePaint);

    // Draw mistake markers
    for (int i = 0; i < moves.length; i++) {
      String tag = moves[i]["tag"] ?? "Good";
      if (tag == "Inaccuracy" || tag == "Mistake" || tag == "Blunder") {
        Color markerColor = _getMarkerColor(tag);

        canvas.drawCircle(
          points[i],
          7,
          Paint()
            ..color = markerColor
            ..style = PaintingStyle.fill,
        );

        canvas.drawCircle(
          points[i],
          7,
          Paint()
            ..color = Colors.white
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke,
        );
      }
    }

    // Selected move indicator
    if (selectedMoveIndex != null &&
        selectedMoveIndex! >= 0 &&
        selectedMoveIndex! < points.length) {
      final selectedPoint = points[selectedMoveIndex!];

      // Vertical line
      final verticalPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(selectedPoint.dx, 0),
        Offset(selectedPoint.dx, size.height),
        verticalPaint,
      );

      // Glow
      canvas.drawCircle(
        selectedPoint,
        14,
        Paint()
          ..color = const Color(0xFF67C23A).withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        selectedPoint,
        10,
        Paint()
          ..color = const Color(0xFF67C23A)
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        selectedPoint,
        10,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke,
      );
    }
  }

  Color _getMarkerColor(String tag) {
    switch (tag) {
      case "Inaccuracy":
        return const Color(0xFFE6A23C);
      case "Mistake":
        return const Color(0xFFF56C6C);
      case "Blunder":
        return const Color(0xFFE84545);
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}