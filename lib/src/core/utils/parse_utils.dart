int parseInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
