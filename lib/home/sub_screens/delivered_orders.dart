import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DeliveredOrderScreen extends StatefulWidget {
  const DeliveredOrderScreen({super.key});

  @override
  DeliveredOrderScreenState createState() => DeliveredOrderScreenState();
}

class DeliveredOrderScreenState extends State<DeliveredOrderScreen> {
  DocumentSnapshot? _selectedOrder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Delivered Orders',
            style: GoogleFonts.lato(color: Colors.grey[900]),
          ),
          toolbarHeight: 50,
          centerTitle: true,
          backgroundColor: Colors.grey[900],
          
        ),
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width - 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[900]),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildOrdersListView(),
                    ),
                    const VerticalDivider(
                      width: 1,
                      color: Colors.white54,
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildOrderDetailsView(_selectedOrder),
                    ),
                  ],
                ),
              ),
            )));
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
                    doc['orderStatus']['processed'] == true &&
                    doc['orderStatus']['shipped'] == true &&
                    doc['orderStatus']['delivered'] == false)
                .toList();

            if (orders.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'There are no delivered orders.',
                        style: GoogleFonts.abel(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: orders.length, // Number of delivered orders
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final datePlaced =
                      (order['precessed_date'] as Timestamp).toDate();
                  final timeAgo =
                      timeago.format(datePlaced, allowFromNow: true);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 70,
                      color: Colors.white54,
                      child: ListTile(
                        title: Text(
                          'Order ${order.id}',
                          style: GoogleFonts.aboreto(),
                        ),
                        trailing: Text(
                          'Delivered: $timeAgo',
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
              ),
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
              'Order ${order.id}',
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
            const Divider(),
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
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping Information:',
                      style: GoogleFonts.aboreto(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Text(
                      'Name: ${shippingInfo['name']}',
                      style: GoogleFonts.abel(),
                    ),
                    Text(
                        'Address: ${shippingInfo['address']}, ${shippingInfo['city']}, ${shippingInfo['state']}',
                        style: GoogleFonts.abel()),
                    Text('Contact Number: ${shippingInfo['contactNumber']}',
                        style: GoogleFonts.abel()),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Status:',
                      style: GoogleFonts.aboreto(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Text('Placed: ${orderStatus['placed']}',
                        style: GoogleFonts.abel()),
                    Text('Precessed: ${orderStatus['processed']}',
                        style: GoogleFonts.abel()),
                    Text('Shipping: ${orderStatus['shipped']}',
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

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final formatter = DateFormat('MMMM d, yyyy');
    return formatter.format(date);
  }
}
