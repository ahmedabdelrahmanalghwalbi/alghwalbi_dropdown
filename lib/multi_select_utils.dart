class MultiSelectUtils {
  static Map<String, Map<String, dynamic>> convertItemsToMap(
    List<Map<String, dynamic>> items,
    String primaryIdKey,
  ) {
    final map = <String, Map<String, dynamic>>{};
    for (final item in items) {
      final id = item[primaryIdKey].toString();
      map[id] = item;
    }
    return map;
  }

  static List<Map<String, dynamic>> convertMapToList(
    Map<String, Map<String, dynamic>> itemsMap,
  ) {
    return itemsMap.values.toList();
  }

  static Set<String> getSelectedIds(
    List<Map<String, dynamic>> selectedItems,
    String primaryIdKey,
  ) {
    return selectedItems.map((item) => item[primaryIdKey].toString()).toSet();
  }
}
