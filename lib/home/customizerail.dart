import 'package:flutter/material.dart';

class CustomNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationRailDestination> destinations;
  final String department;
  final Map<String, dynamic>? adminData;

  const CustomNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.department,
    this.adminData,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 10),
                child: SizedBox(
                  height: 100,
                  width: 150,
                  child: Image.asset(
                    'lib/images/gona_night.png',
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              ...destinations.asMap().entries.map((entry) {
                int idx = entry.key;
                NavigationRailDestination destination = entry.value;

                // Check if the destination should be displayed based on the department
                if (!shouldDisplayDestination(idx, department)) {
                  return const SizedBox.shrink();
                }

                return InkWell(
                  onTap: () => onDestinationSelected(idx),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconTheme(
                          data: IconThemeData(
                            color: selectedIndex == idx
                                ? Colors.orange.shade200
                                : Colors.grey,
                          ),
                          child: destination.icon,
                        ),
                        const SizedBox(width: 12),
                        DefaultTextStyle(
                          style: TextStyle(
                            color: selectedIndex == idx
                                ? Colors.orange.shade200
                                : Colors.grey,
                            fontSize: 13,
                          ),
                          child: destination.label,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  bool shouldDisplayDestination(int index, String department) {
    // Implement your logic here to determine if a destination should be displayed
    // based on the user's department
    // For example:
    if (department == 'Admin') {
      return true; // Admin can see all destinations
    } else if (department == 'Marketing' && index == 5) {
      return true; // Marketing department can see the Marketing screen
    }
    // Add more conditions as needed
    return index < 3; // By default, show only the first three destinations
  }
}
