import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/case_model.dart';

/// Service for managing medical cases in Firestore
class CaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'cases';

  /// Get all cases as a stream
  Stream<List<CaseModel>> getCasesStream() {
    return _firestore
        .collection(_collection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CaseModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get all cases
  Future<List<CaseModel>> getAllCases() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('created_at', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => CaseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cases: $e');
    }
  }

  /// Get case by ID
  Future<CaseModel?> getCaseById(String caseId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(caseId).get();
      if (doc.exists) {
        return CaseModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get case: $e');
    }
  }

  /// Get cases for a specific date
  Stream<List<CaseModel>> getCasesByDate(String date) {
    return _firestore
        .collection(_collection)
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CaseModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Add new case
  Future<String> addCase(CaseModel caseModel) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(caseModel.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add case: $e');
    }
  }

  /// Update case
  Future<void> updateCase(String caseId, CaseModel caseModel) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(caseId)
          .update(caseModel.toJson());
    } catch (e) {
      throw Exception('Failed to update case: $e');
    }
  }

  /// Delete case
  Future<void> deleteCase(String caseId) async {
    try {
      // Delete case assignments first
      final assignmentsSnapshot = await _firestore
          .collection('assignments')
          .where('case_id', isEqualTo: caseId)
          .get();
      
      for (var doc in assignmentsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the case
      await _firestore.collection(_collection).doc(caseId).delete();
    } catch (e) {
      throw Exception('Failed to delete case: $e');
    }
  }

  /// Get cases for a user on a specific date
  Future<List<CaseModel>> getCasesForUserOnDate(
    String username,
    String date,
  ) async {
    try {
      // Get assignments for this user
      final assignmentsSnapshot = await _firestore
          .collection('assignments')
          .where('user_id', isEqualTo: username)
          .get();

      final caseIds = assignmentsSnapshot.docs
          .map((doc) => doc.data()['case_id'] as String)
          .toList();

      if (caseIds.isEmpty) {
        return [];
      }

      // Get cases matching these IDs and date
      final casesSnapshot = await _firestore
          .collection(_collection)
          .where(FieldPath.documentId, whereIn: caseIds)
          .get();

      return casesSnapshot.docs
          .map((doc) => CaseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user cases: $e');
    }
  }

  /// Assign nurse to case
  Future<void> assignNurseToCase(String caseId, String username) async {
    try {
      await _firestore.collection('assignments').add({
        'case_id': caseId,
        'user_id': username,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to assign nurse: $e');
    }
  }

  /// Get nurses assigned to a case
  Future<List<String>> getNursesForCase(String caseId) async {
    try {
      final snapshot = await _firestore
          .collection('assignments')
          .where('case_id', isEqualTo: caseId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['user_id'] as String)
          .toList();
    } catch (e) {
      throw Exception('Failed to get assigned nurses: $e');
    }
  }
}
