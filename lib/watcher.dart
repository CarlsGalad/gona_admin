import 'package:cloud_firestore/cloud_firestore.dart';

class OrderWatcherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void startWatching() {
    _firestore.collection('orderItems').snapshots().listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.modified) {
          print('Order item modified: ${docChange.doc.id}');
          _handleOrderItemChange(docChange.doc);
        }
      }
    });
  }

  Future<void> _handleOrderItemChange(DocumentSnapshot orderItemDoc) async {
    String orderId = orderItemDoc['order_id'];

    // Fetch all order items for this order
    QuerySnapshot orderItemsSnapshot = await _firestore
        .collection('orderItems')
        .where('order_id', isEqualTo: orderId)
        .get();

    List<DocumentSnapshot> orderItems = orderItemsSnapshot.docs;

    // Check the statuses of all order items
    bool allPrepared = orderItems.every((item) => item['status'] == 'prepared');
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

    if (allPrepared) {
      updates['orderStatus.processed'] = true;
      updates['processedDate'] = FieldValue.serverTimestamp();
    }
    if (allPicked) {
      updates['orderStatus.picked'] = true;
      updates['pickedDate'] = FieldValue.serverTimestamp();
    }
    if (allShipped) {
      updates['orderStatus.shipped'] = true;
      updates['shippedDate'] = FieldValue.serverTimestamp();
    }
    if (allHubNear) {
      updates['orderStatus.hubNear'] = true;
      updates['hubDate'] = FieldValue.serverTimestamp();
    }
    if (allEnroute) {
      updates['orderStatus.enroute'] = true;
      updates['enrouteDate'] = FieldValue.serverTimestamp();
    }
    if (allDelivered) {
      updates['orderStatus.delivered'] = true;
      updates['deliveryDate'] = FieldValue.serverTimestamp();
    }

    if (updates.isNotEmpty) {
      await orderDocRef.update(updates);
    }
    // Add logging to see which order items trigger the update
    print(
        'Handling order item: ${orderItemDoc.id} (Status: ${orderItemDoc['status']})');
  }
}
