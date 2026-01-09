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

class _GameReviewScreenState extends State<GameReviewScreen> 
    with SingleTickerProviderStateMixin {
  int? selectedMoveIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(),
          
          // Main content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom App Bar
                _buildSliverAppBar(),
                
                // Hero Accuracy Section
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildHeroAccuracySection(
                        whiteAccuracy,
                        blackAccuracy,
                      ),
                    ),
                  ),
                ),

                // Quick Stats Cards
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildQuickStatsCards(moves, whiteStats, blackStats),
                  ),
                ),

                // Evaluation Graph
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildEvaluationGraph(moves),
                  ),
                ),

                // Detailed Stats
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildDetailedStats(
                      whiteStats,
                      blackStats,
                      whiteAvgCPL,
                      blackAvgCPL,
                    ),
                  ),
                ),

                // Moves List Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Move by Move Analysis",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Moves List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: _buildMoveCard(moves[index], index),
                              ),
                            );
                          },
                        );
                      },
                      childCount: moves.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0E27),
            Color(0xFF1A1F3A),
            Color(0xFF0A0E27),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0E27).withOpacity(0.95),
              const Color(0xFF0A0E27).withOpacity(0.85),
            ],
          ),
          border: const Border(
            bottom: BorderSide(
              color: Color(0xFF6366F1),
              width: 1,
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Game Analysis",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.download_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {
            final moves = List<Map<String, dynamic>>.from(
                widget.analysisResult["moves"] ?? []);
            PGNExporter.showExportDialog(context, moves);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroAccuracySection(int whiteAcc, int blackAcc) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.15),
            const Color(0xFF8B5CF6).withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      "PERFORMANCE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildAccuracyCircle("White", whiteAcc, true)),
              Container(
                width: 2,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
              Expanded(child: _buildAccuracyCircle("Black", blackAcc, false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyCircle(String player, int accuracy, bool isWhite) {
    final color = _getAccuracyGradient(accuracy);
    
    return Column(
      children: [
        Text(
          player.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color[0].withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Progress circle
            SizedBox(
              width: 100,
              height: 100,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(begin: 0.0, end: accuracy / 100),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return CustomPaint(
                    painter: AccuracyCirclePainter(
                      progress: value,
                      colors: color,
                    ),
                  );
                },
              ),
            ),
            // Center text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: color,
                  ).createShader(bounds),
                  child: Text(
                    "$accuracy%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                Text(
                  _getAccuracyLabel(accuracy),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatsCards(
    List<Map<String, dynamic>> moves,
    Map<String, int> whiteStats,
    Map<String, int> blackStats,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.format_list_numbered_rounded,
              label: "MOVES",
              value: "${moves.length}",
              gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.warning_rounded,
              label: "BLUNDERS",
              value: "${(whiteStats['Blunder'] ?? 0) + (blackStats['Blunder'] ?? 0)}",
              gradient: [const Color(0xFFEF4444), const Color(0xFFDC2626)],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.stars_rounded,
              label: "BEST",
              value: "${(whiteStats['Best'] ?? 0) + (blackStats['Best'] ?? 0)}",
              gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient[0].withOpacity(0.15),
            gradient[1].withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient[0].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationGraph(List<Map<String, dynamic>> moves) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Evaluation",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  "${moves.length} moves",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: ModernEvaluationGraphPainter(moves, selectedMoveIndex),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(
    Map<String, int> whiteStats,
    Map<String, int> blackStats,
    double whiteAvgCPL,
    double blackAvgCPL,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Detailed Statistics",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildStatsColumn("WHITE", whiteStats, whiteAvgCPL),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildStatsColumn("BLACK", blackStats, blackAvgCPL),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsColumn(
    String label,
    Map<String, int> stats,
    double avgCPL,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildStatRow("Best", stats["Best"] ?? 0, const Color(0xFF10B981)),
        _buildStatRow("Excellent", stats["Excellent"] ?? 0, const Color(0xFF34D399)),
        _buildStatRow("Good", stats["Good"] ?? 0, const Color(0xFF6EE7B7)),
        _buildStatRow("Inaccuracy", stats["Inaccuracy"] ?? 0, const Color(0xFFF59E0B)),
        _buildStatRow("Mistake", stats["Mistake"] ?? 0, const Color(0xFFF97316)),
        _buildStatRow("Blunder", stats["Blunder"] ?? 0, const Color(0xFFEF4444)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Avg CPL",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                avgCPL.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              "$count",
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
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

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMoveIndex = isSelected ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tagColor.withOpacity(0.15),
                    tagColor.withOpacity(0.05),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? tagColor : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tagColor.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isWhite ? "$moveNumber." : "$moveNumber...",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [tagColor, tagColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: tagColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getEvalColor(eval).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PLAYED",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        played,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (played != best) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white.withOpacity(0.3),
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "BEST",
                          style: TextStyle(
                            color: const Color(0xFF10B981).withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          best,
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (cpl > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: tagColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_down_rounded,
                      color: tagColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Centipawn loss:",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$cpl",
                      style: TextStyle(
                        color: tagColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
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

  // Helper methods
  List<Color> _getAccuracyGradient(int accuracy) {
    if (accuracy >= 95) return [const Color(0xFF10B981), const Color(0xFF059669)];
    if (accuracy >= 90) return [const Color(0xFF34D399), const Color(0xFF10B981)];
    if (accuracy >= 80) return [const Color(0xFF6EE7B7), const Color(0xFF34D399)];
    if (accuracy >= 70) return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
    if (accuracy >= 60) return [const Color(0xFFF97316), const Color(0xFFEA580C)];
    return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
  }

  String _getAccuracyLabel(int accuracy) {
    if (accuracy >= 95) return "BRILLIANT";
    if (accuracy >= 90) return "EXCELLENT";
    if (accuracy >= 80) return "GOOD";
    if (accuracy >= 70) return "DECENT";
    if (accuracy >= 60) return "WEAK";
    return "POOR";
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case "Best":
        return const Color(0xFF10B981);
      case "Excellent":
        return const Color(0xFF34D399);
      case "Good":
        return const Color(0xFF6EE7B7);
      case "Inaccuracy":
        return const Color(0xFFF59E0B);
      case "Mistake":
        return const Color(0xFFF97316);
      case "Blunder":
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _formatEval(double eval) {
    if (eval.abs() > 100) return eval > 0 ? "+M" : "-M";
    if (eval.abs() < 0.1) return "0.0";
    return "${eval > 0 ? '+' : ''}${eval.toStringAsFixed(1)}";
  }

  Color _getEvalColor(double eval) {
    if (eval > 3) return const Color(0xFF10B981);
    if (eval > 1) return const Color(0xFF34D399);
    if (eval > -1) return Colors.white70;
    if (eval > -3) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
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

  Map<String, int> _getMoveStats(List<Map<String, dynamic>> moves, bool isWhite) {
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
}

// Custom painter for accuracy circle
class AccuracyCirclePainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  AccuracyCirclePainter({
    required this.progress,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(colors: colors).createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Modern evaluation graph painter
class ModernEvaluationGraphPainter extends CustomPainter {
  final List<Map<String, dynamic>> moves;
  final int? selectedMoveIndex;

  ModernEvaluationGraphPainter(this.moves, this.selectedMoveIndex);

  @override
  void paint(Canvas canvas, Size size) {
    if (moves.isEmpty) return;

    // Background
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.3);
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      double y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Center line (enhanced)
    final centerLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
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

    // Draw gradient fill
    if (points.length >= 2) {
      final path = Path();
      path.moveTo(points.first.dx, size.height / 2);
      path.lineTo(points.first.dx, points.first.dy);
      
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      
      path.lineTo(points.last.dx, size.height / 2);
      path.close();

      final gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF10B981).withOpacity(0.3),
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFFEF4444).withOpacity(0.1),
            const Color(0xFFEF4444).withOpacity(0.3),
          ],
          stops: const [0.0, 0.45, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(path, gradientPaint);
    }

    // Draw line with gradient
    if (points.length >= 2) {
      final linePaint = Paint()
        ..shader = LinearGradient(
          colors: const [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // Draw mistake markers
    for (int i = 0; i < moves.length; i++) {
      String tag = moves[i]["tag"] ?? "Good";
      if (tag == "Inaccuracy" || tag == "Mistake" || tag == "Blunder") {
        Color markerColor = _getMarkerColor(tag);

        // Glow
        canvas.drawCircle(
          points[i],
          10,
          Paint()
            ..color = markerColor.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );

        // Marker
        canvas.drawCircle(
          points[i],
          6,
          Paint()..color = markerColor,
        );

        canvas.drawCircle(
          points[i],
          6,
          Paint()
            ..color = Colors.white
            ..strokeWidth = 2
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
        ..color = const Color(0xFF6366F1).withOpacity(0.5)
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(selectedPoint.dx, 0),
        Offset(selectedPoint.dx, size.height),
        verticalPaint,
      );

      // Glow
      canvas.drawCircle(
        selectedPoint,
        16,
        Paint()
          ..color = const Color(0xFF6366F1).withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );

      canvas.drawCircle(
        selectedPoint,
        10,
        Paint()..color = const Color(0xFF6366F1),
      );

      canvas.drawCircle(
        selectedPoint,
        10,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );
    }
  }

  Color _getMarkerColor(String tag) {
    switch (tag) {
      case "Inaccuracy":
        return const Color(0xFFF59E0B);
      case "Mistake":
        return const Color(0xFFF97316);
      case "Blunder":
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}