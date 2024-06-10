import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../watcher.dart';

class PendingOrderScreen extends StatefulWidget {
  const PendingOrderScreen({super.key});

  @override
  PendingOrderScreenState createState() => PendingOrderScreenState();
}

class PendingOrderScreenState extends State<PendingOrderScreen> {
  DocumentSnapshot? _selectedOrder;
  final OrderWatcherService _orderWatcherService = OrderWatcherService();

  @override
  void initState() {
    super.initState();
    _orderWatcherService.startWatching(); // Start watching order changes
  }

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
              child: Text('There are no Pending orders yet!'),
            );
          }
          return ListView.builder(
            itemCount: orders.length, // Number of pending orders
            itemBuilder: (context, index) {
              final order = orders[index];
              final datePlaced = (order['order_date'] as Timestamp).toDate();
              final timeAgo = timeago.format(datePlaced, allowFromNow: true);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 70,
                  color: Colors.white,
                  child: ListTile(
                    title: Text(
                      'Order Id ${order.id}',
                      style: GoogleFonts.aboreto(),
                    ),
                    trailing: Text(
                      'Placed $timeAgo',
                      style: GoogleFonts.abel(),
                    ),
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
        },
      ),
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
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Please select an order',
                style: GoogleFonts.abel(),
              ),
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
              style: GoogleFonts.aboreto(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Order Details:',
              style:
                  GoogleFonts.abel(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: orderItems.length,
                  itemBuilder: (context, index) {
                    final item = orderItems[index] as Map<String, dynamic>;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Item ${index + 1}: ${item['name']}',
                          style: GoogleFonts.abel(fontWeight: FontWeight.bold),
                        ),
                        Text('Price: ${item['price']}',
                            style: GoogleFonts.abel()),
                        Text('Quantity: ${item['quantity']}',
                            style: GoogleFonts.abel()),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text(
                      'Shipping Information:',
                      style: GoogleFonts.aboreto(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    Text(
                      'Name: ${shippingInfo['name']}',
                      style: GoogleFonts.abel(),
                    ),
                    Text(
                      'Address: ${shippingInfo['address']}, ${shippingInfo['city']}, ${shippingInfo['state']}',
                      style: GoogleFonts.abel(),
                    ),
                    Text(
                      'Contact Number: ${shippingInfo['contactNumber']}',
                      style: GoogleFonts.abel(),
                    ),
                  ],
                ),
              ),
            ),
            // Display order status
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text(
                      'Order Status:',
                      style: GoogleFonts.aboreto(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Text('Placed: ${orderStatus['placed']}',
                        style: GoogleFonts.abel()),
                    Text('Order Date: ${_formatTimestamp(order['order_date'])}',
                        style: GoogleFonts.abel()),
                    Text('Total Amount: ${order['total_amount']}',
                        style: GoogleFonts.abel()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Pending Orders',
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
        child: Center(
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
                  color: Colors.white,
                ),
                Expanded(
                  flex: 3,
                  child: _buildOrderDetailsView(_selectedOrder),
                ),
              ],
            ),
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
