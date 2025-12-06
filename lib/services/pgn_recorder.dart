class PGNRecorder {
  final List<String> moves = [];

  void addMove(String move) {
    moves.add(move);
  }

  String generatePGN() {
    int moveNumber = 1;
    String pgn = "";

    for (int i = 0; i < moves.length; i++) {
      if (i % 2 == 0) {
        pgn += "$moveNumber. ";
        moveNumber++;
      }
      pgn += "${moves[i]} ";
    }

    return pgn.trim();
  }
}
