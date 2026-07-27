/// 재료 보관 위치. DB 에는 dbValue 문자열로 저장.
enum StorageLocation {
  shelf('shelf'),
  fridge('fridge'),
  freezer('freezer');

  const StorageLocation(this.dbValue);
  final String dbValue;

  static StorageLocation? fromDb(String? value) {
    if (value == null) return null;
    for (final location in StorageLocation.values) {
      if (location.dbValue == value) return location;
    }
    return null;
  }
}
