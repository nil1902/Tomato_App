import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lovenest/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lovenest/services/auth_service.dart';
import 'package:lovenest/services/booking_service.dart';
import 'package:lovenest/models/booking.dart';
import 'package:intl/intl.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Booking> _upcomingBookings = [];
  List<Booking> _completedBookings = [];
  List<Booking> _cancelledBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final bookingService = BookingService(authService.accessToken ?? '');
      final userId = user['id'] ?? user['uid'] ?? user['email'];
      final allBookings = await bookingService.getUserBookings(userId.toString());
      
      setState(() {
        _upcomingBookings = allBookings.where((b) => b.status == 'confirmed' && b.checkInDate.isAfter(DateTime.now())).toList();
        _completedBookings = allBookings.where((b) => b.status == 'completed').toList();
        _cancelledBookings = allBookings.where((b) => b.status == 'cancelled').toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading bookings: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: theme.colorScheme.background,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Upcoming (${_upcomingBookings.length})'),
            Tab(text: 'Completed (${_completedBookings.length})'),
            Tab(text: 'Cancelled (${_cancelledBookings.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(_upcomingBookings, isUpcoming: true),
          _buildBookingList(_completedBookings, isCompleted: true),
          _buildBookingList(_cancelledBookings, isCancelled: true),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) {
            context.push('/home'); // wait, go() might be better for root
          } else if (index == 1) {
            context.push('/search');
          } else if (index == 3) {
            context.push('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Nests'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings, {bool isUpcoming = false, bool isCompleted = false, bool isCancelled = false}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              isUpcoming ? 'Book your next romantic getaway!' : 
              isCompleted ? 'Your completed bookings will appear here' :
              'Your cancelled bookings will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(context, booking, isUpcoming: isUpcoming, isCompleted: isCompleted, isCancelled: isCancelled);
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking, {bool isUpcoming = false, bool isCompleted = false, bool isCancelled = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('dd MMM yyyy');

    Color statusColor = AppColors.primary;
    if (isCompleted) statusColor = Colors.green;
    if (isCancelled) statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking ID: ${booking.id.substring(0, 8)}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: booking.hotelImage != null
                      ? CachedNetworkImage(
                          imageUrl: booking.hotelImage!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.hotel),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.hotel),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.hotel),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.hotelName ?? 'Hotel',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (booking.hotelLocation != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                booking.hotelLocation!,
                                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${dateFormat.format(booking.checkInDate)} - ${dateFormat.format(booking.checkOutDate)}',
                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking.totalNights} night${booking.totalNights > 1 ? 's' : ''} • \$${booking.totalAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Actions
          if (isUpcoming || isCompleted) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      // Navigate to booking details
                    },
                    child: Text('View Details', style: TextStyle(color: AppColors.primary)),
                  ),
                  if (isUpcoming) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.withOpacity(0.5)),
                        elevation: 0,
                      ),
                      onPressed: () => _cancelBooking(booking),
                      child: const Text('Cancel'),
                    ),
                  ],
                  if (isCompleted) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                      ),
                      onPressed: () {
                        context.push('/hotel/${booking.hotelId}');
                      },
                      child: const Text('Rebook'),
                    ),
                  ],
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final bookingService = BookingService(authService.accessToken ?? '');
      
      final success = await bookingService.cancelBooking(booking.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled successfully')),
        );
        _loadBookings();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to cancel booking')),
        );
      }
    }
  }
}
