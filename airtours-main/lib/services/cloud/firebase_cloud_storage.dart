import 'package:AirTours/services/cloud/cloud_storage_exceptions.dart';
import 'package:AirTours/services/cloud/firestore_flight.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCloudStorage {
  final user = FirebaseFirestore.instance.collection('user');
  final admin = FirebaseFirestore.instance.collection('admin');
  final bookings = FirebaseFirestore.instance.collection('bookings');
  final FlightFirestore flights = FlightFirestore();


  Future<void> deleteUser({
    required ownerUserId
    }) async {
    try {
      final booking = await bookings.where(
      'bookingUserId', isEqualTo: ownerUserId
    ).get();
    final documents = booking.docs;
    final document = documents.first;
    final docRef = document.reference;
    final docSnap = await docRef.get();
    final String returnId = docSnap.data() !['returnFlight'];
    final String depId = docSnap.data() !['departureFlight'];

    final bool isCurrent = await flights.isCurrentFlight(
      depId,
      returnId
      );
    
    if (!isCurrent) {
      await docRef.delete();
    }
    } catch (_) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<bool> isUser({required ownerUserId}) async {
    final docRef = user.doc(ownerUserId);
    final docSnap = await docRef.get(); 
    return docSnap.exists;
  }

  Future<void> updateUser(
      {required String ownerUserId,
      required String email,
      required String phoneNum}) async {
    try {
      DocumentReference docRef = user.doc(ownerUserId);
      await docRef.update({"email": email, "phoneNum": phoneNum});
    } catch (_) {
      throw CouldNotUpdateInformationException();
    }
  }

  Future<void> createNewAdmin({required String email, required String phoneNum}) async {
    try {
      await admin.add({"email": email, "phoneNum": phoneNum});
    } catch (_) {
      throw CouldNotCreateAdminException();
    }
  }

  Future<void> createNewUser(
      {required String ownerUserId,
      required String email,
      required String phoneNum,
      required double balance}) async {
    try {
      DocumentReference docRef = user.doc(ownerUserId);
      await docRef.set({"email": email, "phoneNum": phoneNum, "balance": balance});
    } catch (_) {
      throw CouldNotCreateUserException();
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
