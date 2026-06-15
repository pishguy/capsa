class ListDiff<T> {

  static List<int> calculate<T>(
      List<T> oldList,
      List<T> newList,
      ) {

    final changes = <int>[];

    final len = oldList.length > newList.length
        ? oldList.length
        : newList.length;

    for (int i = 0; i < len; i++) {

      if (i >= oldList.length) {
        changes.add(i);
        continue;
      }

      if (i >= newList.length) {
        changes.add(i);
        continue;
      }

      if (oldList[i] != newList[i]) {
        changes.add(i);
      }

    }

    return changes;
  }

}
