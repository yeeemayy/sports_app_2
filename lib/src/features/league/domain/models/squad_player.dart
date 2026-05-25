// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'squad_player.freezed.dart';
part 'squad_player.g.dart';

@freezed
class SquadPlayer with _$SquadPlayer {
  const factory SquadPlayer({
    required String id,
    required String name,
    @JsonKey(name: 'short_name') String? shortName,
    String? logo,
    @JsonKey(name: 'national_logo') String? nationalLogo,
    String? position,
    int? age,
    int? height,
    int? weight,
    String? nationality,
    @JsonKey(name: 'shirt_number') int? shirtNumber,
    @JsonKey(name: 'cn_name') String? cnName,
  }) = _SquadPlayer;

  factory SquadPlayer.fromJson(Map<String, dynamic> json) =>
      _$SquadPlayerFromJson(json);
}
