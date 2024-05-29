import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white60),
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
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Colors.black38,
                        child: ListTile(
                          title: Text(result['name'] ??
                              result['order_id'] ??
                              result['customer_id'] ??
                              'Unknown'),
                          subtitle:
                              Text('Found in: ${result['collectionName']}'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
