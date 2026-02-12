import 'package:flutter_test/flutter_test.dart';
import 'package:mediroster/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create UserModel from JSON', () {
      // Arrange
      final json = {
        'username': 'nurse1',
        'role': 'nurse',
        'display_name': 'Nurse One',
        'email': 'nurse1@mediroster.app',
      };

      // Act
      final userModel = UserModel.fromJson(json);

      // Assert
      expect(userModel.username, 'nurse1');
      expect(userModel.role, 'nurse');
      expect(userModel.displayName, 'Nurse One');
      expect(userModel.email, 'nurse1@mediroster.app');
    });

    test('should convert UserModel to JSON', () {
      // Arrange
      final userModel = UserModel(
        username: 'admin1',
        role: 'admin',
        displayName: 'Admin One',
        email: 'admin1@mediroster.app',
      );

      // Act
      final json = userModel.toJson();

      // Assert
      expect(json['username'], 'admin1');
      expect(json['role'], 'admin');
      expect(json['display_name'], 'Admin One');
      expect(json['email'], 'admin1@mediroster.app');
    });

    test('should correctly identify admin role', () {
      // Arrange
      final admin = UserModel(
        username: 'admin1',
        role: 'admin',
        displayName: 'Admin',
      );
      final nurse = UserModel(
        username: 'nurse1',
        role: 'nurse',
        displayName: 'Nurse',
      );

      // Assert
      expect(admin.isAdmin, true);
      expect(admin.isNurse, false);
      expect(nurse.isAdmin, false);
      expect(nurse.isNurse, true);
    });
  });
}
