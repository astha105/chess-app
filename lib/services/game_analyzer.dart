class GameAnalyzer {
  Map<String, dynamic> analyze(List<Map<String, dynamic>> moves) {
    final white = _score(moves, true);
    final black = _score(moves, false);

    return {
      "moves": moves,
      "whiteAccuracy": white.round(),
      "blackAccuracy": black.round(),
    };
  }

  double _score(List moves, bool white) {
    double penalty = 0;
    int count = 0;

    for (int i = 0; i < moves.length; i++) {
      if ((i % 2 == 0) == white) {
        final cpl = (moves[i]["centipawnLoss"] ?? 0).toDouble();
        penalty += (cpl / 300).clamp(0, 1);
        count++;
      }
    }

    if (count == 0) return 100;
    return (100 * (1 - penalty / count)).clamp(0, 100);
  }
}
