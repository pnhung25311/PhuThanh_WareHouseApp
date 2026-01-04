class FunctionHelper {
  String getNamesFromIdsDynamic<T>({
    required String ids, // "4,5,6"
    required List<T> list,
    required String Function(T item) getId,
    required String Function(T item) getName,
    String separator = ', ',
  }) {
    final idList = ids
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    String result = list
        .where((item) => idList.contains(getId(item)))
        .map((item) => getName(item))
        .where((name) => name.isNotEmpty)
        .join(separator);
        print(result);
    return result;
  }
}
