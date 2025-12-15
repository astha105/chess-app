// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// FINAL Chess.com Style Game Analysis Screen - PRODUCTION READY
class AnalysisScreen extends StatefulWidget {
  final Future<Map<String, dynamic>> result;

  const AnalysisScreen({super.key, required this.result});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _currentMoveIndex = 0;
  bool _showEngineLines = true;
  bool _showBestMoveArrows = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Game Review",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white70, size: 26),
            onPressed: () => _showHelpDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70, size: 26),
            onPressed: () => _showSettings(),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: widget.result,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF81b64c), strokeWidth: 4),
                  SizedBox(height: 20),
                  Text(
                    "Analyzing your game...",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data ?? {};
          List moves = data["moves"] ?? [];
          int whiteAcc = data["whiteAccuracy"] ?? 0;
          int blackAcc = data["blackAccuracy"] ?? 0;
          String result = data["result"] ?? "1-0";
          String opening = data["opening"] ?? "Unknown Opening";

          Map<String, int> whiteStats = _calculateStats(moves, true);
          Map<String, int> blackStats = _calculateStats(moves, false);
          List<int> keyMoments = _getKeyMoments(moves);

          return Column(
            children: [
              // SCROLLABLE CONTENT
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // COACH SECTION
                      _buildCoachSection(whiteAcc, blackAcc, whiteStats, blackStats, result, opening),

                      // KEY MOMENTS TIMELINE
                      if (keyMoments.isNotEmpty)
                        _buildKeyMomentsTimeline(keyMoments, moves),

                      // ACCURACY & GRAPH SECTION
                      _buildAccuracySection(whiteAcc, blackAcc, whiteStats, blackStats, moves),

                      // MOVE LIST
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.list_alt, color: Colors.white70, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Moves",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: moves.length,
                              itemBuilder: (_, i) {
                                final m = moves[i];
                                final moveNumber = (i ~/ 2) + 1;
                                final isWhiteMove = i % 2 == 0;

                                return _buildMoveItem(
                                  m,
                                  moveNumber,
                                  isWhiteMove,
                                  i == _currentMoveIndex,
                                  keyMoments.contains(i),
                                  () => setState(() => _currentMoveIndex = i),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // Bottom padding for navigation bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // FIXED NAVIGATION BAR
              _buildNavigationBar(moves.length, keyMoments),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCoachSection(int whiteAcc, int blackAcc, Map<String, int> whiteStats, Map<String, int> blackStats, String result, String opening) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF262421),
        border: Border(
          bottom: BorderSide(color: Color(0xFF3a3a3a), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF81b64c).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emoji_objects,
                  color: Color(0xFF81b64c),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Coach Analysis",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      opening,
                      style: const TextStyle(
                        color: Color(0xFF81b64c),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getCoachSummary(whiteAcc, blackAcc, whiteStats, blackStats, result),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildEndgameTips(whiteStats, blackStats, result),
        ],
      ),
    );
  }

  Widget _buildEndgameTips(Map<String, int> whiteStats, Map<String, int> blackStats, String result) {
    final tips = _getEndgameTips(whiteStats, blackStats, result);
    if (tips.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates, color: Color(0xFF81b64c), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tips,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMomentsTimeline(List<int> keyMoments, List moves) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a1a),
        border: Border(
          bottom: BorderSide(color: Color(0xFF3a3a3a), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: Color(0xFF81b64c), size: 20),
              SizedBox(width: 8),
              Text(
                "Key Moments",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: keyMoments.length,
              itemBuilder: (_, i) {
                final moveIndex = keyMoments[i];
                final m = moves[moveIndex];
                final tag = m["tag"] ?? "";
                final moveNumber = (moveIndex ~/ 2) + 1;
                final isWhite = moveIndex % 2 == 0;
                
                return GestureDetector(
                  onTap: () => setState(() => _currentMoveIndex = moveIndex),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _getTagData(tag)["color"].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getTagData(tag)["color"].withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getTagData(tag)["icon"],
                          size: 18,
                          color: _getTagData(tag)["color"],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${isWhite ? '$moveNumber.' : '$moveNumber...'} ${m['played']}",
                          style: TextStyle(
                            color: _getTagData(tag)["color"],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildAccuracySection(int whiteAcc, int blackAcc, Map<String, int> whiteStats, Map<String, int> blackStats, List moves) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a1a),
        border: Border(
          bottom: BorderSide(color: Color(0xFF3a3a3a), width: 1),
        ),
      ),
      child: Column(
        children: [
          // ACCURACY SCORES
          Row(
            children: [
              Expanded(
                child: _buildAccuracyCard("White", whiteAcc, whiteStats, true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAccuracyCard("Black", blackAcc, blackStats, false),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // EVALUATION GRAPH
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Position Evaluation",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF262421),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: moves.isNotEmpty
                  ? CustomPaint(
                      painter: EvaluationGraphPainter(moves, _currentMoveIndex),
                      child: Container(),
                    )
                  : const Center(
                      child: Text(
                        "No moves to analyze",
                        style: TextStyle(color: Colors.white38, fontSize: 14),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyCard(String player, int accuracy, Map<String, int> stats, bool isWhite) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262421),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isWhite ? Colors.white : Colors.grey.shade800,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                player,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "$accuracy",
                style: TextStyle(
                  color: _getAccuracyColor(accuracy),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              Text(
                "%",
                style: TextStyle(
                  color: _getAccuracyColor(accuracy),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (stats["brilliant"]! > 0)
                _buildStatBadge(stats["brilliant"]!, const Color(0xFF1baca6), Icons.auto_awesome),
              if (stats["great"]! > 0)
                _buildStatBadge(stats["great"]!, const Color(0xFF5c9ece), Icons.thumb_up_alt),
              if (stats["best"]! > 0)
                _buildStatBadge(stats["best"]!, const Color(0xFF96bc4b), Icons.check_circle),
              if (stats["good"]! > 0)
                _buildStatBadge(stats["good"]!, Colors.grey, Icons.check),
              if (stats["inaccuracy"]! > 0)
                _buildStatBadge(stats["inaccuracy"]!, const Color(0xFFf0c15c), Icons.error_outline),
              if (stats["mistake"]! > 0)
                _buildStatBadge(stats["mistake"]!, const Color(0xFFe58f2a), Icons.warning),
              if (stats["blunder"]! > 0)
                _buildStatBadge(stats["blunder"]!, const Color(0xFFb33430), Icons.close),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            "$count",
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveItem(dynamic m, int moveNumber, bool isWhiteMove, bool isSelected, bool isKeyMoment, VoidCallback onTap) {
    final tag = m["tag"] ?? "Good";
    final tagData = _getTagData(tag);
    final played = m["played"] ?? "";
    final best = m["best"] ?? played;
    final eval = m["eval"] ?? 0.0;
    final cpLoss = m["cpLoss"] ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3a3a3a) : const Color(0xFF302e2b),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF81b64c) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Move number
                SizedBox(
                  width: 50,
                  child: Text(
                    isWhiteMove ? "$moveNumber." : "$moveNumber...",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Move notation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            played,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isKeyMoment)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.star,
                                size: 18,
                                color: Color(0xFF81b64c),
                              ),
                            ),
                        ],
                      ),
                      if (_showBestMoveArrows && played != best) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Color(0xFF81b64c),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              best,
                              style: const TextStyle(
                                color: Color(0xFF81b64c),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // CP Loss indicator
                if (cpLoss > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCPLossColor(cpLoss).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "-$cpLoss",
                      style: TextStyle(
                        color: _getCPLossColor(cpLoss),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                
                // Tag icon
                if (tag.toLowerCase() != "good")
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: tagData["color"].withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      tagData["icon"],
                      size: 20,
                      color: tagData["color"],
                    ),
                  ),
                
                // Eval
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getEvalColor(eval).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatEval(eval),
                    style: TextStyle(
                      color: _getEvalColor(eval),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            // Engine explanation (for errors)
            if (_showEngineLines && tag.toLowerCase() != "good" && tag.toLowerCase() != "best") ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a1a),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: tagData["color"],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _getEngineExplanation(tag, cpLoss, played, best),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // CP Loss bar visualization
            if (cpLoss > 0 && isSelected) ...[
              const SizedBox(height: 12),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (cpLoss / 300).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getCPLossColor(cpLoss),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(int totalMoves, List<int> keyMoments) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a1a),
        border: Border(
          top: BorderSide(color: Color(0xFF3a3a3a), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Key moment navigation
          if (keyMoments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _goToNextKeyMoment(keyMoments, totalMoves),
                  icon: const Icon(Icons.star, size: 20),
                  label: const Text(
                    "Next Key Moment",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF81b64c),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First move
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 32),
                color: _currentMoveIndex > 0 ? Colors.white : Colors.white30,
                onPressed: _currentMoveIndex > 0
                    ? () => setState(() => _currentMoveIndex = 0)
                    : null,
              ),
              
              // Previous
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 40),
                color: _currentMoveIndex > 0 ? Colors.white : Colors.white30,
                onPressed: _currentMoveIndex > 0
                    ? () => setState(() => _currentMoveIndex--)
                    : null,
              ),
              
              const SizedBox(width: 20),
              
              // Move counter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF262421),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${_currentMoveIndex + 1} / $totalMoves",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Next
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 40),
                color: _currentMoveIndex < totalMoves - 1 ? Colors.white : Colors.white30,
                onPressed: _currentMoveIndex < totalMoves - 1
                    ? () => setState(() => _currentMoveIndex++)
                    : null,
              ),
              
              // Last move
              IconButton(
                icon: const Icon(Icons.skip_next, size: 32),
                color: _currentMoveIndex < totalMoves - 1 ? Colors.white : Colors.white30,
                onPressed: _currentMoveIndex < totalMoves - 1
                    ? () => setState(() => _currentMoveIndex = totalMoves - 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  Map<String, int> _calculateStats(List moves, bool isWhite) {
    int brilliant = 0, great = 0, best = 0, good = 0;
    int inaccuracy = 0, mistake = 0, blunder = 0;

    for (int i = 0; i < moves.length; i++) {
      if ((i % 2 == 0) == isWhite) {
        String tag = (moves[i]["tag"] ?? "Good").toLowerCase();
        switch (tag) {
          case "brilliant": brilliant++; break;
          case "great": great++; break;
          case "best": best++; break;
          case "good": good++; break;
          case "inaccuracy": inaccuracy++; break;
          case "mistake": mistake++; break;
          case "blunder": blunder++; break;
        }
      }
    }

    return {
      "brilliant": brilliant, "great": great, "best": best,
      "good": good, "inaccuracy": inaccuracy,
      "mistake": mistake, "blunder": blunder,
    };
  }

  List<int> _getKeyMoments(List moves) {
  List<int> keyMoments = [];
  for (int i = 0; i < moves.length; i++) {
    String tag = (moves[i]["tag"] ?? "").toLowerCase();
    if ([
      "brilliant",
      "blunder",
      "mistake",
      "inaccuracy",
      "missed win",
      "missed draw",
      "missed"
    ].contains(tag)) {
      keyMoments.add(i);
    }
  }
  return keyMoments;
}


  void _goToNextKeyMoment(List<int> keyMoments, int totalMoves) {
    if (keyMoments.isEmpty) return;
    
    final nextKey = keyMoments.firstWhere(
      (k) => k > _currentMoveIndex,
      orElse: () => keyMoments[0],
    );
    setState(() => _currentMoveIndex = nextKey);
  }

  String _getCoachSummary(int whiteAcc, int blackAcc, Map<String, int> whiteStats, Map<String, int> blackStats, String result) {
    final whiteErrors = whiteStats["blunder"]! + whiteStats["mistake"]!;
    final blackErrors = blackStats["blunder"]! + blackStats["mistake"]!;
    
    if (result == "1-0") {
      if (whiteErrors == 0 && whiteAcc >= 95) {
        return "Excellent performance! You played with $whiteAcc% accuracy and made no significant errors to secure a dominant victory.";
      } else if (blackErrors > whiteErrors) {
        return "Good win! Your opponent made $blackErrors critical error${blackErrors > 1 ? 's' : ''} while you maintained $whiteAcc% accuracy.";
      } else {
        return "Solid victory with $whiteAcc% accuracy! You played consistently well throughout the game.";
      }
    } else if (result == "0-1") {
      return "You made $whiteErrors critical error${whiteErrors > 1 ? 's' : ''} that cost you the game. Review these moments to improve.";
    } else {
      return "Fair result! Both players showed similar performance ($whiteAcc% vs $blackAcc%).";
    }
  }

  String _getEndgameTips(Map<String, int> whiteStats, Map<String, int> blackStats, String result) {
    final blunders = whiteStats["blunder"]!;
    final mistakes = whiteStats["mistake"]!;
    
    if (blunders >= 2) {
      return "💡 Tip: You had $blunders blunders. Before moving, ask: Does this move hang a piece? Is my king safe?";
    } else if (mistakes >= 3) {
      return "💡 Tip: Work on tactics! $mistakes mistakes suggest missed tactical opportunities. Try puzzle training.";
    } else if (result == "1-0" && whiteStats["brilliant"]! > 0) {
      return "💡 Excellent! Your brilliant moves show strong calculation skills. Keep it up!";
    } else if (whiteStats["inaccuracy"]! >= 5) {
      return "💡 Tip: Several inaccuracies accumulated. Focus on piece activity and king safety in the opening.";
    }
    return "";
  }

  String _getEngineExplanation(String tag, int cpLoss, String played, String best) {
    switch (tag.toLowerCase()) {
      case "brilliant":
        return "Outstanding! This move is even better than the engine's top choice and creates winning chances.";
      case "great":
        return "Excellent move that maintains or increases your advantage.";
      case "inaccuracy":
        return "Small mistake. $best was slightly better (-$cpLoss cp). Consider piece activity and control.";
      case "mistake":
        return "This move loses significant advantage (-$cpLoss cp). $best would maintain pressure. Look for better piece coordination.";
      case "blunder":
        return "Critical error! This move loses ${_getBlunderSeverity(cpLoss)} (-$cpLoss cp). $best was essential. ${_getBlunderReason(played, best)}";
      case "missed":
        return "You missed a strong opportunity. $best would have given you a winning advantage.";
      default:
        return "Review this position carefully.";
    }
  }

  String _getBlunderSeverity(int cpLoss) {
    if (cpLoss > 500) return "a decisive advantage";
    if (cpLoss > 300) return "a major advantage";
    if (cpLoss > 150) return "significant material";
    return "an important advantage";
  }

  String _getBlunderReason(String played, String best) {
    return "Check for hanging pieces and tactical shots before moving.";
  }

  Color _getCPLossColor(int cpLoss) {
  if (cpLoss >= 300) return const Color(0xFFb33430); // blunder
  if (cpLoss >= 150) return const Color(0xFFe58f2a); // mistake
  if (cpLoss >= 70)  return const Color(0xFFf0c15c); // inaccuracy
  return Colors.grey; // minor
}


  Map<String, dynamic> _getTagData(String tag) {
    switch (tag.toLowerCase()) {
      case "brilliant": return {"color": const Color(0xFF1baca6), "icon": Icons.auto_awesome};
      case "great": return {"color": const Color(0xFF5c9ece), "icon": Icons.thumb_up_alt};
      case "best": return {"color": const Color(0xFF96bc4b), "icon": Icons.check_circle};
      case "good": return {"color": Colors.grey, "icon": Icons.check};
      case "inaccuracy": return {"color": const Color(0xFFf0c15c), "icon": Icons.error_outline};
      case "mistake": return {"color": const Color(0xFFe58f2a), "icon": Icons.warning};
      case "blunder": return {"color": const Color(0xFFb33430), "icon": Icons.close};
      default: return {"color": Colors.grey, "icon": Icons.check};
    }
  }

  Color _getAccuracyColor(int accuracy) {
  if (accuracy >= 95) return const Color(0xFF81b64c); // green bright
  if (accuracy >= 85) return const Color(0xFF96bc4b); // green-soft
  if (accuracy >= 75) return const Color(0xFFf0c15c); // yellow
  if (accuracy >= 65) return const Color(0xFFe58f2a); // orange
  return const Color(0xFFb33430); // red
}


  Color _getEvalColor(double eval) {
    if (eval > 2) return const Color(0xFF81b64c);
    if (eval > 0.5) return const Color(0xFF96af8b);
    if (eval > -0.5) return Colors.white70;
    if (eval > -2) return const Color(0xFFe58f2a);
    return const Color(0xFFb33430);
  }

  String _formatEval(double eval) {
    if (eval > 100) return "+M${(eval - 100).toInt()}";
    if (eval < -100) return "-M${(-eval - 100).toInt()}";
    if (eval.abs() < 0.1) return "0.0";
    return eval >= 0 ? "+${eval.toStringAsFixed(1)}" : eval.toStringAsFixed(1);
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF262421),
        title: const Text("Analysis Settings", style: TextStyle(color: Colors.white, fontSize: 18)),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text("Show Engine Lines", style: TextStyle(color: Colors.white, fontSize: 15)),
                subtitle: const Text("Display why moves are mistakes", style: TextStyle(color: Colors.white54, fontSize: 13)),
                value: _showEngineLines,
                activeColor: const Color(0xFF81b64c),
                onChanged: (val) {
                  setDialogState(() => _showEngineLines = val);
                  setState(() => _showEngineLines = val);
                },
              ),
              SwitchListTile(
                title: const Text("Show Best Move Arrows", style: TextStyle(color: Colors.white, fontSize: 15)),
                subtitle: const Text("Display alternative moves", style: TextStyle(color: Colors.white54, fontSize: 13)),
                value: _showBestMoveArrows,
                activeColor: const Color(0xFF81b64c),
                onChanged: (val) {
                  setDialogState(() => _showBestMoveArrows = val);
                  setState(() => _showBestMoveArrows = val);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Color(0xFF81b64c), fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF262421),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF81b64c), size: 24),
            SizedBox(width: 10),
            Text("Analysis Guide", style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem("Move Classifications", "Brilliant > Great > Best > Good > Inaccuracy > Mistake > Blunder"),
              const SizedBox(height: 14),
              _buildHelpItem("CP Loss", "Centipawn loss shows advantage given away. 100 cp = 1 pawn"),
              const SizedBox(height: 14),
              _buildHelpItem("Key Moments", "Critical positions where the game outcome changed"),
              const SizedBox(height: 14),
              _buildHelpItem("Engine Lines", "Shows why a move was a mistake and suggests better alternatives"),
              const SizedBox(height: 14),
              _buildHelpItem("Accuracy Score", "90%+ is excellent, 80%+ is good, below 70% needs improvement"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it!", style: TextStyle(color: Color(0xFF81b64c), fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ==================== EVALUATION GRAPH PAINTER ====================

class EvaluationGraphPainter extends CustomPainter {
  final List moves;
  final int currentMoveIndex;

  EvaluationGraphPainter(this.moves, this.currentMoveIndex);

 @override
void paint(Canvas canvas, Size size) {
  if (moves.isEmpty) return;

  // Background
  final whiteBg = Paint()..color = Colors.white.withOpacity(0.1);
  final blackBg = Paint()..color = Colors.black.withOpacity(0.15);

  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height / 2), whiteBg);
  canvas.drawRect(Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2), blackBg);

  // Center line
  final midPaint = Paint()
    ..color = Colors.white.withOpacity(0.3)
    ..strokeWidth = 1.5;
  canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), midPaint);

  // Find max eval to scale properly
  double maxEval = 1.0;
  for (var m in moves) {
    final e = (m["eval"] ?? 0).toDouble();
    if (e.abs() > maxEval) maxEval = e.abs();
  }
  maxEval = maxEval.clamp(1.0, 6.0); // avoid blown scaling

  final path = Path();
  for (int i = 0; i < moves.length; i++) {
    double eval = (moves[i]["eval"] ?? 0).toDouble();

    double x = (i / (moves.length - 1)) * size.width;

    // Correct scaling
    double normalized = (eval / maxEval).clamp(-1.0, 1.0);

    // Y axis reversed and centered
    double y = size.height / 2 - (normalized * (size.height / 2));

    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }

  final linePaint = Paint()
    ..color = const Color(0xFF81b64c)
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  canvas.drawPath(path, linePaint);

  // Highlight current move
  if (currentMoveIndex >= 0 && currentMoveIndex < moves.length) {
    double eval = (moves[currentMoveIndex]["eval"] ?? 0).toDouble();
    double normalized = (eval / maxEval).clamp(-1.0, 1.0);
    double x = (currentMoveIndex / (moves.length - 1)) * size.width;
    double y = size.height / 2 - (normalized * (size.height / 2));

    final dot = Paint()..color = const Color(0xFF81b64c);
    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(x, y), 6, dot);
    canvas.drawCircle(Offset(x, y), 6, border);
  }
}

  @override
  bool shouldRepaint(EvaluationGraphPainter oldDelegate) => 
      currentMoveIndex != oldDelegate.currentMoveIndex;
}