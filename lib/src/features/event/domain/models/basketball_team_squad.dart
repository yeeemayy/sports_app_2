import 'package:flutter/foundation.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';

@immutable
class BasketballPlayer {
  const BasketballPlayer({
    required this.id,
    required this.name,
    required this.cnName,
    required this.logo,
    required this.shirtNumber,
    required this.position,
    required this.height,
    required this.weight,
    required this.age,
  });

  final String id;
  final String name;
  final String cnName;
  final String logo;
  final int shirtNumber;
  final String position;
  final int height;
  final int weight;
  final int age;

  String get displayName =>
      SportMatch.teamName({'en_name': name, 'cn_name': cnName});

  factory BasketballPlayer.fromJson(Map<String, dynamic> json) {
    return BasketballPlayer(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      cnName: json['cn_name'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
      shirtNumber: json['shirt_number'] as int? ?? 0,
      position: json['position'] as String? ?? '',
      height: json['height'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
      age: json['age'] as int? ?? 0,
    );
  }
}
