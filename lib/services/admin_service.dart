import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to log activity
  Future<void> logActivity(
      String adminId, String action, String details) async {
    try {
      await _firestore
          .collection('admin')
          .doc(adminId)
          .collection('activityLog')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'action': action,
        'details': details,
      });
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  Future<Map<String, dynamic>?> getCurrentAdminData(String adminId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('admin').doc(adminId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching admin data: $e');
    }
    return null;
  }

  Future<void> updateAdminImage(String adminId, String imageUrl) async {
    await _firestore.collection('admin').doc(adminId).set({
      'imagePath': imageUrl,
    });
  }

  Stream<QuerySnapshot> listenToOrders() {
    return _firestore.collection('orders').snapshots();
  }

  Stream<QuerySnapshot> listenToOrderItems() {
    return _firestore.collection('orderItems').snapshots();
  }

  Stream<QuerySnapshot> listenToNews() {
    return _firestore.collection('news').snapshots();
  }

  Stream<QuerySnapshot> listenToItems() {
    return _firestore.collection('Items').snapshots();
  }

  Stream<QuerySnapshot> listenToDisputes() {
    return _firestore.collection('disputes').snapshots();
  }

  Future<Map<String, dynamic>?> getFarmData(String farmId) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('farms').doc(farmId).get();
    return snapshot.data() as Map<String, dynamic>?;
  }
}
