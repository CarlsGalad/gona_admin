import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gona_admin/headadmin/admin_manage.dart';
import 'package:gona_admin/home/customizerail.dart';

import 'package:gona_admin/home/home_screen.dart';
import 'package:gona_admin/payment_managment.dart';
import 'package:gona_admin/transcactions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

import '../categories/category.dart';
import '../disputes/disputes.dart';

import '../marketing/marketing.dart';
import '../news/gonanews.dart';
import '../help/live_chat.dart';
import '../services/admin_service.dart';
import '../services/nofication_service.dart';
import '../services/search_services.dart';
import '../user/users.dart';
import '../vendors/vendors.dart';
import 'search_results.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final _searchBarController = TextEditingController();
  final SearchService _searchService = SearchService();
  int _selectedIndex = 0;
  String? adminId;
  Map<String, dynamic>? adminData;
  bool isLoading = true;

  List<String> notifications = [];
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        adminId = user.uid;
      });
      _fetchAdminData(user.uid);
    }
  }

  Future<void> _fetchAdminData(String adminId) async {
    AdminService adminService = AdminService();
    var data = await adminService.getCurrentAdminData(adminId);
    setState(() {
      adminData = data;
      isLoading = false;
    });
    if (data != null) {
      _notificationService.setupListeners(
          data['role'] ?? '', data['department'] ?? '');
    }
  }

  void _onSearch() async {
    String searchText = _searchBarController.text;
    if (searchText.isNotEmpty) {
      // Show the loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        List<Map<String, dynamic>> results =
            await _searchService.search(searchText);
        Navigator.pop(context); // Remove the loading indicator

        // Log the search activity
        if (adminId != null) {
          await AdminService()
              .logActivity(adminId!, 'Search', 'Searched for "$searchText"');
        }

        if (results.isEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(
                  searchResults: results, errorMessage: 'No results found.'),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(searchResults: results),
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Remove the loading indicator
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('An error occurred during the search.')));

        // Log the search error
        if (adminId != null) {
          await AdminService().logActivity(
              adminId!, 'Search Error', 'Failed search for "$searchText"');
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Search text cannot be empty.')));
    }
  }

  Future<void> _uploadImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;
      if (fileBytes != null) {
        // Upload the image to Firebase Storage
        try {
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('admin_images/${adminId}_profile.jpg');

          UploadTask uploadTask = ref.putData(fileBytes);
          TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

          // Get the image URL and update the admin data
          String imageUrl = await snapshot.ref.getDownloadURL();
          await AdminService().updateAdminImage(adminId!, imageUrl);

          // Show a snackbar or toast message to indicate success
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Profile image updated successfully'),
          ));

          // Log the image upload activity
          if (adminId != null) {
            await AdminService().logActivity(
                adminId!, 'Profile Image Upload', 'Uploaded new profile image');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image.')));

          // Log the image upload error
          if (adminId != null) {
            await AdminService().logActivity(adminId!,
                'Profile Image Upload Error', 'Failed to upload profile image');
          }
        }
      }
    }
  }

  String _getPageNameByIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Live Chat';
      case 2:
        return 'Gona News';
      case 3:
        return 'Manage Categories';
      case 4:
        return 'Manage Loans';
      case 5:
        return 'Marketing';
      case 6:
        return 'Our Vendors';
      case 7:
        return 'Users';
      case 8:
        return 'Manage Disputes';
      case 9:
        return 'Admin Management';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget screen;
    // Get the user's department, default to 'HomeScreen' if not available
    String department = adminData?['department'] ?? 'HomeScreen';
    switch (_selectedIndex) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const ChatWidget();
        break;
      case 2:
        screen = const NewsScreen();
        break;
      case 3:
        screen = const ManageCategoryScreen();
        break;
      case 5:
        screen = const MarketingScreen();
        break;
      case 6:
        screen = const OurVendorsScreen();
        break;
      case 7:
        screen = const OurUsersScreen();
        break;
      case 8:
        screen = const ManageDisputesScreen();
        break;
      case 9:
        screen = const AdminManagementScreen();
        break;
      default:
        screen = Container();
        break;
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],

      // editting here
      body: Row(
        children: [
          CustomNavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });

              // Log the navigation action
              if (adminData?['id'] != null) {
                String pageName = _getPageNameByIndex(index);
                AdminService().logActivity(
                    adminData!['id'], 'Navigation', 'Navigated to $pageName');
              }
            },
            department: department,
            adminData: adminData,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.headset_mic),
                label: Text('Live Chat'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.newspaper),
                label: Text('Gona News'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category),
                label: Text('Manage Categories'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.attach_money),
                label: Text('Manage Loans'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.trending_up),
                label: Text('Marketing'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Our Vendors'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.adjust),
                label: Text('Manage Disputes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.manage_accounts),
                label: Text('Admin'),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          //title dasboard
                          Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              children: [
                                Text(
                                  'Dashboard',
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  'Overview of Gona market',
                                  style: GoogleFonts.abel(
                                      color: Colors.black87,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                          // search bar starts here
                          Expanded(
                            child: SearchBar(
                              backgroundColor: WidgetStateColor.resolveWith(
                                  (states) => Colors.grey.shade900),
                              textCapitalization: TextCapitalization.sentences,
                              constraints: const BoxConstraints(
                                  maxHeight: 40,
                                  maxWidth: 300,
                                  minHeight: 40,
                                  minWidth: 250),
                              trailing: const [
                                Padding(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                              controller: _searchBarController,
                              textStyle: WidgetStateProperty.resolveWith(
                                  (states) =>
                                      const TextStyle(color: Colors.white)),
                              hintText: 'Search ',
                              hintStyle: WidgetStateProperty.resolveWith(
                                  (states) =>
                                      const TextStyle(color: Colors.grey)),
                              onSubmitted: (_) => _onSearch(),
                            ),
                          ),

                          //payment icon
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0, left: 8),
                            child: IconButton(
                                tooltip: 'Payment Manangement',
                                color: Colors.grey.shade900,
                                onPressed: () {
                                  if (department == 'Admin' ||
                                      department == 'Finance and Accounting') {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const PaymentManagementScreen()));
                                  }
                                },
                                icon: const Icon(Icons.wallet)),
                          ),

                          //transcation history
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0, left: 8),
                            child: IconButton(
                                tooltip: 'Transaction History',
                                color: Colors.grey.shade900,
                                onPressed: () {
                                  if (department == 'Admin' ||
                                      department == 'Finance and Accounting') {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const TransactionsScreen()));
                                  }
                                },
                                icon: const Icon(Icons.history)),
                          ),

                          // notifications
                          StreamBuilder<List<String>>(
                            stream: _notificationService.notificationsStream,
                            builder: (context, snapshot) {
                              int notificationCount =
                                  snapshot.hasData ? snapshot.data!.length : 0;
                              return Stack(
                                children: [
                                  PopupMenuButton(
                                    iconColor: Colors.grey.shade900,
                                    icon: const Icon(Icons.notifications),
                                    itemBuilder: (BuildContext context) {
                                      if (notificationCount == 0) {
                                        return [
                                          PopupMenuItem(
                                            child: SizedBox(
                                                width: 250,
                                                height: 650,
                                                child: Center(
                                                    child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.notifications_none,
                                                      size: 50,
                                                    ),
                                                    Text(
                                                      'You have no notifications',
                                                      style: GoogleFonts.abel(),
                                                    ),
                                                  ],
                                                ))),
                                          ),
                                        ];
                                      } else {
                                        return snapshot.data!
                                            .map((String notification) {
                                          return PopupMenuItem(
                                            child: SelectableText(notification),
                                          );
                                        }).toList();
                                      }
                                    },
                                  ),
                                  if (notificationCount > 0)
                                    Positioned(
                                      right: 11,
                                      top: 11,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
                                        ),
                                        child: Text(
                                          '$notificationCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),

                          // profile

                          MaterialButton(
                            height: 30,
                            minWidth: 70,
                            color: Colors.orange.shade200,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 5,
                            onPressed: () {},
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Profile',
                                    style: GoogleFonts.abel(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  isLoading
                                      ? const CircularProgressIndicator()
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              right: 20.0),
                                          child: PopupMenuButton(
                                            tooltip: 'My Profile',
                                            elevation: 5,
                                            iconSize: 25,
                                            splashRadius: 30,
                                            icon: adminData != null &&
                                                    adminData!['imagePath'] !=
                                                        null
                                                ? Container(
                                                    width: 25,
                                                    height: 25,
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape: BoxShape
                                                                .circle),
                                                    child: ImageNetwork(
                                                      image: adminData![
                                                          'imagePath'],
                                                      width: 25,
                                                      height: 25,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.account_box_rounded),
                                            iconColor: Colors.white54,
                                            color: Colors.white70,
                                            position: PopupMenuPosition.under,
                                            popUpAnimationStyle: AnimationStyle(
                                                curve: Curves.easeIn),
                                            itemBuilder:
                                                (BuildContext context) {
                                              return [
                                                PopupMenuItem(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 15.0,
                                                                  left: 10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${adminData!['firstName']} ${adminData!['lastName']} ',
                                                                style: GoogleFonts.roboto(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(
                                                                '${adminData!['email']}',
                                                                style: GoogleFonts
                                                                    .roboto(
                                                                        fontSize:
                                                                            12),
                                                              ),
                                                              adminData!['role'] !=
                                                                      null
                                                                  ? Text(
                                                                      '${adminData!['role'] ?? ''}',
                                                                      style: GoogleFonts
                                                                          .roboto(),
                                                                    )
                                                                  : const Text(
                                                                      ''),
                                                              adminData!['department'] !=
                                                                      null
                                                                  ? Text(
                                                                      '${adminData!['department'] ?? ''}',
                                                                      style: GoogleFonts
                                                                          .roboto())
                                                                  : const Text(
                                                                      ''),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const VerticalDivider(
                                                        color: Colors.black,
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      14.0),
                                                              child: Stack(
                                                                  children: [
                                                                    adminData!['imagePath'] !=
                                                                            null
                                                                        ? Container(
                                                                            height:
                                                                                80,
                                                                            width:
                                                                                80,
                                                                            decoration:
                                                                                const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                                                                            child:
                                                                                ImageNetwork(
                                                                              image: adminData!['imagePath'],
                                                                              width: 60,
                                                                              height: 60,
                                                                            ),
                                                                          )
                                                                        : Container(
                                                                            height:
                                                                                80,
                                                                            width:
                                                                                80,
                                                                            decoration:
                                                                                const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                                                                            child:
                                                                                const Icon(Icons.person, size: 60),
                                                                          ),
                                                                    Positioned(
                                                                      right: 0,
                                                                      bottom: 0,
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            _uploadImage,
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              30,
                                                                          decoration: BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: Colors.black,
                                                                              border: Border.all(color: Colors.white)),
                                                                          child:
                                                                              const Icon(
                                                                            Icons.edit,
                                                                            color:
                                                                                Colors.grey,
                                                                            size:
                                                                                15,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            InkWell(
                                                              splashFactory:
                                                                  InkSparkle
                                                                      .splashFactory,
                                                              splashColor:
                                                                  Colors.white,
                                                              onTap: _logout,
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .grey,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .black38),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          16.0,
                                                                      top: 6,
                                                                      bottom: 6,
                                                                      right:
                                                                          16),
                                                                  child: Text(
                                                                    'Logout',
                                                                    style: GoogleFonts.abel(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ];
                                            },
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: screen,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    if (adminId != null) {
      await AdminService().logActivity(adminId!, 'Logout', 'Admin logged out');
    }
    FirebaseAuth.instance.signOut();
    // Navigate to login screen or any other action after logout
  }
}
