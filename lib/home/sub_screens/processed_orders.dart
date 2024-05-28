import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProcessedOrderScreen extends StatefulWidget {
  const ProcessedOrderScreen({super.key});

  @override
  ProcessedOrderScreenState createState() => ProcessedOrderScreenState();
}

class ProcessedOrderScreenState extends State<ProcessedOrderScreen> {
  DocumentSnapshot? _selectedOrder;

  Widget _buildOrdersListView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final orders = snapshot.data!.docs
                .where((doc) =>
                    doc['orderStatus']['placed'] == true &&
                    doc['orderStatus']['processed'] == false &&
                    doc['orderStatus']['picked'] == false &&
                    doc['orderStatus']['shipped'] == false &&
                    doc['orderStatus']['hubNear'] == false &&
                    doc['orderStatus']['enroute'] == false &&
                    doc['orderStatus']['delivered'] == false)
                .toList();
            if (orders.isEmpty) {
              return const Center(
                child: Text('There are no processed orders.'),
              );
            }
            return ListView.builder(
              itemCount: orders.length, // Number of processed orders
              itemBuilder: (context, index) {
                final order = orders[index];
                final datePlaced =
                    (order['precessed_date'] as Timestamp).toDate();
                final timeAgo = timeago.format(datePlaced, allowFromNow: true);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 70,
                    color: Colors.white24,
                    child: ListTile(
                      title: Text('Order: ${order.id}'),
                      trailing: Text('Placed $timeAgo'),
                      onTap: () {
                        setState(() {
                          _selectedOrder = order;
                        });
                      },
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  Widget _buildOrderDetailsView(DocumentSnapshot? order) {
    if (order == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white24,
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Please select an order'),
            ),
          ),
        ),
      );
    }

    final orderStatus = order['orderStatus'] as Map<String, dynamic>;
    final shippingInfo = order['shipping_info'] as Map<String, dynamic>;
    final orderItems = order['orderItems'] as List<dynamic>;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ${order['order_id']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Order Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            ListView.builder(
              shrinkWrap: true,
              itemCount: orderItems.length,
              itemBuilder: (context, index) {
                final item = orderItems[index] as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item ${index + 1}: ${item['name']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Price: ${item['price']}'),
                    Text('Quantity: ${item['quantity']}'),
                    const Divider(),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'Shipping Information:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Name: ${shippingInfo['name']}'),
            Text(
                'Address: ${shippingInfo['address']}, ${shippingInfo['city']}, ${shippingInfo['state']}'),
            Text('Contact Number: ${shippingInfo['contactNumber']}'),
            // Display order status
            const SizedBox(height: 10),
            const Text(
              'Order Status:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Placed: ${orderStatus['placed']}'),
            Text('Precessed: ${orderStatus['processed']}'),
            Text('Order Date: ${_formatTimestamp(order['order_date'])}'),
            Text('Total Amount: ${order['total_amount']}'),

            ElevatedButton(
              onPressed: () {
                // Handle notify courier action
              },
              child: const Text('Notify Courier'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      appBar: AppBar(
        title: const Text(
          'Processed Orders',
          style: TextStyle(color: Colors.white),
        ),
        toolbarHeight: 50,
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 500,
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width - 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blueGrey,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildOrdersListView(),
              ),
              const VerticalDivider(
                width: 1,
                color: Colors.white24,
              ),
              Expanded(
                flex: 3,
                child: _buildOrderDetailsView(_selectedOrder),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final formatter = DateFormat('MMMM d, yyyy');
    return formatter.format(date);
  }
}
