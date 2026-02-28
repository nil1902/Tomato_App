# Complete Enhanced Hotel Details Screen Code

Due to the large size of the complete implementation, I'm providing you with the key sections you need to add to your `hotel_details_screen.dart`.

## Step 1: Update the State Class

Add these variables to your `_HotelDetailsScreenState`:

```dart
class _HotelDetailsScreenState extends State<HotelDetailsScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _hotelData;
  List<dynamic> _rooms = [];
  List<dynamic> _reviews = [];
  bool _isLoading = true;
  bool _isFavorite = false;
  late TabController _tabController;
  int _selectedImageIndex = 0;

  final List<String> _categories = [
    'Overview',
    'Rooms',
    'Amenities',
    'Reviews',
    'Location',
    'Policies',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadHotelDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHotelDetails() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.accessToken != null) {
      final databaseService = DatabaseService(authService.accessToken!);
      
      final hotel = await databaseService.getHotelDetails(widget.hotelId);
      final rooms = await databaseService.getRooms(widget.hotelId);
      final reviews = await databaseService.getHotelReviews(widget.hotelId);
      
      setState(() {
        _hotelData = hotel;
        _rooms = rooms;
        _reviews = reviews;
        _isLoading = false;
      });
    }
  }
}
```

## Step 2: Add Category Tabs

Replace your current body with this structure:

```dart
body: CustomScrollView(
  slivers: [
    // Image Gallery (existing code)
    SliverAppBar(...),
    
    // Hotel Info Header
    SliverToBoxAdapter(...),
    
    // NEW: Category Tabs
    SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: _categories.map((cat) => Tab(text: cat)).toList(),
        ),
      ),
    ),
    
    // Tab Content
    SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildRoomsTab(),
          _buildAmenitiesTab(),
          _buildReviewsTab(),
          _buildLocationTab(),
          _buildPoliciesTab(),
        ],
      ),
    ),
  ],
)
```

## Step 3: Add Tab Delegate Class

Add this class at the bottom of your file:

```dart
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
```

## Step 4: Implement Tab Content Methods

I'll provide the complete implementation in the next file due to size constraints.

See `HOTEL_DETAILS_TAB_IMPLEMENTATIONS.md` for the complete tab implementations.
