import 'package:flutter/material.dart';

/// Promotions Tab - Manage banners, popups, discounts, and advertisements
class PromotionsTab extends StatefulWidget {
  const PromotionsTab({super.key});

  @override
  State<PromotionsTab> createState() => _PromotionsTabState();
}

class _PromotionsTabState extends State<PromotionsTab> {
  int _selectedType = 0; // 0: Banners, 1: Popups, 2: Coupons

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTypeTab('Banners', 0),
                _buildTypeTab('Popups', 1),
                _buildTypeTab('Coupons', 2),
              ],
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedType,
        children: const [
          _BannersView(),
          _PopupsView(),
          _CouponsView(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        icon: const Icon(Icons.add),
        label: Text(_getAddButtonLabel()),
      ),
    );
  }

  Widget _buildTypeTab(String label, int index) {
    final isSelected = _selectedType == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  String _getAddButtonLabel() {
    switch (_selectedType) {
      case 0:
        return 'Add Banner';
      case 1:
        return 'Add Popup';
      case 2:
        return 'Add Coupon';
      default:
        return 'Add';
    }
  }

  void _showAddDialog() {
    switch (_selectedType) {
      case 0:
        _showAddBannerDialog();
        break;
      case 1:
        _showAddPopupDialog();
        break;
      case 2:
        _showAddCouponDialog();
        break;
    }
  }

  void _showAddBannerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Banner'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Banner Title'),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              Text('Image upload feature coming soon!'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Banner creation coming soon!')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddPopupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Discount Popup'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Popup Title'),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Discount %'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              Text('Image upload feature coming soon!'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Popup creation coming soon!')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddCouponDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Coupon Code'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Coupon Code'),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Discount %'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Min Order Value'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coupon creation coming soon!')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

// Banners View
class _BannersView extends StatelessWidget {
  const _BannersView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No banners yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create banners to show on homepage',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// Popups View
class _PopupsView extends StatelessWidget {
  const _PopupsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No popups yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create discount popups for users',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// Coupons View
class _CouponsView extends StatelessWidget {
  const _CouponsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No coupons yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create coupon codes for discounts',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
