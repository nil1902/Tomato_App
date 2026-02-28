import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';

/// Promotions Tab - Manage banners, popups, discounts, and advertisements
class PromotionsTab extends StatefulWidget {
  const PromotionsTab({super.key});

  @override
  State<PromotionsTab> createState() => _PromotionsTabState();
}

class _PromotionsTabState extends State<PromotionsTab> {
  int _selectedType = 0; // 0: Banners, 1: Popups, 2: Coupons
  int _refreshKey = 0;

  void _triggerRefresh() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Promotions & Coupons',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(),
                icon: const Icon(Icons.add),
                label: Text(_getAddButtonLabel()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                _buildTypeTab('Banners', 0),
                _buildTypeTab('Popups', 1),
                _buildTypeTab('Coupons', 2),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: IndexedStack(
                key: ValueKey(_refreshKey),
                index: _selectedType,
                children: const [
                  _BannersView(),
                  _PopupsView(),
                  _CouponsView(),
                ],
              ),
            ),
          ),
        ],
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
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final imageUrlController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Banner'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Banner Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://example.com/image.png'
                ),
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
            onPressed: () async {
              Navigator.pop(context);
              final auth = context.read<AuthService>();
              final admin = AdminService(auth.accessToken!);
              
              try {
                await admin.addBanner({
                  'title': titleController.text,
                  'description': descController.text,
                  'is_active': true,
                  'image_url': imageUrlController.text.isNotEmpty 
                      ? imageUrlController.text 
                      : 'https://placehold.co/600x400/png'
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Banner created successfully!')),
                  );
                  _triggerRefresh();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddPopupDialog() {
    final titleController = TextEditingController();
    final discountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Discount Popup'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Popup Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: discountController,
                decoration: const InputDecoration(labelText: 'Discount %'),
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
            onPressed: () async {
              Navigator.pop(context);
              final auth = context.read<AuthService>();
              final admin = AdminService(auth.accessToken!);
              
              try {
                await admin.addPopup({
                  'title': titleController.text,
                  'discount_percent': int.tryParse(discountController.text) ?? 10,
                  'is_active': true,
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Popup created successfully!')),
                  );
                  _triggerRefresh();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddCouponDialog() {
    final codeController = TextEditingController();
    final discountController = TextEditingController();
    final minOrderController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Coupon Code'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Coupon Code (e.g. SUMMER50)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: discountController,
                decoration: const InputDecoration(labelText: 'Discount % (e.g. 15)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minOrderController,
                decoration: const InputDecoration(labelText: 'Min Order Value (₹)'),
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
            onPressed: () async {
              Navigator.pop(context);
              final auth = context.read<AuthService>();
              final admin = AdminService(auth.accessToken!);
              
              try {
                await admin.addDiscount({
                  'code': codeController.text.toUpperCase(),
                  'discount_percent': int.tryParse(discountController.text) ?? 5,
                  'min_order_amount': int.tryParse(minOrderController.text) ?? 0,
                  'is_active': true,
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coupon created successfully!')),
                  );
                  _triggerRefresh();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

// Banners View
class _BannersView extends StatefulWidget {
  const _BannersView();

  @override
  State<_BannersView> createState() => _BannersViewState();
}

class _BannersViewState extends State<_BannersView> {
  List<Map<String, dynamic>> _banners = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthService>();
    if (auth.accessToken == null) return;
    final admin = AdminService(auth.accessToken!);
    final banners = await admin.getBanners();
    if (mounted) {
      setState(() {
        _banners = banners;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_banners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No banners yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _banners.length,
      itemBuilder: (context, index) {
        final banner = _banners[index];
        final isActive = banner['is_active'] == true;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: banner['image_url'] != null
                ? Image.network(banner['image_url'], width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 40))
                : const Icon(Icons.image, size: 40),
            title: Text(banner['title'] ?? 'Untitled Banner', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(banner['description'] ?? 'No description'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: isActive,
                  onChanged: (val) async {
                    final admin = AdminService(context.read<AuthService>().accessToken!);
                    await admin.updateBannerStatus(banner['id'], val);
                    _loadData();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final admin = AdminService(context.read<AuthService>().accessToken!);
                    await admin.deleteBanner(banner['id']);
                    _loadData();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Popups View
class _PopupsView extends StatefulWidget {
  const _PopupsView();

  @override
  State<_PopupsView> createState() => _PopupsViewState();
}

class _PopupsViewState extends State<_PopupsView> {
  List<Map<String, dynamic>> _popups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthService>();
    if (auth.accessToken == null) return;
    final admin = AdminService(auth.accessToken!);
    final popups = await admin.getPopups();
    if (mounted) {
      setState(() {
        _popups = popups;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_popups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No popups yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _popups.length,
      itemBuilder: (context, index) {
        final popup = _popups[index];
        final isActive = popup['is_active'] == true;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.campaign, size: 40, color: Colors.orange),
            title: Text(popup['title'] ?? 'Untitled Popup', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${popup['discount_percent'] ?? 0}% Discount'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: isActive,
                  onChanged: (val) async {
                    final admin = AdminService(context.read<AuthService>().accessToken!);
                    await admin.updatePopupStatus(popup['id'], val);
                    _loadData();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final admin = AdminService(context.read<AuthService>().accessToken!);
                    await admin.deletePopup(popup['id']);
                    _loadData();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Coupons View
class _CouponsView extends StatefulWidget {
  const _CouponsView();

  @override
  State<_CouponsView> createState() => _CouponsViewState();
}

class _CouponsViewState extends State<_CouponsView> {
  List<Map<String, dynamic>> _coupons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthService>();
    if (auth.accessToken == null) return;
    final admin = AdminService(auth.accessToken!);
    final discounts = await admin.getDiscounts();
    if (mounted) {
      setState(() {
        _coupons = discounts;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No coupons yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _coupons.length,
      itemBuilder: (context, index) {
        final coupon = _coupons[index];
        final isActive = coupon['is_active'] == true;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.local_offer, size: 40, color: Colors.green),
            title: Text(coupon['code']?.toString().toUpperCase() ?? 'UNKNOWN', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
            subtitle: Text('${coupon['discount_percent'] ?? 0}% off | Min order: ₹${coupon['min_order_amount'] ?? 0}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: isActive,
                  onChanged: (val) async {
                    final admin = AdminService(context.read<AuthService>().accessToken!);
                    await admin.updateDiscountStatus(coupon['id'], val);
                    _loadData();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final admin = AdminService(context.read<AuthService>().accessToken!);
                    await admin.deleteDiscount(coupon['id']);
                    _loadData();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
