import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  AdminManagementScreenState createState() => AdminManagementScreenState();
}

class AdminManagementScreenState extends State<AdminManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot? _selectedAdmin;
  DocumentSnapshot? _headAdmin;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchHeadAdminDetails();
  }

  Future<void> _fetchHeadAdminDetails() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot headAdminSnapshot =
          await _firestore.collection('admin').doc(currentUser.uid).get();
      setState(() {
        _headAdmin = headAdminSnapshot;
      });
    }
  }

  Future<List<DocumentSnapshot>> _fetchAdmins() async {
    QuerySnapshot adminSnapshot = await _firestore.collection('admin').get();
    return adminSnapshot.docs;
  }

  Future<DocumentSnapshot> _fetchAdminDetails(String adminId) async {
    return await _firestore.collection('admin').doc(adminId).get();
  }

  Future<void> _toggleSuspendAdmin(String adminId) async {
    DocumentSnapshot adminSnapshot =
        await _firestore.collection('admin').doc(adminId).get();
    Map<String, dynamic>? adminData =
        adminSnapshot.data() as Map<String, dynamic>?;

    if (adminData != null && adminData.containsKey('status')) {
      String currentStatus = adminData['status'] as String;
      String newStatus = currentStatus == 'suspended' ? 'active' : 'suspended';
      await _firestore
          .collection('admin')
          .doc(adminId)
          .update({'status': newStatus});
    } else {
      // If 'status' is not present, assume the current status is 'active'
      await _firestore
          .collection('admin')
          .doc(adminId)
          .update({'status': 'suspended'});
    }
  }

  Future<void> _deleteAdmin(String adminId) async {
    await _firestore.collection('admin').doc(adminId).delete();
  }

  Future<void> _showConfirmationDialog(String adminId, String action) async {
    bool confirm = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Admin'),
        content: Text('Are you sure you want to $action this admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirm'),
          ),
        ],
      ),
    ).then((value) {
      confirm = value ?? false;
    });

    if (confirm) {
      setState(() {
        _isProcessing = true;
      });

      if (action == 'Suspend/Unsuspend') {
        await _toggleSuspendAdmin(adminId);
      } else if (action == 'Delete') {
        await _deleteAdmin(adminId);
      }

      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 150),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Management',
              style: GoogleFonts.roboto(color: Colors.white)),
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
        body: Row(
          children: [
            // Left Flex 1: Head Admin Details
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Head Admin Details',
                        style: GoogleFonts.aboreto(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _headAdmin == null
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${_headAdmin!['firstName']}',
                                  style: GoogleFonts.abel(fontSize: 16)),
                              Text('Email: ${_headAdmin!['email']}',
                                  style: GoogleFonts.abel(fontSize: 16)),
                              // Add other head admin details as needed
                            ],
                          ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1),

            // Center Flex 2: List of Admins
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: FutureBuilder<List<DocumentSnapshot>>(
                  future: _fetchAdmins(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('No admins found.',
                              style: GoogleFonts.abel()));
                    }

                    List<DocumentSnapshot> admins = snapshot.data!;
                    return ListView.builder(
                      itemCount: admins.length,
                      itemBuilder: (context, index) {
                        var admin =
                            admins[index].data() as Map<String, dynamic>;
                        final name = admin['firsName'] ??
                            '' + '' + admin['lastName'] ??
                            '';
                        final status = admin['status'] ?? 'active';
                        final department = admin['department'] ?? '';
                        final role = admin['role'] ?? '';
                        final image = admin['imagePath'] ?? '';
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(color: Colors.grey[200]),
                            child: ListTile(
                              selectedTileColor: Colors.grey[200],
                              minLeadingWidth: 50,
                              leading: SizedBox(
                                width: 50,
                                child: ImageNetwork(
                                  image: image,
                                  width: 50,
                                  height: 50,
                                  borderRadius: BorderRadius.circular(45),
                                ),
                              ),
                              title: Text(name, style: GoogleFonts.abel()),
                              subtitle: Text('$department - $role',
                                  style: GoogleFonts.abel()),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Suspend/Unsuspend staff',
                                    icon: Icon(status == 'suspended'
                                        ? Icons.play_arrow
                                        : Icons.pause),
                                    color: status == 'suspended'
                                        ? Colors.green
                                        : Colors.orange,
                                    onPressed: () {
                                      _showConfirmationDialog(admins[index].id,
                                          'Suspend/Unsuspend');
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Erase data',
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      _showConfirmationDialog(
                                          admins[index].id, 'Delete');
                                    },
                                  ),
                                ],
                              ),
                              onTap: () async {
                                DocumentSnapshot adminDetails =
                                    await _fetchAdminDetails(admins[index].id);
                                setState(() {
                                  _selectedAdmin = adminDetails;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const VerticalDivider(width: 1),

            // Right Flex 1: Admin Details and Activity Logs
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey[100],
                child: _selectedAdmin == null
                    ? Center(
                        child: Text('Select an admin to view details.',
                            style: GoogleFonts.abel()))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin Details',
                              style: GoogleFonts.aboreto(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(),
                          // Display selected admin details here
                          Text('Name: ${_selectedAdmin!['firstName']}',
                              style: GoogleFonts.abel(fontSize: 16)),
                          Text('Email: ${_selectedAdmin!['email']}',
                              style: GoogleFonts.abel(fontSize: 16)),
                          Text('Department: ${_selectedAdmin!['department']}',
                              style: GoogleFonts.abel(fontSize: 16)),
                          Text('Role: ${_selectedAdmin!['role']}',
                              style: GoogleFonts.abel(fontSize: 16)),
                          const Divider(),
                          Text('Activity Logs',
                              style: GoogleFonts.aboreto(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(),
                          // Display activity logs here
                          Expanded(
                            child: ListView.builder(
                              itemCount: (_selectedAdmin!['activityLogs']
                                      as Map<String, dynamic>)
                                  .length,
                              itemBuilder: (context, index) {
                                var log = (_selectedAdmin!['activityLogs']
                                    as Map<String, dynamic>)[index];
                                return ListTile(
                                  title: Text(log, style: GoogleFonts.abel()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
