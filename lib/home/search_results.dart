import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

import '../services/search_services.dart';

class SearchResultsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> searchResults;
  final String? errorMessage;

  const SearchResultsScreen({
    super.key,
    required this.searchResults,
    this.errorMessage,
  });

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchResults = widget.searchResults;
    _errorMessage = widget.errorMessage;
  }

  Future<void> _performSearch(String searchText) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Map<String, dynamic>> results =
          await SearchService().search(searchText);

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });

      if (results.isEmpty) {
        setState(() {
          _errorMessage = 'No results found.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error occurred during search: $e';
      });
    }
  }

  void _showDetailDialog(BuildContext context, Map<String, dynamic> result) {
    String collectionName = result['collectionName'];
    String? docId = result['docId'];
    if (docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document ID is missing.')),
      );
      return;
    }
    Widget content;
    bool isUpdating = false;

    switch (collectionName) {
      case 'Category':
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Name: ${result['name']}',
              style: GoogleFonts.roboto(),
            ),
            // Add more fields if necessary
          ],
        );
        break;
      case 'Subcategories':
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Name: ${result['name']}',
              style: GoogleFonts.roboto(),
            ),
            // Add more fields if necessary
          ],
        );
        break;
      case 'Items':
        TextEditingController nameController =
            TextEditingController(text: result['name']);
        TextEditingController descriptionController =
            TextEditingController(text: result['description']);
        TextEditingController priceController =
            TextEditingController(text: result['price'].toString());

        content = StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageNetwork(
                image: result['itemPath'],
                height: 150,
                width: 150,
                curve: Curves.bounceIn,
                borderRadius: BorderRadius.circular(10),
              ),
              const Divider(),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: 'Name', labelStyle: GoogleFonts.roboto()),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                    labelText: 'Description', labelStyle: GoogleFonts.roboto()),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                    labelText: 'Price', labelStyle: GoogleFonts.roboto()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Farm: ${result['itemFarm']}',
                style: GoogleFonts.roboto(),
              ),
              const Divider(),
              Text(
                'Selling Method: ${result['sellingMethod']}',
                style: GoogleFonts.roboto(),
              ),
              const Divider(),
              Text(
                'In Stock: ${result['availQuantity']}',
                style: GoogleFonts.roboto(),
              ),
              const Divider(),
              const SizedBox(height: 20),
              isUpdating
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isUpdating = true;
                        });
                        try {
                          double parsedPrice =
                              double.parse(priceController.text);
                          await _updateItem(
                            result['docId'],
                            nameController.text,
                            descriptionController.text,
                            parsedPrice,
                          );
                          setState(() {
                            isUpdating = false;
                          });
                          Navigator.of(context).pop();
                        } catch (e) {
                          setState(() {
                            isUpdating = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                      child: const Text('Save'),
                    ),
            ],
          );
        });
        break;
      case 'farms':
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ImageNetwork(
              image: result['imagePath'],
              height: 150,
              width: 150,
              curve: Curves.bounceIn,
              borderRadius: BorderRadius.circular(10),
            ),
            const Divider(),
            Text(
              'Farm Name: ${result['farmName']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Owner\'s Name: ${result['ownersName']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Address: ${result['address']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'City: ${result['city']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Country: ${result['country']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Email: ${result['email']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Mobile: ${result['mobile']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Total Earnings: ${result['totalEarnings']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Total Sales: ${result['totalSales']}',
              style: GoogleFonts.roboto(),
            ),
          ],
        );
        break;
      case 'orderItems':
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText('Order ID: ${result['order_id']}'),
            const Divider(),
            Text(
              'Status: ${result['status']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Quantity: ${result['quantity']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Name: ${result['item_name']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Farm: ${result['itemFarm']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
          ],
        );
        break;
      case 'orders':
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              'Order ID: ${result['order_id']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Customer ID: ${result['customer_id']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Placed: ${result['order_date'].toDate()}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Total Amount: ${result['total_amount']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Order Status:',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ..._buildOrderStatusList(result['orderStatus']),
            Text(
              'Shipping Info:',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ..._buildShippingInfoList(result['shipping_info']),
          ],
        );
        break;
      case 'users':
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ImageNetwork(
              image: result['imagePath'],
              height: 150,
              width: 150,
              curve: Curves.bounceInOut,
              borderRadius: BorderRadius.circular(10),
            ),
            const Divider(),
            Text(
              'First Name: ${result['firstName']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Last Name: ${result['lastName']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Email: ${result['email']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Mobile: +234${result['mobile']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Address: ${result['address']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Shipping Infos:',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            ..._buildShippingInfosList(result['shippingInfos']),
            // Add more fields if necessary
          ],
        );
        break;
      default:
        content = Text(
          'No details available',
          style: GoogleFonts.roboto(),
        );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Details',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
          ),
          content: SingleChildScrollView(child: content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: GoogleFonts.roboto(),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateItem(
      String docId, String name, String description, double price) async {
    try {
      await FirebaseFirestore.instance
          .collection('Items')
          .doc(docId)
          .update({'name': name, 'description': description, 'price': price});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: const Text('Item updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update item: $e')),
      );
    }
  }

  List<Widget> _buildOrderStatusList(Map<String, dynamic> orderStatus) {
    return orderStatus.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Text('${entry.key}: ${entry.value}'),
      );
    }).toList();
  }

  List<Widget> _buildShippingInfoList(Map<String, dynamic> shippinInfo) {
    return shippinInfo.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Text('${entry.key}: ${entry.value}'),
      );
    }).toList();
  }

  List<Widget> _buildShippingInfosList(List<dynamic> shippingInfos) {
    return shippingInfos.map((info) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Text(
              'Name: ${info['name']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Address: ${info['address']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'City: ${info['city']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'State: ${info['state']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(),
            Text(
              'Contact Number: ${info['contactNumber']}',
              style: GoogleFonts.roboto(),
            ),
            const Divider(
              color: Colors.blue,
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: GoogleFonts.roboto(color: Colors.white60),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _performSearch(value);
            }
          },
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _performSearch(_searchController.text);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _searchResults.isEmpty
              ? Center(
                  child: Text(
                    _errorMessage ?? 'No results found.',
                    style: GoogleFonts.roboto(color: Colors.red, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 200.0, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(6)),
                        child: ListTile(
                          title: Text(
                            result['name'] ??
                                result['order_id'] ??
                                result['customer_id'] ??
                                result['firstName'] ??
                                'Unknown',
                            style: GoogleFonts.roboto(),
                          ),
                          subtitle: Text(
                            'Found in: ${result['collectionName']}',
                            style: GoogleFonts.roboto(),
                          ),
                          onTap: () => _showDetailDialog(context, result),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
