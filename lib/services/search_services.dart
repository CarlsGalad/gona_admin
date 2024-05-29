import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> search(String searchText) async {
    List<Map<String, dynamic>> results = [];

    // Helper function to add collection name
    void addResults(QuerySnapshot snapshot, String collectionName) {
      results.addAll(snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['collectionName'] = collectionName;
        return data;
      }));
    }

    // Search in 'Category' collection
    QuerySnapshot categorySnapshot = await _firestore
        .collection('Category')
        .where('name', isEqualTo: searchText)
        .get();
    addResults(categorySnapshot, 'Category');

    // Search in 'Category' sub-collection 'Subcategories'
    QuerySnapshot subcategorySnapshot = await _firestore
        .collectionGroup('Subcategories')
        .where('name', isEqualTo: searchText)
        .get();
    addResults(subcategorySnapshot, 'Subcategories');

    // Search in 'Items' collection
    QuerySnapshot itemsSnapshot = await _firestore
        .collection('Items')
        .where('name', isEqualTo: searchText)
        .get();
    addResults(itemsSnapshot, 'Items');

    // Search in 'farms' collection
    QuerySnapshot farmsSnapshot = await _firestore
        .collection('farms')
        .where('farmName', isEqualTo: searchText)
        .get();
    addResults(farmsSnapshot, 'farms');

    QuerySnapshot farmsOwnersSnapshot = await _firestore
        .collection('farms')
        .where('ownersName', isEqualTo: searchText)
        .get();
    addResults(farmsOwnersSnapshot, 'farms');

    // Search in 'orderItems' collection
    QuerySnapshot orderItemsSnapshot = await _firestore
        .collection('orderItems')
        .where('order_id', isEqualTo: searchText)
        .get();
    addResults(orderItemsSnapshot, 'orderItems');

    // Search in 'orders' collection
    QuerySnapshot ordersSnapshot = await _firestore
        .collection('orders')
        .where('order_id', isEqualTo: searchText)
        .get();
    addResults(ordersSnapshot, 'orders');

    QuerySnapshot ordersCustomerSnapshot = await _firestore
        .collection('orders')
        .where('customer_id', isEqualTo: searchText)
        .get();
    addResults(ordersCustomerSnapshot, 'orders');

    // Search in 'users' collection
    QuerySnapshot usersFirstNameSnapshot = await _firestore
        .collection('users')
        .where('firstName', isEqualTo: searchText)
        .get();
    addResults(usersFirstNameSnapshot, 'users');

    QuerySnapshot usersLastNameSnapshot = await _firestore
        .collection('users')
        .where('lastName', isEqualTo: searchText)
        .get();
    addResults(usersLastNameSnapshot, 'users');

    QuerySnapshot usersEmailSnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: searchText)
        .get();
    addResults(usersEmailSnapshot, 'users');

    return results;
  }
}
