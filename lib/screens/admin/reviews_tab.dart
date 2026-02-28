import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';

/// Reviews Tab - Manage all reviews and feedback
class ReviewsTab extends StatefulWidget {
  const ReviewsTab({super.key});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  List<dynamic> _reviews = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _loading = true);
    final authService = context.read<AuthService>();
    if (authService.accessToken == null) return;

    final adminService = AdminService(authService.accessToken!);
    final reviews = await adminService.getAllReviews();
    
    if (mounted) {
      setState(() {
        _reviews = reviews;
        _loading = false;
      });
    }
  }

  List<dynamic> get _filteredReviews {
    if (_searchQuery.isEmpty) return _reviews;
    return _reviews.where((review) {
      final comment = review['comment']?.toString().toLowerCase() ?? '';
      return comment.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Reviews Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (isDesktop)
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search reviews...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
              const SizedBox(width: 16),
              IconButton(onPressed: _loadReviews, icon: const Icon(Icons.refresh)),
            ],
          ),
          if (!isDesktop) ...[
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search reviews...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ],
          const SizedBox(height: 24),
          Expanded(
            child: _filteredReviews.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'No reviews found' : 'No matching reviews',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: isDesktop 
                        ? ListView(
                            children: [
                              PaginatedDataTable(
                                header: const Text('All Reviews'),
                                rowsPerPage: _filteredReviews.length > 10 ? 10 : (_filteredReviews.isEmpty ? 1 : _filteredReviews.length),
                                source: _ReviewDataTableSource(_filteredReviews, _confirmDelete),
                                columns: const [
                                  DataColumn(label: Text('Post Date')),
                                  DataColumn(label: Text('Rating')),
                                  DataColumn(label: Text('Comment')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Actions')),
                                ],
                              )
                            ],
                          )
                        : RefreshIndicator(
                            onRefresh: _loadReviews,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _filteredReviews.length,
                              itemBuilder: (context, index) {
                                final review = _filteredReviews[index];
                                return _buildReviewCard(review);
                              },
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = review['overall_rating']?.toString() ?? 'N/A';
    final comment = review['comment'] ?? 'No comment provided';
    final date = review['created_at']?.toString().split('T')[0] ?? '';
    final verified = review['verified_stay'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[700], size: 20),
                const SizedBox(width: 4),
                Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _confirmDelete(review),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            if (verified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 12, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text('Verified Stay', style: TextStyle(fontSize: 10, color: Colors.green[700])),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final auth = context.read<AuthService>();
              final admin = AdminService(auth.accessToken!);
              final success = await admin.deleteReview(review['id']);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review deleted successfully')));
                _loadReviews();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete review')));
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

class _ReviewDataTableSource extends DataTableSource {
  final List<dynamic> _reviews;
  final Function(Map<String, dynamic>) _onDelete;

  _ReviewDataTableSource(this._reviews, this._onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= _reviews.length) return null;
    final review = _reviews[index] as Map<String, dynamic>;
    
    final date = review['created_at']?.split('T')[0] ?? '';
    final rating = review['overall_rating']?.toString() ?? 'N/A';
    final comment = review['comment']?.toString() ?? 'No comment';
    final verified = review['verified_stay'] == true;

    return DataRow(
      cells: [
        DataCell(Text(date)),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber[700], size: 16),
            const SizedBox(width: 4),
            Text(rating),
          ],
        )),
        DataCell(SizedBox(
          width: 250,
          child: Text(comment, maxLines: 1, overflow: TextOverflow.ellipsis),
        )),
        DataCell(verified 
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)),
              child: Text('Verified', style: TextStyle(fontSize: 10, color: Colors.green[800])),
            )
          : const Text('Unverified', style: TextStyle(fontSize: 10, color: Colors.grey)),
        ),
        DataCell(IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () => _onDelete(review),
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _reviews.length;

  @override
  int get selectedRowCount => 0;
}
