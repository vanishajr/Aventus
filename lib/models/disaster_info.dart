class DisasterInfo {
  final String type;
  final String description;
  final List<String> safetyTips;
  final List<String> beforeDisaster;
  final List<String> duringDisaster;
  final List<String> afterDisaster;
  final Map<String, String> emergencyContacts;

  DisasterInfo({
    required this.type,
    required this.description,
    required this.safetyTips,
    required this.beforeDisaster,
    required this.duringDisaster,
    required this.afterDisaster,
    required this.emergencyContacts,
  });

  factory DisasterInfo.fromJson(Map<String, dynamic> json) {
    return DisasterInfo(
      type: json['type'],
      description: json['description'],
      safetyTips: List<String>.from(json['safety_tips']),
      beforeDisaster: List<String>.from(json['before_disaster']),
      duringDisaster: List<String>.from(json['during_disaster']),
      afterDisaster: List<String>.from(json['after_disaster']),
      emergencyContacts: Map<String, String>.from(json['emergency_contacts']),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'description': description,
    'safety_tips': safetyTips,
    'before_disaster': beforeDisaster,
    'during_disaster': duringDisaster,
    'after_disaster': afterDisaster,
    'emergency_contacts': emergencyContacts,
  };
} 