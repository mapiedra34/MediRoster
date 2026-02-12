import 'package:cloud_firestore/cloud_firestore.dart';

/// Shift model for managing shift schedules
class ShiftModel {
  final String? shiftId;
  final String date;
  final String startTime;
  final String endTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShiftModel({
    this.shiftId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.createdAt,
    this.updatedAt,
  });

  /// Create ShiftModel from Firestore document
  factory ShiftModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShiftModel(
      shiftId: doc.id,
      date: data['date'] as String,
      startTime: data['start_time'] as String,
      endTime: data['end_time'] as String,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Create ShiftModel from JSON
  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      shiftId: json['shift_id'] as String?,
      date: json['date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      createdAt: json['created_at'] != null
          ? (json['created_at'] as Timestamp).toDate()
          : null,
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert ShiftModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with updated fields
  ShiftModel copyWith({
    String? shiftId,
    String? date,
    String? startTime,
    String? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShiftModel(
      shiftId: shiftId ?? this.shiftId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
