import 'package:flutter/material.dart';

class ManageCategoryScreen extends StatefulWidget {
  const ManageCategoryScreen({Key? key}) : super(key: key);

  @override
  _ManageCategoryScreenState createState() => _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends State<ManageCategoryScreen> {
  int? _selectedCategoryIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 180,
      child: Row(
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
    );
  }

  Widget _buildCategoriesGridView() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        itemCount: 14, // Number of categories
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of columns in the grid
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemBuilder: (context, index) {
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
                child: Text('Category $index'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubcategoriesListView() {
    return Scaffold(
      body: ListView.builder(
        itemCount: 10, // Number of subcategories
        itemBuilder: (context, index) {
          // You can replace this ListTile with actual subcategory widgets
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(color: Colors.blue),
              child: ListTile(
                title: Text('Subcategory ${_selectedCategoryIndex!} - $index'),
                onTap: () {
                  // Handle subcategory tap action
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: () {}),
    );
  }
}
