/// スクラッチの状態を管理するクラス
class ScratchState {
  /// 現在のスクラッチ回数
  int currentCount;

  /// 最大スクラッチ回数
  final int maxCount;

  /// スクラッチが完了したかどうか
  bool isCompleted;

  ScratchState({
    this.currentCount = 0,
    this.maxCount = 4,
    this.isCompleted = false,
  });

  /// スクラッチ回数を増やす
  void increment() {
    if (currentCount < maxCount) {
      currentCount++;
      if (currentCount >= maxCount) {
        isCompleted = true;
      }
    }
  }

  /// スクラッチ回数をリセット
  void reset() {
    currentCount = 0;
    isCompleted = false;
  }
}
