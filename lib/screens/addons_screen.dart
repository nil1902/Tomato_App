import 'package:flutter/material.dart';
import '../models/addon.dart';
import '../services/addon_service.dart';

class AddonsScreen extends StatefulWidget {
  final List<Addon>? preSelectedAddons;
  
  const AddonsScreen({Key? key, this.preSelectedAddons}) : super(key: key);

  @override
  _AddonsScreenState createState() => _AddonsScreenState();
}

class _AddonsScreenState extends State<AddonsScreen> {
  final AddonService _addonService = AddonService();
  Map<String, List<Addon>> _categorizedAddons = {};
  bool _isLoading = true;
  List<Addon> _selectedAddons = [];

  @override
  void initState() {
    super.initState();
    _loadAddons();
  }

  Future<void> _loadAddons() async {
    setState(() => _isLoading = true);
    
    final addons = await _addonService.getAddonsByCategory();
    
    // Pre-select addons if provided
    if (widget.preSelectedAddons != null) {
      for (var preSelected in widget.preSelectedAddons!) {
        for (var category in addons.values) {
          for (var addon in category) {
            if (addon.id == preSelected.id) {
              addon.isSelected = true;
              _selectedAddons.add(addon);
            }
          }
        }
      }
    }
    
    setState(() {
      _categorizedAddons = addons;
      _isLoading = false;
    });
  }

  void _toggleAddon(Addon addon) {
    setState(() {
      addon.isSelected = !addon.isSelected;
      if (addon.isSelected) {
        _selectedAddons.add(addon);
      } else {
        _selectedAddons.removeWhere((a) => a.id == addon.id);
      }
    });
  }

  double get _totalPrice {
    return _selectedAddons.fold(0, (sum, addon) => sum + addon.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Romantic Add-ons'),
        backgroundColor: Color(0xFF8B1538),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF8B1538), Color(0xFFD4145A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Make your stay extra special',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Choose from our curated romantic experiences',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      ..._buildCategoryWidgets(),
                    ],
                  ),
                ),
                if (_selectedAddons.isNotEmpty) _buildBottomBar(),
              ],
            ),
    );
  }

  List<Widget> _buildCategoryWidgets() {
    List<Widget> widgets = [];
    
    _categorizedAddons.forEach((category, addons) {
      if (addons.isNotEmpty) {
        widgets.add(_buildCategorySection(category, addons));
        widgets.add(SizedBox(height: 24));
      }
    });
    
    return widgets;
  }

  Widget _buildCategorySection(String category, List<Addon> addons) {
    final categoryNames = {
      'decoration': 'Decorations',
      'food': 'Food & Beverages',
      'experience': 'Experiences',
      'gift': 'Gifts',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${addons[0].categoryIcon} ${categoryNames[category] ?? category}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...addons.map((addon) => _buildAddonCard(addon)).toList(),
      ],
    );
  }

  Widget _buildAddonCard(Addon addon) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _toggleAddon(addon),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              if (addon.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    addon.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  ),
                ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addon.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      addon.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\$${addon.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B1538),
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: addon.isSelected,
                onChanged: (value) => _toggleAddon(addon),
                activeColor: Color(0xFF8B1538),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_selectedAddons.length} add-ons selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Total: \$${_totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B1538),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selectedAddons);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B1538),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'Continue',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
