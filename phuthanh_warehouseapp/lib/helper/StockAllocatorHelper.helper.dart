import 'dart:collection';

class StockResult {
  final int co;
  final int ko;

  StockResult({required this.co, required this.ko});

  @override
  String toString() => '{co: $co, ko: $ko}';
}

class StockAllocator {
  final Map<String, Map<String, Map<String, int>>> memo = {};

  // 🔥 DFS chính
  Map<String, Map<String, int>> dfs(
    List<MapEntry<String, int>> items,
    int index,
    int remaining,
  ) {
    if (index == items.length) {
      return LinkedHashMap();
    }

    String key = '${index}_$remaining';
    if (memo.containsKey(key)) {
      return memo[key]!;
    }

    String name = items[index].key;
    int value = items[index].value;

    Map<String, Map<String, int>>? best;

    for (int co = 0; co <= (value < remaining ? value : remaining); co++) {
      int newRemaining = remaining - co;

      Map<String, Map<String, int>> sub =
          dfs(items, index + 1, newRemaining);

      Map<String, Map<String, int>> current = LinkedHashMap();

      current[name] = {
        'co': co,
        'ko': value - co,
      };

      current.addAll(sub);

      if (best == null ||
          score(current, newRemaining) > score(best, remaining)) {
        best = current;
      }
    }

    memo[key] = best!;
    return best;
  }

  // 🎯 Rule đánh giá (có thể custom)
  int score(Map<String, Map<String, int>> map, int remaining) {
    return -remaining; // càng ít dư càng tốt
  }

  // 🚀 Wrapper dùng ngoài cho gọn
  Map<String, StockResult> allocate(
    Map<String, int> input,
    int total,
  ) {
    memo.clear(); // reset cache

    final raw = dfs(input.entries.toList(), 0, total);

    return raw.map(
      (key, value) => MapEntry(
        key,
        StockResult(
          co: value['co'] ?? 0,
          ko: value['ko'] ?? 0,
        ),
      ),
    );
  }
}