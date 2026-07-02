/// Parses any JSON value (int, numeric string, "-", null) to a nullable int.
int? nullableIntFromJson(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

dynamic nullableIntToJson(int? value) => value;
