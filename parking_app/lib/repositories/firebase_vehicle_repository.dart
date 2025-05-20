import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vehicle.dart';

class FirebaseVehicleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection reference
  CollectionReference get _vehiclesCollection => _firestore.collection('vehicles');
  
  // Get all vehicles
  Future<List<Vehicle>> getAll() async {
    try {
      final querySnapshot = await _vehiclesCollection.get();
      return querySnapshot.docs
          .map((doc) => Vehicle.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load vehicles: ${e.toString()}');
    }
  }

  // Get vehicles by owner ID
  Future<List<Vehicle>> getByOwnerId(String ownerId) async {
    try {
      final querySnapshot = await _vehiclesCollection
          .where('ownerId', isEqualTo: ownerId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Vehicle.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load vehicles by owner: ${e.toString()}');
    }
  }

  // Get vehicle by registration number
  Future<Vehicle?> getByRegistrationNumber(String registrationNumber) async {
    try {
      final docSnapshot = await _vehiclesCollection.doc(registrationNumber).get();
      
      if (!docSnapshot.exists) {
        return null;
      }
      
      return Vehicle.fromJson(docSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load vehicle: ${e.toString()}');
    }
  }

  // Create a new vehicle
  Future<void> create(Vehicle vehicle) async {
    try {
      // Use registration number as document ID for easy retrieval
      await _vehiclesCollection.doc(vehicle.registrationNumber).set(vehicle.toJson());
    } catch (e) {
      throw Exception('Failed to create vehicle: ${e.toString()}');
    }
  }

  // Update an existing vehicle
  Future<void> update(String registrationNumber, Vehicle vehicle) async {
    try {
      await _vehiclesCollection.doc(registrationNumber).update(vehicle.toJson());
    } catch (e) {
      throw Exception('Failed to update vehicle: ${e.toString()}');
    }
  }

  // Delete a vehicle
  Future<void> delete(String registrationNumber) async {
    try {
      await _vehiclesCollection.doc(registrationNumber).delete();
    } catch (e) {
      throw Exception('Failed to delete vehicle: ${e.toString()}');
    }
  }
  
  // Get current user's vehicles
  Future<List<Vehicle>> getCurrentUserVehicles() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }
    
    try {
      final querySnapshot = await _vehiclesCollection
          .where('ownerId', isEqualTo: user.uid)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Vehicle.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get current user vehicles: ${e.toString()}');
    }
  }
}
