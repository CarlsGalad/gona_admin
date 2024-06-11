import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gona_admin/services/admin_service.dart'; // Import the AdminService

class ManageDisputesScreen extends StatefulWidget {
  const ManageDisputesScreen({super.key});

  @override
  ManageDisputesScreenState createState() => ManageDisputesScreenState();
}

class ManageDisputesScreenState extends State<ManageDisputesScreen> {
  int? _selectedDisputeIndex;
  DocumentSnapshot? _selectedDispute;
  Map<String, dynamic>? _selectedUserDetails;

  String? adminId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width: MediaQuery.of(context).size.width - 160,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.blueGrey),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildDisputesListView(),
            ),
            const VerticalDivider(
              thickness: 1,
              width: 2,
              color: Color.fromARGB(255, 26, 25, 25),
            ),
            Expanded(
              flex: 3,
              child: _selectedDisputeIndex == null
                  ? const Center(
                      child: Text('Please select a dispute'),
                    )
                  : _buildDisputeDetailsView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisputesListView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('disputes')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: LinearProgressIndicator());
            }

            final disputes = snapshot.data!.docs;
            return ListView.builder(
              itemCount: disputes.length, // Number of disputes
              itemBuilder: (context, index) {
                final dispute = disputes[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.grey),
                    child: ListTile(
                      title: Text(
                        'Category: ${dispute['category']}',
                        style: GoogleFonts.abel(fontSize: 16),
                      ),
                      subtitle: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(dispute['userId'])
                            .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const Text('Loading...');
                          }
                          final userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;
                          return Text(
                            'Sender: ${userData['firstName']} ${userData['lastName']}',
                            style: GoogleFonts.abel(fontSize: 16),
                          );
                        },
                      ),
                      trailing: Text(
                        'Status: ${dispute['status']}',
                        style: GoogleFonts.abel(fontSize: 16),
                      ),
                      onTap: () {
                        setState(
                          () {
                            _selectedDisputeIndex = index;
                            _selectedDispute = dispute;
                            _fetchUserDetails(dispute['userId']);
                          },
                        );

                        // Log the action of viewing a dispute
                        if (adminId != null) {
                          AdminService().logActivity(adminId!, 'View Dispute',
                              'Viewed details of dispute with ID "${dispute.id}"');
                        }
                      },
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  Future<void> _fetchUserDetails(String userId) async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      _selectedUserDetails = userSnapshot.data();
    });
  }

  Widget _buildDisputeDetailsView() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: ${_selectedDispute!['category']}',
                  style: GoogleFonts.aboreto(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 10),
              _selectedUserDetails == null
                  ? const LinearProgressIndicator()
                  : Text(
                      'Sender: ${_selectedUserDetails!['firstName']} ${_selectedUserDetails!['lastName']}',
                      style: GoogleFonts.abel(fontSize: 16),
                    ),
              const SizedBox(height: 10),
              Text(
                'Details:',
                style: GoogleFonts.aboreto(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                '${_selectedDispute!['description']}',
                style: GoogleFonts.abel(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => _resolveDispute('refund'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      'Refund',
                      style: GoogleFonts.abel(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _resolveDispute('replace'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text(
                      'Replace',
                      style: GoogleFonts.abel(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _settleDispute,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      'Settle',
                      style: GoogleFonts.abel(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to update 'resolve' field
  Future<void> _resolveDispute(String action) async {
    try {
      await FirebaseFirestore.instance
          .collection('disputes')
          .doc(_selectedDispute!.id)
          .update({
        'resolve': action,
      });

      // Log the action of resolving a dispute
      if (adminId != null) {
        await AdminService().logActivity(adminId!, 'Resolve Dispute',
            'Resolved dispute with ID "${_selectedDispute!.id}" using "$action" action');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dispute resolved with $action action.')),
      );

      setState(() {
        // Refresh the selected dispute to reflect the updated resolve field
        _selectedDispute = null;
        _selectedDisputeIndex = null;
      });
    } catch (error) {
      print('Failed to resolve dispute: $error');
    }
  }

  // Function to update 'status' field to 'settled'
  Future<void> _settleDispute() async {
    try {
      await FirebaseFirestore.instance
          .collection('disputes')
          .doc(_selectedDispute!.id)
          .update({
        'status': 'settled',
      });

      // Log the action of settling a dispute
      if (adminId != null) {
        await AdminService().logActivity(adminId!, 'Settle Dispute',
            'Settled dispute with ID "${_selectedDispute!.id}"');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispute status set to settled.')),
      );

      setState(() {
        // Refresh the selected dispute to reflect the updated status
        _selectedDispute = null;
        _selectedDisputeIndex = null;
      });
    } catch (error) {
      print('Failed to settle dispute: $error');
    }
  }
}
