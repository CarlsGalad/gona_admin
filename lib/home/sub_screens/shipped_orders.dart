import 'package:flutter/material.dart';

class ShippedOrderScreen extends StatefulWidget {
  const ShippedOrderScreen({super.key});

  @override
  ShippedOrderScreenState createState() => ShippedOrderScreenState();
}

class ShippedOrderScreenState extends State<ShippedOrderScreen> {
  int? _selectedOrderIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              width: MediaQuery.of(context).size.width - 180,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blueGrey),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildOrdersListView(),
                  ),
                  Expanded(
                    flex: 3,
                    child: _selectedOrderIndex == null
                        ? const Center(
                            child: Text('Please select an order'),
                          )
                        : _buildOrderDetailsView(),
                  ),
                ],
              ),
            )));
  }

  Widget _buildOrdersListView() {
    return ListView.builder(
      itemCount: 10, // Number of shipped orders
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Order ${index + 1}'),
          onTap: () {
            setState(() {
              _selectedOrderIndex = index;
            });
          },
        );
      },
    );
  }

  Widget _buildOrderDetailsView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ${_selectedOrderIndex! + 1}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Order Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Details of the order will be shown here.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
