import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class StockfishService {
  Process? _process;
  StreamSubscription<String>? _stdoutSubscription;
  final StreamController<String> _outputController =
      StreamController<String>.broadcast();

  Stream<String> get output => _outputController.stream;

  Future<void> start() async {
    if (_process != null) return;

    String assetPath = '';

    if (Platform.isAndroid) {
      assetPath = 'assets/stockfish/stockfish_android';
    } else if (Platform.isIOS) {
      assetPath = 'assets/stockfish/stockfish_ios';
    } else if (Platform.isMacOS) {
      assetPath = 'assets/stockfish/stockfish_ios'; 
    }

    // Load binary from assets
    final byteData = await rootBundle.load(assetPath);

    // Write engine to temporary folder
    final tempDir = Directory.systemTemp;
    final enginePath = '${tempDir.path}/stockfish_engine';

    final engineFile = File(enginePath);
    await engineFile.writeAsBytes(
      byteData.buffer.asUint8List(),
      flush: true,
    );

    // Only Android & macOS need +x permission
    if (!Platform.isIOS) {
      try {
        await Process.run("chmod", ["+x", engineFile.path]);
      } catch (_) {}
    }

    // Start engine
    _process = await Process.start(engineFile.path, []);
    _stdoutSubscription =
        _process!.stdout.transform(SystemEncoding().decoder).listen((data) {
      _outputController.add(data);
    });

    send("uci");
  }

  void send(String command) {
    _process?.stdin.writeln(command);
  }

  Future<void> stop() async {
    await _stdoutSubscription?.cancel();
    _process?.kill();
    _process = null;
  }
}
