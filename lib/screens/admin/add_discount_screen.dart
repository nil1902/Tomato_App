import 'package:flutter/material.dart';
import 'package:lovenest/services/admin_service.dart';

/// Add Discount/Coupon Screen
class AddDiscountScreen extends StatefulWidget {
  const AddDiscountScreen({super.key});

  @override
  State<AddDiscountScreen> createState() => _AddDiscountScreenState();
}

class _AddDiscountScreenState extends State<AddDiscountScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();
  
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();
  final _minAmountController = TextEditingController(text: '0');
  final _maxDiscountController = TextEditingController();
  final _usageLimitController = TextEditingController();
  
  bool _isActive = true;
  bool _saving = false;
  String _discountType = 'percentage'; // percentage or fixed
  DateTime? _validFrom;
  DateTime? _validTo;

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    _minAmountController.dispose();
    _maxDiscountController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Discount'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Coupon Code *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_offer),
                hintText: 'e.g., WELCOME20',
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter coupon code';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: 'e.g., Get 20% off on first booking',
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Discount Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Percentage'),
                            value: 'percentage',
                            groupValue: _discountType,
                            onChanged: (value) {
                              setState(() => _discountType = value!);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Fixed'),
                            value: 'fixed',
                            groupValue: _discountType,
                            onChanged: (value) {
                              setState(() => _discountType = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _discountController,
              decoration: InputDecoration(
                labelText: _discountType == 'percentage' 
                    ? 'Discount Percentage *' 
                    : 'Discount Amount (₹) *',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  _discountType == 'percentage' 
                      ? Icons.percent 
                      : Icons.currency_rupee,
                ),
                hintText: _discountType == 'percentage' ? '20' : '500',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter discount value';
                }
                final num = double.tryParse(value);
                if (num == null) {
                  return 'Please enter valid number';
                }
                if (_discountType == 'percentage' && (num < 0 || num > 100)) {
                  return 'Percentage must be between 0 and 100';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _minAmountController,
              decoration: const InputDecoration(
                labelText: 'Minimum Order Amount (₹)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_cart),
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            if (_discountType == 'percentage')
              TextFormField(
                controller: _maxDiscountController,
                decoration: const InputDecoration(
                  labelText: 'Maximum Discount (₹)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money_off),
                  hintText: 'e.g., 1000',
                ),
                keyboardType: TextInputType.number,
              ),
            if (_discountType == 'percentage') const SizedBox(height: 16),
            
            TextFormField(
              controller: _usageLimitController,
              decoration: const InputDecoration(
                labelText: 'Usage Limit (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
                hintText: 'Leave empty for unlimited',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Valid From'),
                    subtitle: Text(
                      _validFrom != null 
                          ? '${_validFrom!.day}/${_validFrom!.month}/${_validFrom!.year}'
                          : 'Not set',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _validFrom ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _validFrom = date);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text('Valid To'),
                    subtitle: Text(
                      _validTo != null 
                          ? '${_validTo!.day}/${_validTo!.month}/${_validTo!.year}'
                          : 'Not set',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _validTo ?? DateTime.now().add(const Duration(days: 30)),
                        firstDate: _validFrom ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _validTo = date);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Make coupon available to users'),
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
              ),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _saving ? null : _saveDiscount,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Discount'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDiscount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final discountData = {
        'code': _codeController.text.toUpperCase(),
        'description': _descriptionController.text,
        'discount_type': _discountType,
        'discount_value': double.parse(_discountController.text),
        'min_order_amount': double.parse(_minAmountController.text),
        'max_discount': _maxDiscountController.text.isNotEmpty 
            ? double.parse(_maxDiscountController.text) 
            : null,
        'usage_limit': _usageLimitController.text.isNotEmpty 
            ? int.parse(_usageLimitController.text) 
            : null,
        'valid_from': _validFrom?.toIso8601String(),
        'valid_to': _validTo?.toIso8601String(),
        'is_active': _isActive,
      };

      await _adminService.addDiscount(discountData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Discount added successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding discount: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
