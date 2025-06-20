import 'package:flutter/material.dart';
import '../services/local_payment_service.dart';
import '../models/payment_method.dart';
import '../services/payment_service.dart';

class PaymentMethodTestScreen extends StatefulWidget {
  const PaymentMethodTestScreen({super.key});

  @override
  State<PaymentMethodTestScreen> createState() => _PaymentMethodTestScreenState();
}

class _PaymentMethodTestScreenState extends State<PaymentMethodTestScreen> {
  final LocalPaymentService _paymentService = LocalPaymentService();
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoading = true);
    try {
      final methods = await _paymentService.getPaymentMethods('test_user');
      setState(() {
        _paymentMethods = methods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load payment methods: $e');
    }
  }

  Future<void> _addTestCard() async {
    setState(() => _isLoading = true);
    try {
      final request = PaymentMethodRequest(
        type: PaymentMethodType.creditCard,
        cardNumber: '4111111111111111',
        expiryMonth: '12',
        expiryYear: '2025',
        cvv: '123',
        holderName: 'Test User',
      );

      await _paymentService.addPaymentMethod('test_user', request);
      await _loadPaymentMethods();
      _showSuccess('Test card added successfully!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to add test card: $e');
    }
  }

  Future<void> _clearAllPaymentMethods() async {
    setState(() => _isLoading = true);
    try {
      await _paymentService.clearAllPaymentMethods('test_user');
      await _loadPaymentMethods();
      _showSuccess('All payment methods cleared!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to clear payment methods: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _addTestCard,
                  child: const Text('Add Test Card'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _clearAllPaymentMethods,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Clear All'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loadPaymentMethods,
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Stored Payment Methods (${_paymentMethods.length}):',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_paymentMethods.isEmpty)
              const Center(
                child: Text(
                  'No payment methods stored.\nAdd a test card to verify persistence.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = _paymentMethods[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.credit_card,
                          color: method.isDefault ? Colors.green : null,
                        ),
                        title: Text(method.displayName),
                        subtitle: Text(
                          'Added: ${method.createdAt.toString().split('.')[0]}\n'
                          'Token: ${method.token}',
                        ),
                        trailing: method.isDefault
                            ? const Chip(
                                label: Text('Default'),
                                backgroundColor: Colors.green,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
