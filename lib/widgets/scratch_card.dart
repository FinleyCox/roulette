import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';
import 'particle_overlay.dart';
import 'dart:async';
import 'dart:io';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

/// スクラッチカードのウィジェット
class ScratchCard extends StatefulWidget {
  final VoidCallback onScratch;
  final VoidCallback onReset;
  final int index;
  final String cardTitle;
  final String completedMessage;
  final String instructionText;
  final VoidCallback? onExternalReset;
  final VoidCallback? onCardReset;

  const ScratchCard({
    super.key,
    required this.onScratch,
    required this.onReset,
    required this.index,
    required this.cardTitle,
    required this.completedMessage,
    required this.instructionText,
    this.onExternalReset,
    this.onCardReset,
  });

  @override
  State<ScratchCard> createState() => _ScratchCardState();
}

class _ScratchCardState extends State<ScratchCard> {
  final scratchKey = GlobalKey<ScratcherState>();
  bool isCompleted = false;

  // Effects
  final StreamController<Offset> _touchStreamController =
      StreamController<Offset>.broadcast();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _touchStreamController.close();
    super.dispose();
  }

  // リセット時の確認ダイアログ
  Future<void> _confirmReset() async {
    // Check if instruction text contains Japanese characters
    final isJa = RegExp(
      r'[\u3040-\u309F\u30A0-\u30FF]',
    ).hasMatch(widget.instructionText);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isJa ? 'リセット' : 'Reset'),
        content: Text(isJa ? 'カードをリセットしますか？' : 'Reset this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isJa ? 'リセット' : 'Reset',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      _resetScratcher();
    }
  }

  void _resetScratcher() {
    scratchKey.currentState?.reset();
    setState(() {
      isCompleted = false;
    });
    widget.onReset();
  }

  // 外部からリセットするためのメソッド
  void resetFromExternal() {
    scratchKey.currentState?.reset();
    setState(() {
      isCompleted = false;
    });
  }

  void _onPointerDown(PointerEvent details) {
    if (isCompleted) return;
  }

  void _onPointerMove(PointerEvent details) {
    if (isCompleted) {
      return;
    }
    // Add particle position relative to the scratch area
    _touchStreamController.add(details.localPosition);
  }

  void _onPointerUp(PointerEvent details) {
    // No-op without audio
  }

  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareResult() async {
    final image = await _screenshotController.capture();
    if (image == null) return;

    final directory = await getTemporaryDirectory();
    final imagePath = await File(
      '${directory.path}/scratch_result.png',
    ).create();
    await imagePath.writeAsBytes(image);

    // ignore: deprecated_member_use
    await Share.shareXFiles([
      XFile(imagePath.path),
    ], text: widget.completedMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cardTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.instructionText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  IconButton(
                    onPressed: _shareResult,
                    icon: const Icon(Icons.share),
                    color: Colors.blue,
                    splashRadius: 20,
                    tooltip: 'Share',
                  ),
                IconButton(
                  onPressed: _confirmReset,
                  icon: const Icon(Icons.restart_alt),
                  color: Colors.black,
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Listener(
                      onPointerDown: _onPointerDown,
                      onPointerMove: _onPointerMove,
                      onPointerUp: _onPointerUp,
                      onPointerCancel: _onPointerUp,
                      child: Scratcher(
                        key: scratchKey,
                        brushSize: 30,
                        threshold: 50,
                        color: const Color(0xFFDBD8D8),
                        onThreshold: () {
                          setState(() {
                            isCompleted = true;
                          });
                          widget.onScratch();
                        },
                        child: Container(
                          width: double.infinity,
                          height:
                              double.infinity, // Ensure full height in Expanded
                          color: const Color(0xFFF9F7F5),
                          alignment: Alignment.center,
                          child: Text(
                            widget.completedMessage,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: ScratchEffectOverlay(
                        touchStream: _touchStreamController.stream,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
