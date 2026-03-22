/// 汎用 Undo/Redo スタック
///
/// 状態の変更を記録し、元に戻す・やり直す操作を提供する。
/// [T] は不変（immutable）な型であること。
class UndoRedoStack<T> {
  final int maxHistory;
  final List<T> _undoStack = [];
  final List<T> _redoStack = [];
  T _current;

  UndoRedoStack(T initial, {this.maxHistory = 30}) : _current = initial;

  /// 現在の状態
  T get current => _current;

  /// Undo 可能か
  bool get canUndo => _undoStack.isNotEmpty;

  /// Redo 可能か
  bool get canRedo => _redoStack.isNotEmpty;

  /// 新しい状態を記録する
  void push(T state) {
    _undoStack.add(_current);
    if (_undoStack.length > maxHistory) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    _current = state;
  }

  /// 1つ前の状態に戻す
  T undo() {
    if (!canUndo) return _current;
    _redoStack.add(_current);
    _current = _undoStack.removeLast();
    return _current;
  }

  /// やり直す
  T redo() {
    if (!canRedo) return _current;
    _undoStack.add(_current);
    _current = _redoStack.removeLast();
    return _current;
  }
}
