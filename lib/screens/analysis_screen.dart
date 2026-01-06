// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AnalysisScreen extends StatefulWidget {
  final Map<String, dynamic> analysisResult;

  const AnalysisScreen({
    super.key,
    required this.analysisResult,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  Widget build(BuildContext context) {
    final moves =
        List<Map<String, dynamic>>.from(widget.analysisResult["moves"] ?? []);
    final whiteAccuracy = widget.analysisResult["whiteAccuracy"] ?? 0;
    final blackAccuracy = widget.analysisResult["blackAccuracy"] ?? 0;

    final stats = _calculateStatistics(moves);

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF262421),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Game Review"),
        centerTitle: true,
      ),
      body: moves.isEmpty
          ? const Center(
              child: Text(
                "No moves to analyze",
                style: TextStyle(color: Colors.white54),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _accuracy(whiteAccuracy, blackAccuracy),
                  const SizedBox(height: 16),
                  _stats(stats),
                  const SizedBox(height: 16),
                  _moves(moves),
                ],
              ),
            ),
    );
  }

  // ================= LOGIC =================

  Map<String, dynamic> _calculateStatistics(List<Map<String, dynamic>> moves) {
    int wB = 0, wG = 0, wI = 0, wM = 0, wBl = 0;
    int bB = 0, bG = 0, bI = 0, bM = 0, bBl = 0;
    double wCpl = 0, bCpl = 0;
    int wc = 0, bc = 0;

    for (int i = 0; i < moves.length; i++) {
      final tag = moves[i]["tag"] ?? "Good";
      final cpl = (moves[i]["centipawnLoss"] ?? 0).toDouble();
      final isWhite = i % 2 == 0;

      if (isWhite) {
        wCpl += cpl;
        wc++;
        if (tag == "Brilliant") wB++;
        if (tag == "Good") wG++;
        if (tag == "Inaccuracy") wI++;
        if (tag == "Mistake") wM++;
        if (tag == "Blunder") wBl++;
      } else {
        bCpl += cpl;
        bc++;
        if (tag == "Brilliant") bB++;
        if (tag == "Good") bG++;
        if (tag == "Inaccuracy") bI++;
        if (tag == "Mistake") bM++;
        if (tag == "Blunder") bBl++;
      }
    }

    return {
      "white": {
        "brilliant": wB,
        "good": wG,
        "inaccuracy": wI,
        "mistake": wM,
        "blunder": wBl,
        "avgCPL": wc == 0 ? 0 : wCpl / wc,
      },
      "black": {
        "brilliant": bB,
        "good": bG,
        "inaccuracy": bI,
        "mistake": bM,
        "blunder": bBl,
        "avgCPL": bc == 0 ? 0 : bCpl / bc,
      },
    };
  }

  // ================= UI (UNCHANGED STYLE) =================

  Widget _accuracy(int w, int b) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: _box("White", w)),
            const SizedBox(width: 16),
            Expanded(child: _box("Black", b)),
          ],
        ),
      );

  Widget _box(String t, int v) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF262421),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(t, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Text("$v%",
                style: const TextStyle(
                    fontSize: 36, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _stats(Map s) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(child: _player("White", s["white"])),
            const SizedBox(width: 16),
            Expanded(child: _player("Black", s["black"])),
          ],
        ),
      );

  Widget _player(String t, Map s) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF262421),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.toUpperCase(),
                style:
                    const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            Text("Brilliant: ${s["brilliant"]}"),
            Text("Good: ${s["good"]}"),
            Text("Inaccuracy: ${s["inaccuracy"]}"),
            Text("Mistake: ${s["mistake"]}"),
            Text("Blunder: ${s["blunder"]}"),
            const Divider(),
            Text("Avg CPL: ${s["avgCPL"].toStringAsFixed(1)}"),
          ],
        ),
      );

  Widget _moves(List<Map<String, dynamic>> moves) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: moves.length,
        itemBuilder: (_, i) {
          final m = moves[i];
          final tag = m["tag"] ?? "Good";
          Color tagColor = Colors.white54;
          
          if (tag == "Best" || tag == "Excellent") tagColor = Colors.green;
          if (tag == "Good") tagColor = Colors.blue;
          if (tag == "Inaccuracy") tagColor = Colors.orange;
          if (tag == "Mistake") tagColor = Colors.deepOrange;
          if (tag == "Blunder") tagColor = Colors.red;
          
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: tagColor, width: 1),
              ),
              child: Text(
                tag,
                style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              "Played: ${m["played"]}  →  Best: ${m["best"]}",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            subtitle: Text(
              "CPL: ${m["centipawnLoss"]} | Eval: ${m["eval"]}",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          );
        },
      );
}