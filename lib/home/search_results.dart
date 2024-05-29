import 'package:flutter/material.dart';

class SearchResultsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;
  final String? errorMessage;

  const SearchResultsScreen(
      {super.key, required this.searchResults, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: searchResults.isEmpty
          ? Center(
              child: Text(
                errorMessage ?? 'No results found.',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final result = searchResults[index];
                final collectionName =
                    result['collectionName'] ?? 'Unknown Collection';
                final displayName = result['name'] ??
                    result['farmName'] ??
                    result['ownersName'] ??
                    result['order_id'] ??
                    result['customer_id'] ??
                    result['firstName'] ??
                    result['lastName'] ??
                    result['email'] ??
                    '';

                return ListTile(
                  title: Text(displayName),
                  subtitle: Text(result.toString()), // Customize this as needed
                  trailing: Text(collectionName),
                );
              },
            ),
    );
  }
}
