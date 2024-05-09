import 'package:flutter/material.dart';

class OurVendorsScreen extends StatefulWidget {
  const OurVendorsScreen({super.key});

  @override
  OurVendorsScreenState createState() => OurVendorsScreenState();
}

class OurVendorsScreenState extends State<OurVendorsScreen> {
  int? _selectedVendorIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: MediaQuery.of(context).size.width - 180,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.blueGrey),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildVendorsListView(),
            ),
            const VerticalDivider(
              thickness: 1,
              width: 2,
              color: Color.fromARGB(255, 26, 25, 25),
            ),
            Expanded(
              flex: 3,
              child: _selectedVendorIndex == null
                  ? const Center(
                      child: Text('Please select a vendor'),
                    )
                  : _buildVendorDetailsView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorsListView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView.builder(
        itemCount: 10, // Number of vendors
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
            child: Container(
              decoration: const BoxDecoration(color: Colors.grey),
              child: ListTile(
                title: Text('Vendor $index'),
                onTap: () {
                  setState(() {
                    _selectedVendorIndex = index;
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVendorDetailsView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendor ${_selectedVendorIndex!}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Contact: John Doe',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'Phone: +1234567890',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'Email: john@example.com',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Products:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildProductsGridView(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGridView() {
    return GridView.builder(
      itemCount: 8, // Number of products
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Number of columns in the grid
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text('Product $index'),
            ),
          ),
        );
      },
    );
  }
}
