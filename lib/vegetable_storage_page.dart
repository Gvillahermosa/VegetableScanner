import 'package:flutter/material.dart';
import 'notifications_page.dart';

class VegetableStoragePage extends StatefulWidget {
  const VegetableStoragePage({super.key});

  @override
  State<VegetableStoragePage> createState() => _VegetableStoragePageState();
}

class _VegetableStoragePageState extends State<VegetableStoragePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Selected vegetable category
  String _selectedCategory = 'All';

  // List of vegetable categories
  final List<String> _categories = [
    'All',
    'Leafy Greens',
    'Root Vegetables',
    'Cruciferous',
    'Alliums',
    'Gourds & Squashes',
    'Nightshades',
    'Herbs',
  ];

  // Your stored vegetables (this would typically come from a database)
  List<Vegetable> _myVegetables = [];

  // Filter vegetables based on search and category
  List<Vegetable> get _filteredMyVegetables {
    return _myVegetables.where((vegetable) {
      final matchesSearch =
          vegetable.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || vegetable.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    // For demo purposes, add some example vegetables
    _myVegetables = [
      Vegetable(
        name: 'Spinach',
        category: 'Leafy Greens',
        storageLocation: 'Refrigerator',
        temperatureRange: '1-4°C',
        humidity: 'High',
        description: 'Store in a perforated plastic bag in the crisper drawer.',
        daysToExpiry: 5,
        imageAsset: 'assets/images/spinach.png',
      ),
      Vegetable(
        name: 'Carrots',
        category: 'Root Vegetables',
        storageLocation: 'Refrigerator',
        temperatureRange: '0-4°C',
        humidity: 'High',
        description:
            'Remove tops and store in a plastic bag in the crisper drawer.',
        daysToExpiry: 14,
        imageAsset: 'assets/images/carrot.png',
      ),
      Vegetable(
        name: 'Tomatoes',
        category: 'Nightshades',
        storageLocation: 'Counter',
        temperatureRange: '18-21°C',
        humidity: 'Medium',
        description: 'Store at room temperature away from direct sunlight.',
        daysToExpiry: 7,
        imageAsset: 'assets/images/tomato.png',
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Vegetables',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search and filter section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search vegetables...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),

                // Category filter
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Vegetables list
          Expanded(
            child: _filteredMyVegetables.isEmpty
                ? const Center(
                    child: Text(
                      'No vegetables added yet.\nUse the Identify feature to add vegetables.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredMyVegetables.length,
                    itemBuilder: (context, index) {
                      final vegetable = _filteredMyVegetables[index];
                      return _buildVegetableCard(
                        vegetable,
                        onActionPressed: () {
                          _removeVegetable(vegetable);
                        },
                        actionIcon: Icons.remove_circle,
                        actionColor: Colors.red,
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildVegetableCard(
    Vegetable vegetable, {
    required VoidCallback onActionPressed,
    required IconData actionIcon,
    required Color actionColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Image.asset(
              vegetable.imageAsset,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.eco, color: Colors.green);
              },
            ),
          ),
        ),
        title: Text(
          vegetable.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${vegetable.category} • ${vegetable.storageLocation} • ${vegetable.temperatureRange}',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Days to expiry indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getExpiryColor(vegetable.daysToExpiry),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${vegetable.daysToExpiry} days',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(actionIcon),
              color: actionColor,
              onPressed: onActionPressed,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStorageInfoRow(
                    'Storage Location', vegetable.storageLocation),
                const SizedBox(height: 8),
                _buildStorageInfoRow('Temperature', vegetable.temperatureRange),
                const SizedBox(height: 8),
                _buildStorageInfoRow('Humidity', vegetable.humidity),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Storage Tips',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vegetable.description,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Color _getExpiryColor(int daysToExpiry) {
    if (daysToExpiry <= 2) {
      return Colors.red;
    } else if (daysToExpiry <= 5) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  void _removeVegetable(Vegetable vegetable) {
    setState(() {
      _myVegetables.remove(vegetable);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${vegetable.name} removed from My Vegetables'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavBarItem(
              icon: Icons.notifications_outlined,
              isSelected: false,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsPage()))),
          _buildNavBarItem(
              icon: Icons.home,
              isSelected: false,
              onTap: () => Navigator.of(context).pop()),
          _buildCircularProfileButton(),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(
      {required IconData icon, required bool isSelected, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Icon(icon,
            color: isSelected ? Colors.green : Colors.grey, size: 28),
      ),
    );
  }

  Widget _buildCircularProfileButton() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.8), shape: BoxShape.circle),
      child: const Icon(Icons.person, color: Colors.white, size: 24),
    );
  }
}

class Vegetable {
  final String name;
  final String category;
  final String storageLocation;
  final String temperatureRange;
  final String humidity;
  final String description;
  final int daysToExpiry;
  final String imageAsset;

  Vegetable({
    required this.name,
    required this.category,
    required this.storageLocation,
    required this.temperatureRange,
    required this.humidity,
    required this.description,
    required this.daysToExpiry,
    required this.imageAsset,
  });
}
