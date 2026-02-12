import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/add_case_page.dart';
import 'screens/view_cases_page.dart';
import 'screens/view_case_details_page.dart';
import 'screens/my_shifts_page.dart';
import 'screens/edit_case_page.dart';
import 'screens/add_edit_shift_page.dart';
import 'screens/check_in_page.dart';
import 'services/auth_service.dart';
import 'services/case_service.dart';
import 'services/shift_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const MediRosterApp());
}

class MediRosterApp extends StatelessWidget {
  const MediRosterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<CaseService>(create: (_) => CaseService()),
        Provider<ShiftService>(create: (_) => ShiftService()),
      ],
      child: MaterialApp(
        title: 'MediRoster',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          primaryColor: const Color(0xFF018786),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.teal,
          ).copyWith(
            secondary: const Color(0xFF03DAC5),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF018786),
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF018786),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF018786), width: 2),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/add-case': (context) => const AddCasePage(),
          '/view-cases': (context) => const ViewCasesPage(),
          '/my-shifts': (context) => const MyShiftsPage(),
          '/check-in': (context) => const CheckInPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/view-case-details') {
            final caseId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ViewCaseDetailsPage(caseId: caseId),
            );
          } else if (settings.name == '/edit-case') {
            final caseId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => EditCasePage(caseId: caseId),
            );
          } else if (settings.name == '/add-edit-shift') {
            final shiftId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => AddEditShiftPage(shiftId: shiftId),
            );
          }
          return null;
        },
      ),
    );
  }
}
