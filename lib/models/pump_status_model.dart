class PumpStatusModel {
  final String id;
  final String status;

  PumpStatusModel({required this.id, required this.status});

  // Factory constructor to create a PumpStatusModel from JSON
  factory PumpStatusModel.fromJson(Map<String, dynamic> json) {
    return PumpStatusModel(
      id: json['id'] as String,
      status: json['status'] as String,
    );
  }

  // Method to convert PumpStatusModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
    };
  }
}
