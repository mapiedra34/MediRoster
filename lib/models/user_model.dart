/// User model for authentication and user data
class UserModel {
  final String username;
  final String role;
  final String displayName;
  final String? email;

  UserModel({
    required this.username,
    required this.role,
    required this.displayName,
    this.email,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] as String,
      role: json['role'] as String,
      displayName: json['display_name'] as String,
      email: json['email'] as String?,
    );
  }

  /// Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'role': role,
      'display_name': displayName,
      'email': email,
    };
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user is nurse
  bool get isNurse => role == 'nurse';
}
