import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> search(String searchText) async {
    List<Map<String, dynamic>> results = [];
    String lowercasedSearchText = searchText.toLowerCase();

    // Helper function to add collection name
    void addResults(QuerySnapshot snapshot, String collectionName) {
      results.addAll(snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['collectionName'] = collectionName;
        return data;
      }).where((data) {
        return data.values.any((value) =>
            value is String &&
            value.toLowerCase().contains(lowercasedSearchText));
      }));
    }

    try {
      // Fetch all documents and filter in Dart
      Future<void> fetchAndFilter(String collection, String field) async {
        QuerySnapshot snapshot = await _firestore.collection(collection).get();
        addResults(snapshot, collection);
      }

      // Fetch all documents from collection groups and filter in Dart
      Future<void> fetchAndFilterGroup(
          String collectionGroup, String field) async {
        QuerySnapshot snapshot =
            await _firestore.collectionGroup(collectionGroup).get();
        addResults(snapshot, collectionGroup);
      }

      // Search in 'Category' collection
      await fetchAndFilter('Category', 'name');

      // Search in 'Category' sub-collection 'Subcategories'
      await fetchAndFilterGroup('Subcategories', 'name');

      // Search in 'Items' collection
      await fetchAndFilter('Items', 'name');

      // Search in 'farms' collection
      await fetchAndFilter('farms', 'farmName');
      await fetchAndFilter('farms', 'ownersName');

      // Search in 'orderItems' collection
      await fetchAndFilter('orderItems', 'order_id');

      // Search in 'orders' collection
      await fetchAndFilter('orders', 'order_id');
      await fetchAndFilter('orders', 'customer_id');

      // Search in 'users' collection
      await fetchAndFilter('users', 'firstName');
      await fetchAndFilter('users', 'lastName');
      await fetchAndFilter('users', 'email');

      return results;
    } catch (e) {
      // Log the error or handle it appropriately
      print('Error occurred during search: $e');
      return [];
    }
  }
}
