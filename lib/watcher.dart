import 'package:cloud_firestore/cloud_firestore.dart';

class OrderWatcherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> startWatching() async {
    try {
      _firestore.collection('orderItems').snapshots().listen((snapshot) {
        for (var docChange in snapshot.docChanges) {
          if (docChange.type == DocumentChangeType.modified) {
            print('Order item modified: ${docChange.doc.id}');
            _handleOrderItemChange(docChange.doc);
          }
        }
      }, onError: (error) {
        print('Error in order items listener: $error');
      });
    } catch (e) {
      print('Error starting order watcher: $e');
    }
  }

  Future<void> _handleOrderItemChange(DocumentSnapshot orderItemDoc) async {
    try {
      String orderId = orderItemDoc['order_id'];

      // Fetch all order items for this order
      QuerySnapshot orderItemsSnapshot = await _firestore
          .collection('orderItems')
          .where('order_id', isEqualTo: orderId)
          .get();

      List<DocumentSnapshot> orderItems = orderItemsSnapshot.docs;

      // Check the statuses of all order items
      bool allPrepared =
          orderItems.every((item) => item['status'] == 'prepared');
      bool allPicked = orderItems.every((item) => item['status'] == 'picked');
      bool allShipped = orderItems.every((item) => item['status'] == 'shipped');
      bool allHubNear = orderItems.every((item) => item['status'] == 'hubNear');
      bool allEnroute = orderItems.every((item) => item['status'] == 'enroute');
      bool allDelivered =
          orderItems.every((item) => item['status'] == 'delivered');

      // Update the corresponding order document
      DocumentReference orderDocRef =
          _firestore.collection('orders').doc(orderId);
      Map<String, dynamic> updates = {};

      if (allPrepared) updates['orderStatus.processed'] = true;
      if (allPicked) updates['orderStatus.picked'] = true;
      if (allShipped) updates['orderStatus.shipped'] = true;
      if (allHubNear) updates['orderStatus.hubNear'] = true;
      if (allEnroute) updates['orderStatus.enroute'] = true;
      if (allDelivered) updates['orderStatus.delivered'] = true;

      if (updates.isNotEmpty) {
        updates['lastUpdated'] = FieldValue.serverTimestamp();
        await orderDocRef.update(updates);
        print('Updated order $orderId with status changes: $updates');
      }

      // Add logging to see which order items trigger the update
      print(
          'Handled order item: ${orderItemDoc.id} (Status: ${orderItemDoc['status']})');
    } catch (e) {
      print('Error handling order item change: $e');
    }
  }
}
