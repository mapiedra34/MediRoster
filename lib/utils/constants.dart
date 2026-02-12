/// App-wide constants
class AppConstants {
  // App Information
  static const String appName = 'MediRoster';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String casesCollection = 'cases';
  static const String shiftsCollection = 'shifts';
  static const String assignmentsCollection = 'assignments';
  static const String presenceCollection = 'presence';
  static const String operationsCollection = 'operations';
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleNurse = 'nurse';
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'EEEE, MMMM d, y';
  
  // Default Values
  static const int defaultRequiredNurses = 1;
  static const String defaultStartTime = '08:00';
  static const String defaultEndTime = '17:00';
  
  // Operations List
  static const List<String> operations = [
    'Appendectomy',
    'Gallbladder Removal',
    'Knee Replacement',
    'Hip Replacement',
    'Hernia Repair',
    'Cesarean Section',
    'Tonsillectomy',
    'Mastectomy',
    'Coronary Bypass',
    'Cataract Surgery',
  ];
  
  // Email Domain (for username to email conversion)
  static const String emailDomain = 'mediroster.app';
  
  // Error Messages
  static const String errorNoInternet = 'No internet connection';
  static const String errorGeneric = 'An error occurred. Please try again.';
  static const String errorAuth = 'Authentication failed';
  static const String errorInvalidCredentials = 'Invalid username or password';
  static const String errorEmptyFields = 'Please fill in all fields';
  
  // Success Messages
  static const String successLogin = 'Login successful!';
  static const String successLogout = 'Logged out successfully';
  static const String successCaseAdded = 'Case added successfully';
  static const String successCaseUpdated = 'Case updated successfully';
  static const String successCaseDeleted = 'Case deleted successfully';
  static const String successShiftAdded = 'Shift added successfully';
  static const String successShiftUpdated = 'Shift updated successfully';
  static const String successShiftDeleted = 'Shift deleted successfully';
  static const String successCheckIn = 'Check-in successful!';
}
