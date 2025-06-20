import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/payment_method.dart';
import '../services/payment_service.dart';
import '../services/local_payment_service.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/add_payment_method_dialog.dart';
import '../widgets/payment_method_options_dialog.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final PaymentService _paymentService = LocalPaymentService();
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  String _getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      return authState.user.personalNumber ?? 'mock_user_id';
    }
    return 'mock_user_id';
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      String userId = 'mock_user_id';
      if (authState is AuthSuccess) {
        userId = authState.user.personalNumber ?? 'mock_user_id';
      }

      final methods = await _paymentService.getPaymentMethods(userId);
      setState(() {
        _paymentMethods = methods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  Future<void> _addPaymentMethod() async {
    final userId = _getCurrentUserId();
    final result = await showDialog<PaymentMethod>(
      context: context,
      builder: (context) => AddPaymentMethodDialog(
        paymentService: _paymentService,
        userId: userId,
      ),
    );

    if (result != null) {
      await _loadPaymentMethods();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.typeDisplayName} added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showPaymentMethodOptions(PaymentMethod paymentMethod) async {
    final action = await showDialog<PaymentMethodAction>(
      context: context,
      builder: (context) => PaymentMethodOptionsDialog(paymentMethod: paymentMethod),
    );

    if (action != null && mounted) {
      switch (action) {
        case PaymentMethodAction.setDefault:
          await _setDefaultPaymentMethod(paymentMethod);
          break;
        case PaymentMethodAction.delete:
          await _deletePaymentMethod(paymentMethod);
          break;
      }
    }
  }
  Future<void> _setDefaultPaymentMethod(PaymentMethod paymentMethod) async {
    try {
      final userId = _getCurrentUserId();
      await _paymentService.setDefaultPaymentMethod(userId, paymentMethod.id);
      await _loadPaymentMethods();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${paymentMethod.displayName} set as default'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set default: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePaymentMethod(PaymentMethod paymentMethod) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete ${paymentMethod.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );    if (confirmed == true) {
      try {
        final userId = _getCurrentUserId();
        await _paymentService.deletePaymentMethod(userId, paymentMethod.id);
        await _loadPaymentMethods();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${paymentMethod.displayName} deleted'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPaymentMethods,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPaymentMethod,
        icon: const Icon(Icons.add),
        label: const Text('Add Payment Method'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading payment methods...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load payment methods',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPaymentMethods,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_paymentMethods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Payment Methods',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add a payment method to start using ParkMe',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addPaymentMethod,
              icon: const Icon(Icons.add),
              label: const Text('Add Payment Method'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _paymentMethods.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader();
        }

        final paymentMethod = _paymentMethods[index - 1];
        return PaymentMethodCard(
          paymentMethod: paymentMethod,
          onTap: () => _showPaymentMethodOptions(paymentMethod),
        );
      },
    );
  }

  Widget _buildHeader() {
    final defaultMethod = _paymentMethods.where((pm) => pm.isDefault).firstOrNull;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Methods',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (defaultMethod != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Default: ${defaultMethod.displayName}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Tap on a payment method to manage it',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
