import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';

/// Bookings Tab - Manage all bookings
class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  List<dynamic> _bookings = [];
  bool _loading = true;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _loading = true);
    final authService = context.read<AuthService>();
    if (authService.accessToken == null) return;

    final adminService = AdminService(authService.accessToken!);
    final bookings = await adminService.getAllBookings(status: _filterStatus);
    
    setState(() {
      _bookings = bookings;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings Management'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterStatus = value == 'all' ? null : value;
              });
              _loadBookings();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Bookings')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'confirmed', child: Text('Confirmed')),
              const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No bookings found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      return _buildBookingCard(booking);
                    },
                  ),
                ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final hotelId = booking['hotel_id'] ?? 'Unknown';
    final userId = booking['user_id'] ?? 'Unknown';
    final status = booking['status'] ?? 'pending';
    final checkIn = booking['check_in_date'] ?? '';
    final checkOut = booking['check_out_date'] ?? '';
    final totalPrice = booking['total_price'] ?? 0;

    Color statusColor;
    switch (status) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showBookingOptions(booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking #${booking['id']?.toString().substring(0, 8) ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '$checkIn → $checkOut',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User: ${userId.toString().substring(0, 8)}...',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '₹$totalPrice',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingOptions(Map<String, dynamic> booking) {
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
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Confirm Booking'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(booking, 'confirmed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancel Booking'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(booking, 'cancelled');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Booking'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(booking);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(Map<String, dynamic> booking, String status) async {
    final authService = context.read<AuthService>();
    final adminService = AdminService(authService.accessToken!);
    final success = await adminService.updateBookingStatus(booking['id'], status);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking $status successfully!')),
      );
      _loadBookings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update booking')),
      );
    }
  }

  void _confirmDelete(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure you want to delete this booking?'),
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
              final success = await adminService.deleteBooking(booking['id']);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking deleted successfully!')),
                );
                _loadBookings();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete booking')),
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
