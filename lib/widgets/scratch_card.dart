import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';

/// スクラッチカードのウィジェット
class ScratchCard extends StatefulWidget {
  final VoidCallback onScratch;
  final VoidCallback onReset;
  final int index;
  final String cardTitle;
  final String completedMessage;
  final VoidCallback? onExternalReset;
  final VoidCallback? onCardReset;

  const ScratchCard({
    super.key,
    required this.onScratch,
    required this.onReset,
    required this.index,
    required this.cardTitle,
    required this.completedMessage,
    this.onExternalReset,
    this.onCardReset,
  });

  @override
  State<ScratchCard> createState() => _ScratchCardState();
}

class _ScratchCardState extends State<ScratchCard> {
  final scratchKey = GlobalKey<ScratcherState>();
  bool isCompleted = false;

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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          // カード番号表示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Text(
                    widget.cardTitle,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(child: Container()),
                  IconButton(
                    onPressed: _resetScratcher,
                    icon: const Icon(Icons.undo),
                    color: Colors.black,
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),
            ),
          ),

          // スクラッチエリア
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Scratcher(
                  key: scratchKey,
                  brushSize: 30,
                  threshold: 50,
                  color: const Color.fromARGB(255, 219, 216, 216),
                  onThreshold: () {
                    setState(() {
                      isCompleted = true;
                    });
                    widget.onScratch();
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        widget.completedMessage,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
