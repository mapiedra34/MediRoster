import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../services/shift_service.dart';

/// Check-in page for nurses
class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  bool _isLoading = false;
  String _username = '';
  DateTime _selectedDate = DateTime.now();
  List<String> _presentNurses = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _username = args['username'] ?? '';
    }
    _loadPresentNurses();
  }

  Future<void> _loadPresentNurses() async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final nurses = await context.read<ShiftService>().getPresentNurses(dateStr);
      if (mounted) {
        setState(() => _presentNurses = nurses);
      }
    } catch (e) {
      // Ignore errors on initial load
    }
  }

  Future<void> _handleCheckIn() async {
    if (_username.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Username not available',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final shiftService = context.read<ShiftService>();
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      await shiftService.markPresent(_username, dateStr);

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Check-in successful!',
          backgroundColor: Colors.green,
        );
        _loadPresentNurses();
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error: $e',
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadPresentNurses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCheckedIn = _presentNurses.contains(_username);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Color(0xFF018786),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Daily Check-In',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mark your attendance for today',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('EEEE, MMMM d, y').format(_selectedDate)),
                leading: const Icon(Icons.calendar_today),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (_isLoading || isCheckedIn) ? null : _handleCheckIn,
                icon: Icon(isCheckedIn ? Icons.check_circle : Icons.login),
                label: Text(
                  isCheckedIn ? 'Already Checked In' : 'Check In Now',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCheckedIn ? Colors.green : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, color: Color(0xFF018786)),
                        const SizedBox(width: 8),
                        const Text(
                          'Present Today',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Chip(
                          label: Text('${_presentNurses.length}'),
                          backgroundColor: const Color(0xFF03DAC5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_presentNurses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No one checked in yet',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    else
                      ...(_presentNurses.map((nurse) {
                        final isCurrentUser = nurse == _username;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isCurrentUser 
                                ? Colors.green 
                                : const Color(0xFF018786),
                            child: Text(
                              nurse[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            nurse,
                            style: TextStyle(
                              fontWeight: isCurrentUser 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isCurrentUser
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                        );
                      }).toList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
