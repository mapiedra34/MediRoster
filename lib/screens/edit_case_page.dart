import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/case_service.dart';
import '../services/shift_service.dart';
import '../models/case_model.dart';
import '../models/shift_model.dart';

/// Edit existing case
class EditCasePage extends StatefulWidget {
  final String caseId;

  const EditCasePage({super.key, required this.caseId});

  @override
  State<EditCasePage> createState() => _EditCasePageState();
}

class _EditCasePageState extends State<EditCasePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _requiredNursesController = TextEditingController();
  
  String? _selectedOperation;
  String? _selectedShiftId;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;
  bool _isInitialized = false;

  final List<String> _operations = [
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

  @override
  void dispose() {
    _descriptionController.dispose();
    _requiredNursesController.dispose();
    super.dispose();
  }

  Future<void> _loadCaseData() async {
    if (_isInitialized) return;

    try {
      final caseData = await context.read<CaseService>().getCaseById(widget.caseId);
      if (caseData != null && mounted) {
        setState(() {
          _descriptionController.text = caseData.description;
          _requiredNursesController.text = caseData.requiredNurses.toString();
          _selectedOperation = caseData.operation;
          _selectedShiftId = caseData.scheduledShiftId;
          
          // Parse start time
          final startParts = caseData.startTime.split(':');
          if (startParts.length == 2) {
            _startTime = TimeOfDay(
              hour: int.parse(startParts[0]),
              minute: int.parse(startParts[1]),
            );
          }
          
          // Parse end time
          final endParts = caseData.endTime.split(':');
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
          msg: 'Error loading case: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime 
          ? (_startTime ?? const TimeOfDay(hour: 8, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 17, minute: 0)),
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

    if (_selectedOperation == null) {
      Fluttertoast.showToast(msg: 'Please select an operation');
      return;
    }

    if (_selectedShiftId == null) {
      Fluttertoast.showToast(msg: 'Please select a shift');
      return;
    }

    if (_startTime == null || _endTime == null) {
      Fluttertoast.showToast(msg: 'Please select start and end times');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final caseService = context.read<CaseService>();
      
      final updatedCase = CaseModel(
        caseId: widget.caseId,
        description: _descriptionController.text.trim(),
        requiredNurses: int.tryParse(_requiredNursesController.text) ?? 1,
        scheduledShiftId: _selectedShiftId,
        operation: _selectedOperation!,
        startTime: _formatTimeOfDay(_startTime!),
        endTime: _formatTimeOfDay(_endTime!),
      );

      await caseService.updateCase(widget.caseId, updatedCase);

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Case updated successfully',
          backgroundColor: Colors.green,
        );
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
      _loadCaseData();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Case'),
      ),
      body: _isInitialized
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Operation',
                        prefixIcon: Icon(Icons.medical_services),
                      ),
                      value: _selectedOperation,
                      items: _operations.map((operation) {
                        return DropdownMenuItem(
                          value: operation,
                          child: Text(operation),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedOperation = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an operation';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _requiredNursesController,
                      decoration: const InputDecoration(
                        labelText: 'Required Nurses',
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of nurses';
                        }
                        if (int.tryParse(value) == null || int.parse(value) < 1) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<ShiftModel>>(
                      stream: context.read<ShiftService>().getShiftsStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final shifts = snapshot.data ?? [];
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Shift',
                            prefixIcon: Icon(Icons.schedule),
                          ),
                          value: _selectedShiftId,
                          items: shifts.map((shift) {
                            return DropdownMenuItem(
                              value: shift.shiftId,
                              child: Text('${shift.date} (${shift.startTime} - ${shift.endTime})'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedShiftId = value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a shift';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Start Time'),
                            subtitle: Text(_startTime != null 
                                ? _formatTimeOfDay(_startTime!)
                                : 'Not set'),
                            leading: const Icon(Icons.access_time),
                            onTap: () => _selectTime(context, true),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ListTile(
                            title: const Text('End Time'),
                            subtitle: Text(_endTime != null
                                ? _formatTimeOfDay(_endTime!)
                                : 'Not set'),
                            leading: const Icon(Icons.access_time),
                            onTap: () => _selectTime(context, false),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                      ],
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
                            : const Text('Update Case'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
