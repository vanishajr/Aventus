class SupplyReport {
  final DateTime timestamp;
  final int numberOfPeople;
  final Map<String, Map<String, dynamic>> supplies;
  final String nextShipmentDue;
  final String mostUrgent;
  final String mostUrgentStatus;

  SupplyReport({
    required this.timestamp,
    required this.numberOfPeople,
    required this.supplies,
    required this.nextShipmentDue,
    required this.mostUrgent,
    required this.mostUrgentStatus,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'numberOfPeople': numberOfPeople,
    'supplies': supplies,
    'nextShipmentDue': nextShipmentDue,
    'mostUrgent': mostUrgent,
    'mostUrgentStatus': mostUrgentStatus,
  };

  factory SupplyReport.fromJson(Map<String, dynamic> json) => SupplyReport(
    timestamp: DateTime.parse(json['timestamp']),
    numberOfPeople: json['numberOfPeople'],
    supplies: Map<String, Map<String, dynamic>>.from(json['supplies']),
    nextShipmentDue: json['nextShipmentDue'],
    mostUrgent: json['mostUrgent'],
    mostUrgentStatus: json['mostUrgentStatus'],
  );
} 