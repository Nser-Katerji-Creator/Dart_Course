import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/parking.dart';

class FirebaseParkingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection reference
  CollectionReference get _parkingsCollection => _firestore.collection('parkings');
  
  // Get all parkings
  Future<List<Parking>> getAll() async {
    try {
      final querySnapshot = await _parkingsCollection.get();
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Ensure the document ID is used as the parking ID
            data['id'] = doc.id;
            return Parking.fromJson(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to load parkings: ${e.toString()}');
    }
  }

  // Get parkings by vehicle ID
  Future<List<Parking>> getByVehicleId(String vehicleId) async {
    try {
      final querySnapshot = await _parkingsCollection
          .where('vehicleId', isEqualTo: vehicleId)
          .get();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Parking.fromJson(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to load parkings by vehicle: ${e.toString()}');
    }
  }

  // Get parking by ID
  Future<Parking?> getById(String id) async {
    try {
      final docSnapshot = await _parkingsCollection.doc(id).get();
      
      if (!docSnapshot.exists) {
        return null;
      }
      
      final data = docSnapshot.data() as Map<String, dynamic>;
      data['id'] = docSnapshot.id;
      return Parking.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load parking: ${e.toString()}');
    }
  }

  // Create a new parking
  Future<void> create(Parking parking) async {
    try {
      // Convert DateTime objects to Firestore Timestamps
      final parkingData = parking.toJson();
      parkingData['startTime'] = Timestamp.fromDate(parking.startTime);
      if (parking.endTime != null) {
        parkingData['endTime'] = Timestamp.fromDate(parking.endTime!);
      }
      
      // Remove id from the data as it will be the document ID
      parkingData.remove('id');
      
      // Use the parking's ID as the Firestore document ID instead of auto-generating
      if (parking.id.isNotEmpty) {
        await _parkingsCollection.doc(parking.id).set(parkingData);
      } else {
        // Fallback to auto-generated ID if parking ID is empty
        await _parkingsCollection.add(parkingData);
      }
    } catch (e) {
      throw Exception('Failed to create parking: ${e.toString()}');
    }
  }

  // Update an existing parking
  Future<void> update(String id, Parking parking) async {
    try {
      // Convert DateTime objects to Firestore Timestamps
      final parkingData = parking.toJson();
      parkingData['startTime'] = Timestamp.fromDate(parking.startTime);
      if (parking.endTime != null) {
        parkingData['endTime'] = Timestamp.fromDate(parking.endTime!);
      }
      
      // Remove id from the data as it's the document ID
      parkingData.remove('id');
      
      await _parkingsCollection.doc(id).update(parkingData);
    } catch (e) {
      throw Exception('Failed to update parking: ${e.toString()}');
    }
  }

  // End a parking session
  Future<void> endParking(String id) async {
    try {
      final parking = await getById(id);
      if (parking == null) {
        throw Exception('Parking not found');
      }
      
      final updatedParking = Parking(
        id: parking.id,
        vehicleId: parking.vehicleId,
        parkingSpaceId: parking.parkingSpaceId,
        startTime: parking.startTime,
        endTime: DateTime.now(),
      );
      
      await update(id, updatedParking);
    } catch (e) {
      throw Exception('Failed to end parking: ${e.toString()}');
    }
  }

  // Get active parkings (where endTime is null)
  Future<List<Parking>> getActiveParking() async {
    try {
      final querySnapshot = await _parkingsCollection
          .where('endTime', isNull: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Parking.fromJson(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to load active parkings: ${e.toString()}');
    }
  }

  // Get parking history (where endTime is not null)
  Future<List<Parking>> getParkingHistory() async {
    try {
      final querySnapshot = await _parkingsCollection
          .where('endTime', isNull: false)
          .get();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Parking.fromJson(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to load parking history: ${e.toString()}');
    }
  }

  // Sort parkings by start time
  Future<List<Parking>> sortByStartTime(List<Parking> parkings, {bool ascending = true}) {
    parkings.sort((a, b) => ascending 
      ? a.startTime.compareTo(b.startTime)
      : b.startTime.compareTo(a.startTime));
    return Future.value(parkings);
  }
  
  // Get current user's parking history
  Future<List<Parking>> getCurrentUserParkingHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }
    
    try {
      // First get all vehicles owned by the current user
      final vehiclesSnapshot = await _firestore.collection('vehicles')
          .where('ownerId', isEqualTo: user.uid)
          .get();
      
      final vehicleIds = vehiclesSnapshot.docs.map((doc) => doc.id).toList();
      
      if (vehicleIds.isEmpty) {
        return [];
      }
      
      // Then get all parkings for those vehicles
      final List<Parking> allParkings = [];
      
      for (final vehicleId in vehicleIds) {
        final parkingsSnapshot = await _parkingsCollection
            .where('vehicleId', isEqualTo: vehicleId)
            .where('endTime', isNull: false)
            .get();
        
        final parkings = parkingsSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return Parking.fromJson(data);
        }).toList();
        
        allParkings.addAll(parkings);
      }
      
      return allParkings;
    } catch (e) {
      throw Exception('Failed to get current user parking history: ${e.toString()}');
    }
  }
}
