import 'package:cloud_firestore/cloud_firestore.dart';

enum FavouriteType { team, league }

class FavouriteEntry {
  const FavouriteEntry({
    required this.id,
    required this.sport,
    required this.name,
    this.cnName,
    this.logoUrl,
    required this.addedAt,
  });

  final String id;
  final String sport; // LeagueSport.apiPath value
  final String name;
  final String? cnName;
  final String? logoUrl;
  final DateTime addedAt;

  factory FavouriteEntry.fromMap(String docId, Map<String, dynamic> map) {
    final ts = map['addedAt'];
    return FavouriteEntry(
      id: map['id'] as String? ?? docId.split(':').last,
      sport: map['sport'] as String? ?? '',
      name: map['name'] as String? ?? '',
      cnName: map['cnName'] as String?,
      logoUrl: map['logoUrl'] as String?,
      addedAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}
