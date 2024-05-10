import 'package:flutter/material.dart';

class ProcessedOrderScreen extends StatefulWidget {
  const ProcessedOrderScreen({super.key});

  @override
  ProcessedOrderScreenState createState() => ProcessedOrderScreenState();
}

class ProcessedOrderScreenState extends State<ProcessedOrderScreen> {
  int? _selectedOrderIndex;

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
                child: _selectedOrderIndex == null
                    ? Center(
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
                      )
                    : _buildOrderDetailsView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersListView() {
    return ListView.builder(
      itemCount: 10, // Number of processed orders
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 70,
            color: Colors.white24,
            child: ListTile(
              title: Text('Order ${index + 1}'),
              trailing: const Text('date processed'),
              onTap: () {
                setState(() {
                  _selectedOrderIndex = index;
                });
              },
            ),
          ),
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
            const SizedBox(height: 20),
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
}
