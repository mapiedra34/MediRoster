import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../services/shift_service.dart';
import '../models/shift_model.dart';

/// Add or edit shift
class AddEditShiftPage extends StatefulWidget {
  final String? shiftId;

  const AddEditShiftPage({super.key, this.shiftId});

  @override
  State<AddEditShiftPage> createState() => _AddEditShiftPageState();
}

class _AddEditShiftPageState extends State<AddEditShiftPage> {
  final _formKey = GlobalKey<FormState>();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.shiftId != null) {
      _loadShiftData();
    } else {
      _isInitialized = true;
    }
  }

  Future<void> _loadShiftData() async {
    try {
      final shift = await context.read<ShiftService>().getShiftById(widget.shiftId!);
      if (shift != null && mounted) {
        setState(() {
          // Parse date
          _selectedDate = DateFormat('yyyy-MM-dd').parse(shift.date);
          
          // Parse start time
          final startParts = shift.startTime.split(':');
          if (startParts.length == 2) {
            _startTime = TimeOfDay(
              hour: int.parse(startParts[0]),
              minute: int.parse(startParts[1]),
            );
          }
          
          // Parse end time
          final endParts = shift.endTime.split(':');
          if (endParts.length == 2) {
            _endTime = TimeOfDay(
              hour: int.parse(endParts[0]),
              minute: int.parse(endParts[1]),
            );
          }
          
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error loading shift: $e',
          backgroundColor: Colors.red,
        );
        setState(() => _isInitialized = true);
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
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final shiftService = context.read<ShiftService>();
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      final shift = ShiftModel(
        shiftId: widget.shiftId,
        date: dateStr,
        startTime: _formatTimeOfDay(_startTime),
        endTime: _formatTimeOfDay(_endTime),
      );

      if (widget.shiftId == null) {
        // Add new shift
        await shiftService.addShift(shift);
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Shift added successfully',
            backgroundColor: Colors.green,
          );
        }
      } else {
        // Update existing shift
        await shiftService.updateShift(widget.shiftId!, shift);
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Shift updated successfully',
            backgroundColor: Colors.green,
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.shiftId == null ? 'Add Shift' : 'Edit Shift'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shiftId == null ? 'Add Shift' : 'Edit Shift'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('EEEE, MMMM d, y').format(_selectedDate)),
                  leading: const Icon(Icons.calendar_today),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(_formatTimeOfDay(_startTime)),
                  leading: const Icon(Icons.access_time),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () => _selectTime(context, true),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('End Time'),
                  subtitle: Text(_formatTimeOfDay(_endTime)),
                  leading: const Icon(Icons.access_time_filled),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () => _selectTime(context, false),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(widget.shiftId == null ? 'Add Shift' : 'Update Shift'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
