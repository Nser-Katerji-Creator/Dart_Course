import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/person.dart';

class FirebasePersonRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection reference
  CollectionReference get _personsCollection => _firestore.collection('persons');
  
  // Get all persons
  Future<List<Person>> getAll() async {
    try {
      final querySnapshot = await _personsCollection.get();
      return querySnapshot.docs
          .map((doc) => Person.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load persons: ${e.toString()}');
    }
  }

  // Get person by personal number
  Future<Person?> getByPersonalNumber(String personalNumber) async {
    try {
      final querySnapshot = await _personsCollection
          .where('personalNumber', isEqualTo: personalNumber)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      
      return Person.fromJson(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load person: ${e.toString()}');
    }
  }

  // Create a new person
  Future<void> create(Person person) async {
    try {
      // Use personal number as document ID for easy retrieval
      await _personsCollection.doc(person.personalNumber).set(person.toJson());
    } catch (e) {
      throw Exception('Failed to create person: ${e.toString()}');
    }
  }

  // Update an existing person
  Future<void> update(String personalNumber, Person person) async {
    try {
      await _personsCollection.doc(personalNumber).update(person.toJson());
    } catch (e) {
      throw Exception('Failed to update person: ${e.toString()}');
    }
  }

  // Delete a person
  Future<void> delete(String personalNumber) async {
    try {
      await _personsCollection.doc(personalNumber).delete();
    } catch (e) {
      throw Exception('Failed to delete person: ${e.toString()}');
    }
  }
  
  // Get current user's person data
  Future<Person?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    
    try {
      // First try to find by UID
      final querySnapshot = await _personsCollection
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return Person.fromJson(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      }
      
      // If not found by UID, try by email
      if (user.email != null) {
        final emailQuerySnapshot = await _personsCollection
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        
        if (emailQuerySnapshot.docs.isNotEmpty) {
          return Person.fromJson(
              emailQuerySnapshot.docs.first.data() as Map<String, dynamic>);
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  // Get person by email
  Future<Person?> getByEmail(String email) async {
    try {
      final querySnapshot = await _personsCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      return Person.fromJson(querySnapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load person by email: \\${e.toString()}');
    }
  }
}
