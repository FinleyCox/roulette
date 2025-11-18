import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';

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
    return Container(
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
              IconButton(
                onPressed: _resetScratcher,
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
          ),
        ],
      ),
    );
  }
}
