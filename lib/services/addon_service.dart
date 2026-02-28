import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/addon.dart';
import 'api_constants.dart';

class AddonService {
  // Fetch all available add-ons
  Future<List<Addon>> getAddons({String? category}) async {
    try {
      String url = '${ApiConstants.baseUrl}/addons?is_active=eq.true';
      if (category != null) {
        url += '&category=eq.$category';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Addon.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load add-ons');
      }
    } catch (e) {
      print('Error fetching add-ons: $e');
      return [];
    }
  }

  // Get add-ons by category
  Future<Map<String, List<Addon>>> getAddonsByCategory() async {
    try {
      final addons = await getAddons();
      final Map<String, List<Addon>> categorized = {
        'decoration': [],
        'food': [],
        'experience': [],
        'gift': [],
      };

      for (var addon in addons) {
        if (categorized.containsKey(addon.category)) {
          categorized[addon.category]!.add(addon);
        }
      }

      return categorized;
    } catch (e) {
      print('Error categorizing add-ons: $e');
      return {};
    }
  }

  // Calculate total price for selected add-ons
  double calculateAddonsTotal(List<Addon> addons) {
    return addons.where((a) => a.isSelected).fold(0, (sum, addon) => sum + addon.price);
  }

  // Get popular add-ons (mock implementation - can be enhanced with analytics)
  Future<List<Addon>> getPopularAddons({int limit = 5}) async {
    try {
      final addons = await getAddons();
      return addons.take(limit).toList();
    } catch (e) {
      print('Error fetching popular add-ons: $e');
      return [];
    }
  }
}
