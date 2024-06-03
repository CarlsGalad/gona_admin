import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';

class OurVendorsScreen extends StatefulWidget {
  const OurVendorsScreen({super.key});

  @override
  OurVendorsScreenState createState() => OurVendorsScreenState();
}

class OurVendorsScreenState extends State<OurVendorsScreen> {
  int? _selectedVendorIndex;
  List<DocumentSnapshot> _vendors = [];
  List<DocumentSnapshot> _vendorItems = [];

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    final snapshot = await FirebaseFirestore.instance.collection('farms').get();
    setState(() {
      _vendors = snapshot.docs;
    });
  }

  Future<void> _fetchVendorItems(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Items')
        .where('farmId', isEqualTo: userId)
        .get();
    setState(() {
      _vendorItems = snapshot.docs;
    });
  }

  Future<void> _deleteVendor(int index) async {
    final vendor = _vendors[index];
    final imageUrl = vendor['imagePath'] as String?;

    // Delete the image from Firebase Storage if it exists
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.delete();
      } catch (e) {
        print('Failed to delete vendor image: $e');
      }
    }

    await FirebaseFirestore.instance
        .collection('farms')
        .doc(vendor.id)
        .delete();
    setState(() {
      _vendors.removeAt(index);
      _selectedVendorIndex = null;
      _vendorItems = [];
    });
  }

  Future<void> _deleteItem(int index) async {
    final item = _vendorItems[index];
    final imageUrl = item['itemPath'] as String?;

    // Delete the image from Firebase Storage if it exists
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.delete();
      } catch (e) {
        print('Failed to delete item image: $e');
      }
    }

    // Delete the item document
    await FirebaseFirestore.instance.collection('Items').doc(item.id).delete();

    setState(() {
      _vendorItems.removeAt(index);
    });
  }

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
        itemCount: _vendors.length,
        itemBuilder: (context, index) {
          final vendor = _vendors[index];
          final farmName = vendor['farmName'] ?? 'Farm Name';
          final ownersName = vendor['ownersName'] ?? 'Owner\'s Name';
          final status = vendor['status'] ?? 'active';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
            child: Container(
              decoration: const BoxDecoration(color: Colors.grey),
              child: ListTile(
                title: Text(farmName),
                subtitle: Text(ownersName),
                onTap: () {
                  setState(() {
                    _selectedVendorIndex = index;
                  });
                  _fetchVendorItems(vendor['userId']);
                },
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          status == 'suspended' ? Icons.lock_open : Icons.block,
                          color: status == 'suspended'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(status == 'suspended'
                                  ? 'Lift Suspension'
                                  : 'Suspend Vendor'),
                              content: Text(status == 'suspended'
                                  ? 'Are you sure you want to lift the suspension on this vendor?'
                                  : 'Are you sure you want to suspend this vendor?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(status == 'suspended'
                                      ? 'Lift Suspension'
                                      : 'Suspend'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            _toggleVendorSuspension(index);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Vendor'),
                              content: const Text(
                                  'Are you sure you want to delete this vendor?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            _deleteVendor(index);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVendorDetailsView() {
    final vendor = _vendors[_selectedVendorIndex!];

    final String imagePath = vendor['imagePath'] ?? '';
    final String farmName = vendor['farmName'] ?? 'Farm Name';
    final String ownersName = vendor['ownersName'] ?? 'Owner\'s Name';
    final String email = vendor['email'] ?? 'No email provided';
    final String mobile = vendor['mobile'] ?? 'No mobile number provided';
    final String address = vendor['address'] ?? 'No address provided';
    final String city = vendor['city'] ?? 'No city provided';
    final String country = vendor['country'] ?? 'No country provided';
    final int totalEarnings = vendor['totalEarnings'] ?? 0;
    final int totalSales = vendor['totalSales'] ?? 0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath.isNotEmpty)
              ImageNetwork(
                image: imagePath,
                width: 200,
                height: 200,
                borderRadius: BorderRadius.circular(45),
              ),
            Text(
              farmName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Owner: $ownersName',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Email: $email',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Mobile: $mobile',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Address: $address, $city, $country',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Total Earnings: ₦${totalEarnings.toString()}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Total Sales: ${totalSales.toString()}',
              style: const TextStyle(fontSize: 16),
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
    if (_vendorItems.isEmpty) {
      return const Text('No products available');
    }

    return GridView.builder(
      itemCount: _vendorItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Number of columns in the grid
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 2 / 3.2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = _vendorItems[index];
        final String name = item['name'] ?? 'No name';
        final String itemPath = item['itemPath'] ?? '';
        final int price = item['price'] ?? 0;
        final String sellingMethod =
            item['sellingMethod'] ?? 'No selling method';
        final int farmingYear = item['farmingYear'] ?? 0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (itemPath.isNotEmpty)
                  ImageNetwork(
                    image: itemPath,
                    width: 150,
                    height: 100,
                    fitWeb: BoxFitWeb.cover,
                    borderRadius: BorderRadius.circular(10),
                  ),
                const SizedBox(height: 5),
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Price: ₦${price.toString()}',
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Selling Method: $sellingMethod',
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Farming Year: ${farmingYear.toString()}',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Item'),
                            content: const Text(
                                'Are you sure you want to delete this item?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          _deleteItem(index);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleVendorSuspension(int index) async {
    final vendor = _vendors[index];

    final vendorId = vendor.id;
    final currentStatus = vendor['status'] ?? 'active';
    final newStatus = currentStatus == 'suspended' ? 'active' : 'suspended';

    FirebaseFirestore.instance
        .collection('farms')
        .doc(vendorId)
        .update({'status': newStatus});

    final updatedVendor = await vendor.reference.get();

    setState(() {
      _vendors[index] = updatedVendor;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newStatus == 'suspended'
            ? 'Vendor suspended'
            : 'lifted suspension'),
      ),
    );
  }
}
