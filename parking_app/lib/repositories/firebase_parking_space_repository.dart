import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parking_space.dart';

class FirebaseParkingSpaceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection reference
  CollectionReference get _parkingSpacesCollection => _firestore.collection('parkingspaces');
  
  // Get all parking spaces
  Future<List<ParkingSpace>> getAll() async {
    try {
      final querySnapshot = await _parkingSpacesCollection.get();
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Ensure the document ID is used as the parking space ID
            data['id'] = doc.id;
            return ParkingSpace.fromJson(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to load parking spaces: ${e.toString()}');
    }
  }

  // Get parking space by ID
  Future<ParkingSpace?> getById(String id) async {
    try {
      final docSnapshot = await _parkingSpacesCollection.doc(id).get();
      
      if (!docSnapshot.exists) {
        return null;
      }
      
      final data = docSnapshot.data() as Map<String, dynamic>;
      data['id'] = docSnapshot.id;
      return ParkingSpace.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load parking space: ${e.toString()}');
    }
  }

  // Search parking spaces by query
  Future<List<ParkingSpace>> search(String query) async {
    try {
      if (query.isEmpty) {
        return await getAll();
      }
      
      // Firestore doesn't support contains queries directly, so we need to get all and filter
      final allSpaces = await getAll();
      query = query.toLowerCase();
      
      return allSpaces.where((space) => 
        space.address.toLowerCase().contains(query) || 
        space.id.toLowerCase().contains(query)
      ).toList();
      
      // Note: For a production app with many parking spaces, you might want to implement
      // a more efficient search using Firestore's array-contains or other indexing strategies
    } catch (e) {
      throw Exception('Failed to search parking spaces: ${e.toString()}');
    }
  }
  
  // Get available parking spaces
  Future<List<ParkingSpace>> getAvailableSpaces() async {
    try {
      final querySnapshot = await _parkingSpacesCollection
          .where('isOccupied', isEqualTo: false)
          .get();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return ParkingSpace.fromJson(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to load available parking spaces: ${e.toString()}');
    }
  }
  
  // Update parking space status
  Future<void> updateStatus(String id, bool isOccupied) async {
    try {
      await _parkingSpacesCollection.doc(id).update({
        'isOccupied': isOccupied
      });
    } catch (e) {
      throw Exception('Failed to update parking space status: ${e.toString()}');
    }
  }
  
  // Stream of parking spaces for real-time updates (VG feature)
  Stream<List<ParkingSpace>> getParkingSpacesStream() {
    return _parkingSpacesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ParkingSpace.fromJson(data);
      }).toList();
    });
  }

  // Add a new parking space (admin only)
  Future<void> add(ParkingSpace parkingSpace) async {
    try {
      await _parkingSpacesCollection.add(parkingSpace.toFirestore());
    } catch (e) {
      throw Exception('Failed to add parking space: \\${e.toString()}');
    }
  }
}
