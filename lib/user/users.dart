import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gona_admin/user/insights.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';
import 'package:intl/intl.dart';

import '../services/admin_service.dart';

class OurUsersScreen extends StatefulWidget {
  const OurUsersScreen({super.key});

  @override
  OurUsersScreenState createState() => OurUsersScreenState();
}

class OurUsersScreenState extends State<OurUsersScreen> {
  int? _selectedUserIndex;
  List<DocumentSnapshot> _users = [];

  String? cUser = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _users = snapshot.docs;
    });
  }

  Future<void> _deleteUser(int index) async {
    final user = _users[index];
    await FirebaseFirestore.instance.collection('users').doc(user.id).delete();
    setState(() {
      _users.removeAt(index);
      _selectedUserIndex = null;
    });

    // Log user deletion activity
    final userId = user.id;
    AdminService()
        .logActivity(cUser!, 'User Deletion', 'Deleted user with ID: $userId');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width - 155,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.white),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Customers',
                style: GoogleFonts.lato(color: Colors.white),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: IconButton(
                      tooltip: 'Customer Insights',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CustomerInsightsScreen()));
                      },
                      icon: const Icon(Icons.insights)),
                )
              ],
              backgroundColor: Colors.grey[900],
            ),
            body: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildUsersListView(),
                ),
                const VerticalDivider(
                  thickness: 1,
                  width: 2,
                  color: Color.fromARGB(255, 26, 25, 25),
                ),
                Expanded(
                  flex: 3,
                  child: _selectedUserIndex == null
                      ? const Center(
                          child: Text('Please select a user'),
                        )
                      : _buildUserDetailsView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersListView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView.builder(
        itemCount: _users.length, // Number of users
        itemBuilder: (context, index) {
          final user = _users[index];
          final firstName = user['firstName'] ?? 'First Name';
          final lastName = user['lastName'] ?? 'Last Name';
          final status = user['status'] ?? 'active';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              child: ListTile(
                title: Text('$firstName $lastName',
                    style: GoogleFonts.aboreto(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                onTap: () {
                  setState(() {
                    _selectedUserIndex = index;
                  });
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
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
                                : 'Suspend User'),
                            content: Text(status == 'suspended'
                                ? 'Are you sure you want to lift the suspension on this user?'
                                : 'Are you sure you want to suspend this user?'),
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
                          _toggleUserSuspension(index);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete User'),
                            content: const Text(
                                'Are you sure you want to delete this user?'),
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
                          _deleteUser(index);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserDetailsView() {
    final user = _users[_selectedUserIndex!];

    final String imagePath = user['imagePath'] ?? '';
    final String firstName = user['firstName'] ?? 'First Name';
    final String lastName = user['lastName'] ?? 'Last Name';
    final String email = user['email'] ?? 'No email provided';
    final String mobile = user['mobile'] ?? 'No mobile number provided';
    final String address = user['address'] ?? 'No address provided';
    final List<dynamic> purchaseHistory = user['purchase_history'] ?? [];

    return Scaffold(
      body: SingleChildScrollView(
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
                  fitWeb: BoxFitWeb.cover,
                  borderRadius: BorderRadius.circular(10),
                ),
              const Divider(),
              Text(
                '$firstName $lastName',
                style: GoogleFonts.aboreto(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text('Email: $email', style: GoogleFonts.abel(fontSize: 16)),
              const SizedBox(height: 5),
              Text('Mobile: $mobile', style: GoogleFonts.abel(fontSize: 16)),
              const SizedBox(height: 5),
              Text('Address: $address', style: GoogleFonts.abel(fontSize: 16)),
              const SizedBox(height: 5),
              const Divider(),
              Text('Last 5 Purchases:',
                  style: GoogleFonts.aboreto(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 10),
              _buildLastPurchases(purchaseHistory),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastPurchases(List<dynamic> purchases) {
    if (purchases.isEmpty) {
      return const Text('No purchases available');
    }

    return Column(
      children: purchases.take(5).map((purchase) {
        final DateTime orderDate =
            (purchase['order_date'] as Timestamp).toDate();
        final formattedDate =
            DateFormat('yyyy-MM-dd – kk:mm').format(orderDate);

        return Card(
          child: ListTile(
            title: Text('Order ID: ${purchase['order_id']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Amount: ₦${purchase['total_amount']}',
                    style: GoogleFonts.abel(fontSize: 16)),
                Text('Order Date: $formattedDate',
                    style: GoogleFonts.abel(fontSize: 16)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _toggleUserSuspension(int index) async {
    final user = _users[index];
    final userId = user.id;
    final currentStatus = user['status'] ?? 'active';
    final newStatus = currentStatus == 'suspended' ? 'active' : 'suspended';

    // Update the user's status in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'status': newStatus});

    // Fetch the updated user data
    final updatedUser = await user.reference.get();

    setState(() {
      _users[index] = updatedUser;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus == 'suspended'
              ? 'User suspended'
              : 'User suspension lifted',
        ),
      ),
    );

    // Log user suspension activity
    final action = newStatus == 'suspended' ? 'Suspended' : 'Lifted Suspension';
    AdminService().logActivity(
        cUser!, 'User Suspension', '$action user with ID: $userId');
  }
}
