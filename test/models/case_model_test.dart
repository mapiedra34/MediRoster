import 'package:flutter_test/flutter_test.dart';
import 'package:mediroster/models/case_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('CaseModel', () {
    test('should create CaseModel from JSON', () {
      // Arrange
      final json = {
        'description': 'Emergency surgery',
        'required_nurses': 2,
        'scheduled_shift_id': 'shift123',
        'operation': 'Appendectomy',
        'start_time': '08:00',
        'end_time': '10:00',
      };

      // Act
      final caseModel = CaseModel.fromJson(json);

      // Assert
      expect(caseModel.description, 'Emergency surgery');
      expect(caseModel.requiredNurses, 2);
      expect(caseModel.scheduledShiftId, 'shift123');
      expect(caseModel.operation, 'Appendectomy');
      expect(caseModel.startTime, '08:00');
      expect(caseModel.endTime, '10:00');
    });

    test('should convert CaseModel to JSON', () {
      // Arrange
      final caseModel = CaseModel(
        description: 'Emergency surgery',
        requiredNurses: 2,
        scheduledShiftId: 'shift123',
        operation: 'Appendectomy',
        startTime: '08:00',
        endTime: '10:00',
      );

      // Act
      final json = caseModel.toJson();

      // Assert
      expect(json['description'], 'Emergency surgery');
      expect(json['required_nurses'], 2);
      expect(json['scheduled_shift_id'], 'shift123');
      expect(json['operation'], 'Appendectomy');
      expect(json['start_time'], '08:00');
      expect(json['end_time'], '10:00');
    });

    test('should use default value for required_nurses', () {
      // Arrange
      final json = {
        'description': 'Test case',
        'operation': 'Surgery',
        'start_time': '08:00',
        'end_time': '10:00',
      };

      // Act
      final caseModel = CaseModel.fromJson(json);

      // Assert
      expect(caseModel.requiredNurses, 1);
    });

    test('should create copy with updated fields', () {
      // Arrange
      final original = CaseModel(
        caseId: 'case123',
        description: 'Original',
        operation: 'Surgery',
        startTime: '08:00',
        endTime: '10:00',
      );

      // Act
      final updated = original.copyWith(
        description: 'Updated',
        requiredNurses: 3,
      );

      // Assert
      expect(updated.caseId, 'case123');
      expect(updated.description, 'Updated');
      expect(updated.requiredNurses, 3);
      expect(updated.operation, 'Surgery');
      expect(updated.startTime, '08:00');
    });
  });
}
