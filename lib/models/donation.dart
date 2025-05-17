class Donation {
  final String id;
  final String disasterName;
  final double amount;
  final DateTime date;
  final String donorName;
  final String status;

  Donation({
    required this.id,
    required this.disasterName,
    required this.amount,
    required this.date,
    required this.donorName,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'disaster_name': disasterName,
    'amount': amount,
    'date': date.toIso8601String(),
    'donor_name': donorName,
    'status': status,
  };

  factory Donation.fromJson(Map<String, dynamic> json) => Donation(
    id: json['id'],
    disasterName: json['disaster_name'],
    amount: json['amount'].toDouble(),
    date: DateTime.parse(json['date']),
    donorName: json['donor_name'],
    status: json['status'],
  );
} 