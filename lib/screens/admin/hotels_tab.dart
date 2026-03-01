import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import 'forms/hotel_form_screen.dart';

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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header actions
            Row(
              children: [
                Expanded(
                  flex: isDesktop ? 1 : 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search hotels...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                if (isDesktop) const Spacer(flex: 2),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HotelFormScreen()),
                    ).then((saved) {
                      if (saved == true) _loadHotels();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Hotel'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadHotels,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Hotels List
            Expanded(
              child: _filteredHotels.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty ? 'No hotels found' : 'No matching hotels',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey[600]
                            ),
                          ),
                        ],
                      ),
                    )
                  : Card(
                      elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 2,
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: Theme.of(context).brightness == Brightness.dark 
                           ? BorderSide(color: Colors.white.withOpacity(0.05)) 
                           : BorderSide.none,
                      ),
                      child: isDesktop 
                          ? ListView(
                              children: [
                                PaginatedDataTable(
                                  header: const Text('Hotels Listing'),
                                  rowsPerPage: _filteredHotels.length > 10 ? 10 : (_filteredHotels.isEmpty ? 1 : _filteredHotels.length),
                                  columnSpacing: 20,
                                  source: _HotelDataTableSource(
                                    _filteredHotels,
                                    _showHotelOptions,
                                  ),
                                  columns: const [
                                    DataColumn(label: Text('Image')),
                                    DataColumn(label: Text('Hotel Name')),
                                    DataColumn(label: Text('Location')),
                                    DataColumn(label: Text('Price')),
                                    DataColumn(label: Text('Rating')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                )
                              ],
                            )
                          : RefreshIndicator(
                              onRefresh: _loadHotels,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: _filteredHotels.length,
                                itemBuilder: (context, index) {
                                  final hotel = _filteredHotels[index];
                                  return _buildHotelCard(hotel);
                                },
                              ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelCard(Map<String, dynamic> hotel) {
    final name = hotel['name'] ?? 'Unknown Hotel';
    final location = hotel['location'] ?? 'Unknown Location';
    final price = hotel['base_price'] ?? hotel['price_per_night'] ?? 0;
    final rating = hotel['rating']?.toDouble() ?? 0.0;
    final images = hotel['image_urls'] as List<dynamic>? ?? hotel['images'] as List<dynamic>?;
    final imageUrl = images != null && images.isNotEmpty ? images[0].toString() : null;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.surface,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark ? BorderSide(color: Colors.white.withOpacity(0.05)) : BorderSide.none,
      ),
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
                        errorBuilder: (_, _, _) => Container(
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: Theme.of(context).textTheme.bodySmall,
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '₹$price/night',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.green[400] : Colors.green[700],
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HotelFormScreen(hotelToEdit: hotel)),
                ).then((saved) {
                  if (saved == true) _loadHotels();
                });
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
    final defaultPrice = hotel['base_price'] ?? hotel['price_per_night'];
    final controller = TextEditingController(
      text: defaultPrice?.toString() ?? '',
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
                {'base_price': price},
              );
              
              if (mounted) {
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
              
              if (mounted) {
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

class _HotelDataTableSource extends DataTableSource {
  final List<dynamic> _hotels;
  final Function(Map<String, dynamic>) _onRowTap;

  _HotelDataTableSource(this._hotels, this._onRowTap);

  @override
  DataRow? getRow(int index) {
    if (index >= _hotels.length) return null;
    final hotel = _hotels[index] as Map<String, dynamic>;
    
    final name = hotel['name'] ?? 'Unknown Hotel';
    final location = hotel['location'] ?? 'Unknown Location';
    final price = hotel['base_price'] ?? hotel['price_per_night'] ?? 0;
    final rating = hotel['rating']?.toDouble() ?? 0.0;
    final images = hotel['image_urls'] as List<dynamic>? ?? hotel['images'] as List<dynamic>?;
    final imageUrl = images != null && images.isNotEmpty ? images[0].toString() : null;

    return DataRow(
      cells: [
        DataCell(
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[300],
                      child: const Icon(Icons.hotel, size: 20),
                    ),
                  )
                : Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey[300],
                    child: const Icon(Icons.hotel, size: 20),
                  ),
          ),
        ),
        DataCell(Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(location)),
        DataCell(Text('₹$price/night', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: 16, color: Colors.amber[700]),
              const SizedBox(width: 4),
              Text(rating.toStringAsFixed(1)),
            ],
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _onRowTap(hotel),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _hotels.length;

  @override
  int get selectedRowCount => 0;
}
