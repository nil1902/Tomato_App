import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';

/// Hotels Tab - Manage all hotels
class HotelsTab extends StatefulWidget {
  const HotelsTab({super.key});

  @override
  State<HotelsTab> createState() => _HotelsTabState();
}

class _HotelsTabState extends State<HotelsTab> {
  List<dynamic> _hotels = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    setState(() => _loading = true);
    final authService = context.read<AuthService>();
    if (authService.accessToken == null) return;

    final adminService = AdminService(authService.accessToken!);
    final hotels = await adminService.getAllHotels();
    
    setState(() {
      _hotels = hotels;
      _loading = false;
    });
  }

  List<dynamic> get _filteredHotels {
    if (_searchQuery.isEmpty) return _hotels;
    return _hotels.where((hotel) {
      final name = hotel['name']?.toString().toLowerCase() ?? '';
      final location = hotel['location']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || location.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotels Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHotels,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search hotels...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          
          // Hotels List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHotels.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty ? 'No hotels found' : 'No matching hotels',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHotels,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredHotels.length,
                          itemBuilder: (context, index) {
                            final hotel = _filteredHotels[index];
                            return _buildHotelCard(hotel);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add hotel screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Hotel feature coming soon!')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Hotel'),
      ),
    );
  }

  Widget _buildHotelCard(Map<String, dynamic> hotel) {
    final name = hotel['name'] ?? 'Unknown Hotel';
    final location = hotel['location'] ?? 'Unknown Location';
    final price = hotel['price_per_night'] ?? 0;
    final rating = hotel['rating']?.toDouble() ?? 0.0;
    final images = hotel['image_urls'] as List<dynamic>?;
    final imageUrl = images != null && images.isNotEmpty ? images[0] : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showHotelOptions(hotel),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Hotel Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.hotel, size: 40),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.hotel, size: 40),
                      ),
              ),
              const SizedBox(width: 12),
              
              // Hotel Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '₹$price/night',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showHotelOptions(hotel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHotelOptions(Map<String, dynamic> hotel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Hotel'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.green),
              title: const Text('Update Price'),
              onTap: () {
                Navigator.pop(context);
                _showPriceDialog(hotel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Hotel'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(hotel);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceDialog(Map<String, dynamic> hotel) {
    final controller = TextEditingController(
      text: hotel['price_per_night']?.toString() ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Price'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Price per night',
            prefixText: '₹',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final price = int.tryParse(controller.text);
              if (price == null) return;
              
              Navigator.pop(context);
              
              final authService = context.read<AuthService>();
              final adminService = AdminService(authService.accessToken!);
              final success = await adminService.updateHotel(
                hotel['id'],
                {'price_per_night': price},
              );
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Price updated successfully!')),
                );
                _loadHotels();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update price')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> hotel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hotel'),
        content: Text('Are you sure you want to delete ${hotel['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final authService = context.read<AuthService>();
              final adminService = AdminService(authService.accessToken!);
              final success = await adminService.deleteHotel(hotel['id']);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hotel deleted successfully!')),
                );
                _loadHotels();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete hotel')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
