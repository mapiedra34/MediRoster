import 'package:flutter_test/flutter_test.dart';
import 'package:mediroster/models/shift_model.dart';

void main() {
  group('ShiftModel', () {
    test('should create ShiftModel from JSON', () {
      // Arrange
      final json = {
        'shift_id': 'shift123',
        'date': '2024-02-15',
        'start_time': '08:00',
        'end_time': '17:00',
      };

      // Act
      final shiftModel = ShiftModel.fromJson(json);

      // Assert
      expect(shiftModel.shiftId, 'shift123');
      expect(shiftModel.date, '2024-02-15');
      expect(shiftModel.startTime, '08:00');
      expect(shiftModel.endTime, '17:00');
    });

    test('should convert ShiftModel to JSON', () {
      // Arrange
      final shiftModel = ShiftModel(
        shiftId: 'shift123',
        date: '2024-02-15',
        startTime: '08:00',
        endTime: '17:00',
      );

      // Act
      final json = shiftModel.toJson();

      // Assert
      expect(json['date'], '2024-02-15');
      expect(json['start_time'], '08:00');
      expect(json['end_time'], '17:00');
    });

    test('should create copy with updated fields', () {
      // Arrange
      final original = ShiftModel(
        shiftId: 'shift123',
        date: '2024-02-15',
        startTime: '08:00',
        endTime: '17:00',
      );

      // Act
      final updated = original.copyWith(
        date: '2024-02-16',
        startTime: '09:00',
      );

      // Assert
      expect(updated.shiftId, 'shift123');
      expect(updated.date, '2024-02-16');
      expect(updated.startTime, '09:00');
      expect(updated.endTime, '17:00');
    });
  });
}
