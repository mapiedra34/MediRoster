import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shift_model.dart';

/// Service for managing shifts in Firestore
class ShiftService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'shifts';

  /// Get all shifts as a stream
  Stream<List<ShiftModel>> getShiftsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ShiftModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get all shifts
  Future<List<ShiftModel>> getAllShifts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('date')
          .get();
      return snapshot.docs
          .map((doc) => ShiftModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get shifts: $e');
    }
  }

  /// Get shift by ID
  Future<ShiftModel?> getShiftById(String shiftId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(shiftId).get();
      if (doc.exists) {
        return ShiftModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get shift: $e');
    }
  }

  /// Get shifts for a specific date
  Stream<List<ShiftModel>> getShiftsByDate(String date) {
    return _firestore
        .collection(_collection)
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ShiftModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Add new shift
  Future<String> addShift(ShiftModel shift) async {
    try {
      // Check for overlapping shifts
      final overlaps = await checkShiftOverlap(
        shift.date,
        shift.startTime,
        shift.endTime,
      );

      if (overlaps) {
        throw Exception('Shift overlaps with an existing shift');
      }

      final docRef = await _firestore
          .collection(_collection)
          .add(shift.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add shift: $e');
    }
  }

  /// Update shift
  Future<void> updateShift(String shiftId, ShiftModel shift) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(shiftId)
          .update(shift.toJson());
    } catch (e) {
      throw Exception('Failed to update shift: $e');
    }
  }

  /// Delete shift
  Future<void> deleteShift(String shiftId) async {
    try {
      // Check if shift is assigned to any cases
      final casesSnapshot = await _firestore
          .collection('cases')
          .where('scheduled_shift_id', isEqualTo: shiftId)
          .get();

      if (casesSnapshot.docs.isNotEmpty) {
        throw Exception('Cannot delete shift that is assigned to cases');
      }

      await _firestore.collection(_collection).doc(shiftId).delete();
    } catch (e) {
      throw Exception('Failed to delete shift: $e');
    }
  }

  /// Check if shift overlaps with existing shifts
  Future<bool> checkShiftOverlap(
    String date,
    String newStart,
    String newEnd,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('date', isEqualTo: date)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final existingStart = data['start_time'] as String;
        final existingEnd = data['end_time'] as String;

        // Check for overlap
        if (newEnd.compareTo(existingStart) > 0 &&
            newStart.compareTo(existingEnd) < 0) {
          return true;
        }
      }

      return false;
    } catch (e) {
      throw Exception('Failed to check shift overlap: $e');
    }
  }

  /// Mark nurse as present for a date
  Future<void> markPresent(String username, String date) async {
    try {
      await _firestore.collection('presence').doc('${username}_$date').set({
        'username': username,
        'date': date,
        'checked_in_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark presence: $e');
    }
  }

  /// Get present nurses for a date
  Future<List<String>> getPresentNurses(String date) async {
    try {
      final snapshot = await _firestore
          .collection('presence')
          .where('date', isEqualTo: date)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['username'] as String)
          .toList();
    } catch (e) {
      throw Exception('Failed to get present nurses: $e');
    }
  }
}
