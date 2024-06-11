import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_network/image_network.dart';
import '../services/admin_service.dart';

class ManageCategoryScreen extends StatefulWidget {
  const ManageCategoryScreen({super.key});

  @override
  ManageCategoryScreenState createState() => ManageCategoryScreenState();
}

class ManageCategoryScreenState extends State<ManageCategoryScreen> {
  int? _selectedCategoryIndex;
  List<DocumentSnapshot> _categories = [];
  PlatformFile? _imageFile;

  late AdminService _adminService;

  String? adminId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _adminService = AdminService(); // Initialize the AdminService instance
  }

  Future<void> _fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Category').get();
    setState(() {
      _categories = snapshot.docs;
    });
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null) return;

      setState(() {
        _imageFile = result.files.first;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _addCategory(
      String categoryName, List<String> subcategories) async {
    if (categoryName.isEmpty || _imageFile == null) {
      return;
    }

    final storage = FirebaseStorage.instance;
    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    final ref = storage.ref().child('categoryimages/$timeStamp.jpg');
    await ref.putData(Uint8List.fromList(_imageFile!.bytes!));
    final imageUrl = await ref.getDownloadURL();

    final newCategory =
        await FirebaseFirestore.instance.collection('Category').add({
      'name': categoryName,
      'imagePath': imageUrl,
    });

    for (String subcategory in subcategories) {
      await newCategory.collection('Subcategories').add({'name': subcategory});
    }

    // Log the activity
    await _adminService.logActivity(
      adminId!,
      'Added a new category',
      'Added $categoryName and subcategories $subcategories with an image $imageUrl',
    );

    // Clear the image after adding category
    setState(() {
      _imageFile = null;
    });

    _fetchCategories(); // Refresh the categories list
  }

  Future<void> _addSubcategory(String subcategoryName) async {
    if (_selectedCategoryIndex == null || subcategoryName.isEmpty) {
      return;
    }

    final selectedCategory = _categories[_selectedCategoryIndex!];
    await FirebaseFirestore.instance
        .collection('Category')
        .doc(selectedCategory.id)
        .collection('Subcategories')
        .add({'name': subcategoryName});

    // Log the activity
    await _adminService.logActivity(
      adminId!,
      'Added a Subcategory',
      'category_id $selectedCategory.id subcategory_name $subcategoryName',
    );

    // Refresh the UI to reflect the new subcategory
    setState(() {});
  }

  Future<void> _editSubcategory(String subcategoryId, String newName) async {
    if (_selectedCategoryIndex == null || newName.isEmpty) {
      return;
    }

    final selectedCategory = _categories[_selectedCategoryIndex!];
    await FirebaseFirestore.instance
        .collection('Category')
        .doc(selectedCategory.id)
        .collection('Subcategories')
        .doc(subcategoryId)
        .update({'name': newName});

    // Log the activity
    await _adminService.logActivity(
      adminId!,
      'Edited a subcategory',
      'category_id ${selectedCategory.id} subcategory id $subcategoryId the new name is $newName',
    );

    // Refresh the UI to reflect the edited subcategory
    setState(() {});
  }

  Future<void> _deleteSubcategory(String subcategoryId) async {
    if (_selectedCategoryIndex == null) {
      return;
    }

    final selectedCategory = _categories[_selectedCategoryIndex!];
    await FirebaseFirestore.instance
        .collection('Category')
        .doc(selectedCategory.id)
        .collection('Subcategories')
        .doc(subcategoryId)
        .delete();

    // Log the activity
    await _adminService.logActivity(
      adminId!,
      'Deleted a subcategory',
      'category id $selectedCategory.id subcategory_id $subcategoryId',
    );

    // Refresh the UI to reflect the deleted subcategory
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: MediaQuery.of(context).size.width - 150,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Categories',
            style: TextStyle(fontSize: 20),
          ),
          toolbarHeight: 50,
          elevation: 5,
        ),
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildCategoriesGridView(),
            ),
            const VerticalDivider(
              thickness: 1,
              width: 2,
              color: Colors.grey,
            ),
            Expanded(
              flex: 3,
              child: _selectedCategoryIndex == null
                  ? Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Please select a category',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                      ),
                    )
                  : _buildSubcategoriesListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGridView() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          itemCount: _categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Number of columns in the grid
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 2 / 2.2),
          itemBuilder: (context, index) {
            final category = _categories[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedCategoryIndex == index
                      ? Colors.blue[200]
                      : Colors.blue[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FutureBuilder(
                          future: FirebaseStorage.instance
                              .refFromURL(category['imagePath'])
                              .getDownloadURL(),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LinearProgressIndicator(
                                  color: Colors.blue[
                                      200]); // Placeholder for loading state
                            } else if (snapshot.hasError) {
                              return const Text(
                                  'Error loading image'); // Placeholder for error state
                            } else {
                              return ImageNetwork(
                                onLoading: LinearProgressIndicator(
                                    color: Colors.blue[200]),
                                image: snapshot.data!,
                                height: 100,
                                width: 200,
                              );
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            category['name'],
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController categoryNameController =
        TextEditingController();
    final TextEditingController subcategoryController = TextEditingController();
    List<String> subcategories = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: categoryNameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: subcategoryController,
                  decoration:
                      const InputDecoration(labelText: 'Add Subcategory'),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        subcategories.add(value);
                        subcategoryController.clear();
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                Wrap(
                  children: subcategories
                      .map((subcategory) => Chip(label: Text(subcategory)))
                      .toList(),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    alignment: Alignment.center,
                    width: 200,
                    height: 200,
                    color: Colors.grey,
                    child: _imageFile != null
                        ? Image.memory(
                            Uint8List.fromList(_imageFile!.bytes!),
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.add_a_photo,
                            size: 50,
                          ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addCategory(categoryNameController.text, subcategories);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubcategoriesListView() {
    final selectedCategory = _categories[_selectedCategoryIndex!];
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Category')
          .doc(selectedCategory.id)
          .collection('Subcategories')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: LinearProgressIndicator(color: Colors.blue[200]),
          ));
        }

        final subcategories = snapshot.data!.docs;

        return Scaffold(
          backgroundColor: Colors.white,
          body: ListView.builder(
            itemCount: subcategories.length,
            itemBuilder: (context, index) {
              final subcategory = subcategories[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.blue[200]),
                  child: ListTile(
                    title: Text(subcategory['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditSubcategoryDialog(
                                subcategory.id, subcategory['name']);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteSubcategoryDialog(subcategory.id);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Handle subcategory tap action
                    },
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: _showAddSubcategoryDialog,
          ),
        );
      },
    );
  }

  void _showAddSubcategoryDialog() {
    final TextEditingController subcategoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Subcategory'),
          content: TextField(
            controller: subcategoryController,
            decoration: const InputDecoration(labelText: 'Subcategory Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addSubcategory(subcategoryController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditSubcategoryDialog(String subcategoryId, String currentName) {
    final TextEditingController subcategoryController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Subcategory'),
          content: TextField(
            controller: subcategoryController,
            decoration: const InputDecoration(labelText: 'Subcategory Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _editSubcategory(subcategoryId, subcategoryController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSubcategoryDialog(String subcategoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Subcategory'),
          content:
              const Text('Are you sure you want to delete this subcategory?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteSubcategory(subcategoryId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
