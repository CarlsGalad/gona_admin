import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}
