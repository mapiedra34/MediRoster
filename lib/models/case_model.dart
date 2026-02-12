import 'package:cloud_firestore/cloud_firestore.dart';

/// Medical case model for managing case data
class CaseModel {
  final String? caseId;
  final String description;
  final int requiredNurses;
  final String? scheduledShiftId;
  final String operation;
  final String startTime;
  final String endTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CaseModel({
    this.caseId,
    required this.description,
    this.requiredNurses = 1,
    this.scheduledShiftId,
    required this.operation,
    required this.startTime,
    required this.endTime,
    this.createdAt,
    this.updatedAt,
  });

  /// Create CaseModel from Firestore document
  factory CaseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CaseModel(
      caseId: doc.id,
      description: data['description'] as String,
      requiredNurses: data['required_nurses'] as int? ?? 1,
      scheduledShiftId: data['scheduled_shift_id'] as String?,
      operation: data['operation'] as String,
      startTime: data['start_time'] as String,
      endTime: data['end_time'] as String,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Create CaseModel from JSON
  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      caseId: json['case_id'] as String?,
      description: json['description'] as String,
      requiredNurses: json['required_nurses'] as int? ?? 1,
      scheduledShiftId: json['scheduled_shift_id'] as String?,
      operation: json['operation'] as String,
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

  /// Convert CaseModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'required_nurses': requiredNurses,
      'scheduled_shift_id': scheduledShiftId,
      'operation': operation,
      'start_time': startTime,
      'end_time': endTime,
      'created_at': createdAt != null 
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with updated fields
  CaseModel copyWith({
    String? caseId,
    String? description,
    int? requiredNurses,
    String? scheduledShiftId,
    String? operation,
    String? startTime,
    String? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CaseModel(
      caseId: caseId ?? this.caseId,
      description: description ?? this.description,
      requiredNurses: requiredNurses ?? this.requiredNurses,
      scheduledShiftId: scheduledShiftId ?? this.scheduledShiftId,
      operation: operation ?? this.operation,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
