/// Common interface for all sport-specific realtime data models.
/// Allows the generic [SportRealtime] family provider to work with any sport.
abstract interface class SportRealtimeData {
  String get id;
  int get statusId;
}
