class DiffOperation<T> {
  final String type;
  final int from;
  final int to;
  final T item;

  DiffOperation(this.type, this.from, this.to, this.item);
}

List<DiffOperation<T>> keyedDiff<T, K>(
    List<T> oldList,
    List<T> newList,
    K Function(T) keyOf,
    ) {
  final ops = <DiffOperation<T>>[];

  final oldKeyIndex = <K, int>{};

  for (int i = 0; i < oldList.length; i++) {
    oldKeyIndex[keyOf(oldList[i])] = i;
  }

  final usedOld = <int>{};

  for (int newIndex = 0; newIndex < newList.length; newIndex++) {
    final item = newList[newIndex];

    final key = keyOf(item);

    final oldIndex = oldKeyIndex[key];

    if (oldIndex == null) {
      ops.add(DiffOperation("insert", -1, newIndex, item));
      continue;
    }

    usedOld.add(oldIndex);

    if (oldIndex != newIndex) {
      ops.add(DiffOperation("move", oldIndex, newIndex, item));
    }
  }

  for (int oldIndex = 0; oldIndex < oldList.length; oldIndex++) {
    if (!usedOld.contains(oldIndex)) {
      ops.add(DiffOperation("remove", oldIndex, -1, oldList[oldIndex]));
    }
  }

  return ops;
}
