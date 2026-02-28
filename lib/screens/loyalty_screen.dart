import 'package:flutter/material.dart';
import '../models/loyalty_points.dart';
import '../services/loyalty_service.dart';
import '../services/auth_service.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({Key? key}) : super(key: key);

  @override
  _LoyaltyScreenState createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final LoyaltyService _loyaltyService = LoyaltyService();
  final AuthService _authService = AuthService();
  LoyaltyPoints? _loyaltyPoints;
  List<PointsTransaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoyaltyData();
  }

  Future<void> _loadLoyaltyData() async {
    setState(() => _isLoading = true);
    
    final user = _authService.currentUser;
    if (user != null) {
      final userId = user['id']?.toString() ?? user['uid']?.toString() ?? user['email']?.toString() ?? '';
      final points = await _loyaltyService.getUserLoyaltyPoints(userId);
      final transactions = await _loyaltyService.getTransactionHistory(userId);
      
      setState(() {
        _loyaltyPoints = points;
        _transactions = transactions;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loyalty Rewards'),
        backgroundColor: Color(0xFF8B1538),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _loyaltyPoints == null
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadLoyaltyData,
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      _buildPointsCard(),
                      SizedBox(height: 16),
                      _buildTierCard(),
                      SizedBox(height: 24),
                      _buildHowItWorks(),
                      SizedBox(height: 24),
                      _buildTransactionHistory(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Start earning rewards',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Book your first stay to earn points',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B1538), Color(0xFFD4145A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B1538).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Points',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${_loyaltyPoints!.points}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Worth \$${_loyaltyService.pointsToDiscount(_loyaltyPoints!.points).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _loyaltyPoints!.tierIcon,
                  style: TextStyle(fontSize: 32),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_loyaltyPoints!.tierName} Member',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_loyaltyPoints!.lifetimePoints} lifetime points',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_loyaltyPoints!.nextTierPoints > 0) ...[
              SizedBox(height: 16),
              Text(
                'Progress to next tier',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: _loyaltyPoints!.progressToNextTier,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B1538)),
              ),
              SizedBox(height: 4),
              Text(
                '${(_loyaltyPoints!.progressToNextTier * 100).toInt()}% complete',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How it works',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildInfoTile(Icons.hotel, 'Earn 1 point per \$1 spent on bookings'),
            _buildInfoTile(Icons.redeem, '100 points = \$1 discount on next booking'),
            _buildInfoTile(Icons.card_giftcard, 'Unlock exclusive perks at higher tiers'),
            _buildInfoTile(Icons.people, 'Refer friends, earn 500 bonus points'),
            _buildInfoTile(Icons.rate_review, 'Write reviews, earn 50 points each'),
            _buildInfoTile(Icons.celebration, 'Birthday bonus: 200 points'),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),
            Text(
              'Membership Tiers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildTierInfo('🥉 Bronze', '0-999 points', 'Standard benefits'),
            _buildTierInfo('🥈 Silver', '1,000-4,999 points', 'Early check-in, 5% bonus points'),
            _buildTierInfo('🥇 Gold', '5,000-9,999 points', 'Late checkout, 10% bonus, priority support'),
            _buildTierInfo('💎 Platinum', '10,000+ points', 'Free upgrades, 15% bonus, exclusive offers'),
          ],
        ),
      ),
    );
  }

  Widget _buildTierInfo(String tier, String range, String benefits) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tier, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(range, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(benefits, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF8B1538), size: 20),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        if (_transactions.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No transactions yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ..._transactions.take(10).map((transaction) {
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Text(
                  transaction.icon,
                  style: TextStyle(fontSize: 24),
                ),
                title: Text(transaction.description),
                subtitle: Text(
                  _formatDate(transaction.createdAt),
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  '${transaction.points > 0 ? '+' : ''}${transaction.points}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: transaction.points > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
