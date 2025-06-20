import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/payment_method.dart';
import '../services/payment_service.dart';
import '../widgets/card_number_formatter.dart';
import '../widgets/expiry_date_formatter.dart';

class AddPaymentMethodDialog extends StatefulWidget {
  final PaymentService paymentService;
  final String userId;

  const AddPaymentMethodDialog({
    super.key,
    required this.paymentService,
    required this.userId,
  });

  @override
  State<AddPaymentMethodDialog> createState() => _AddPaymentMethodDialogState();
}

class _AddPaymentMethodDialogState extends State<AddPaymentMethodDialog> {
  PaymentMethodType _selectedType = PaymentMethodType.creditCard;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildPaymentMethodSelector(),
                    const SizedBox(height: 24),
                    _buildPaymentMethodForm(),
                  ],
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Add Payment Method',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildPaymentMethodOption(
              PaymentMethodType.creditCard,
              'Credit Card',
              Icons.credit_card,
              Colors.blue.shade600,
            ),
            _buildPaymentMethodOption(
              PaymentMethodType.debitCard,
              'Debit Card',
              Icons.credit_card,
              Colors.green.shade600,
            ),
            _buildPaymentMethodOption(
              PaymentMethodType.paypal,
              'PayPal',
              Icons.account_balance_wallet,
              Colors.blue.shade600,
            ),
            _buildPaymentMethodOption(
              PaymentMethodType.googlePay,
              'Google Pay',
              Icons.wallet,
              Colors.green.shade600,
            ),
            _buildPaymentMethodOption(
              PaymentMethodType.applePay,
              'Apple Pay',
              Icons.phone_iphone,
              Colors.black,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption(
    PaymentMethodType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Theme.of(context).primaryColor : color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodForm() {
    switch (_selectedType) {      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return CreditCardForm(
          paymentService: widget.paymentService,
          userId: widget.userId,
          isDebitCard: _selectedType == PaymentMethodType.debitCard,
          onSuccess: (paymentMethod) => Navigator.pop(context, paymentMethod),
          onLoading: (loading) => setState(() => _isLoading = loading),
        );
      case PaymentMethodType.paypal:
        return PayPalForm(
          paymentService: widget.paymentService,
          userId: widget.userId,
          onSuccess: (paymentMethod) => Navigator.pop(context, paymentMethod),
          onLoading: (loading) => setState(() => _isLoading = loading),
        );
      case PaymentMethodType.googlePay:
        return GooglePayForm(
          paymentService: widget.paymentService,
          userId: widget.userId,
          onSuccess: (paymentMethod) => Navigator.pop(context, paymentMethod),
          onLoading: (loading) => setState(() => _isLoading = loading),
        );
      case PaymentMethodType.applePay:
        return ApplePayForm(
          paymentService: widget.paymentService,
          userId: widget.userId,
          onSuccess: (paymentMethod) => Navigator.pop(context, paymentMethod),
          onLoading: (loading) => setState(() => _isLoading = loading),
        );
    }
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// Credit Card Form Component
class CreditCardForm extends StatefulWidget {
  final PaymentService paymentService;
  final String userId;
  final bool isDebitCard;
  final Function(PaymentMethod) onSuccess;
  final Function(bool) onLoading;

  const CreditCardForm({
    super.key,
    required this.paymentService,
    required this.userId,
    required this.isDebitCard,
    required this.onSuccess,
    required this.onLoading,
  });

  @override
  State<CreditCardForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              prefixIcon: Icon(Icons.credit_card),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CardNumberFormatter(),
            ],
            validator: _validateCardNumber,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _expiryController,
                  decoration: const InputDecoration(
                    labelText: 'MM/YY',
                    hintText: '12/25',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ExpiryDateFormatter(),
                  ],
                  validator: _validateExpiry,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    prefixIcon: Icon(Icons.security),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: _validateCVV,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _holderNameController,
            decoration: const InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'John Doe',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: _validateHolderName,
          ),
          const SizedBox(height: 24),
          Text(
            'Billing Address',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateRequired,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateRequired,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressLine1Controller,
            decoration: const InputDecoration(
              labelText: 'Address Line 1',
              border: OutlineInputBorder(),
            ),
            validator: _validateRequired,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressLine2Controller,
            decoration: const InputDecoration(
              labelText: 'Address Line 2 (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateRequired,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateRequired,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Postal Code',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateRequired,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateRequired,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Add ${widget.isDebitCard ? 'Debit' : 'Credit'} Card'),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) return 'Card number is required';
    final cleanNumber = value.replaceAll(' ', '');
    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return 'Invalid card number';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.isEmpty) return 'Expiry date is required';
    if (value.length != 5) return 'Invalid expiry date';
    
    final parts = value.split('/');
    if (parts.length != 2) return 'Invalid expiry date';
    
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) return 'Invalid expiry date';
    if (month < 1 || month > 12) return 'Invalid month';
    
    final currentYear = DateTime.now().year % 100;
    final currentMonth = DateTime.now().month;
    
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }
    
    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) return 'CVV is required';
    if (value.length < 3 || value.length > 4) return 'Invalid CVV';
    return null;
  }

  String? _validateHolderName(String? value) {
    if (value == null || value.isEmpty) return 'Cardholder name is required';
    return null;
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    widget.onLoading(true);

    try {
      final expiryParts = _expiryController.text.split('/');
      final billingAddress = BillingAddress(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text.isEmpty ? null : _addressLine2Controller.text,
        city: _cityController.text,
        state: _stateController.text,
        postalCode: _postalCodeController.text,
        countryCode: _countryController.text,
      );

      final request = PaymentMethodRequest(
        type: widget.isDebitCard ? PaymentMethodType.debitCard : PaymentMethodType.creditCard,
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        expiryMonth: expiryParts[0],
        expiryYear: expiryParts[1],
        cvv: _cvvController.text,
        holderName: _holderNameController.text,
        billingAddress: billingAddress,
      );

      final paymentMethod = await widget.paymentService.addPaymentMethod(widget.userId, request);
      widget.onSuccess(paymentMethod);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add card: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      widget.onLoading(false);
    }
  }
}

// PayPal Form Component
class PayPalForm extends StatelessWidget {
  final PaymentService paymentService;
  final String userId;
  final Function(PaymentMethod) onSuccess;
  final Function(bool) onLoading;

  const PayPalForm({
    super.key,
    required this.paymentService,
    required this.userId,
    required this.onSuccess,
    required this.onLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.account_balance_wallet,
          size: 64,
          color: Colors.blue,
        ),
        const SizedBox(height: 24),
        Text(
          'PayPal Integration',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'You will be redirected to PayPal to authenticate your account securely.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _authenticateWithPayPal(context),
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Connect PayPal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _authenticateWithPayPal(BuildContext context) async {
    onLoading(true);

    try {
      // Simulate PayPal OAuth flow
      await Future.delayed(const Duration(seconds: 2));
        final request = PaymentMethodRequest(
        type: PaymentMethodType.paypal,
        paypalEmail: 'user@example.com', // This would come from PayPal OAuth
      );

      final paymentMethod = await paymentService.addPaymentMethod(userId, request);
      onSuccess(paymentMethod);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect PayPal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      onLoading(false);
    }
  }
}

// Google Pay Form Component
class GooglePayForm extends StatelessWidget {
  final PaymentService paymentService;
  final String userId;
  final Function(PaymentMethod) onSuccess;
  final Function(bool) onLoading;

  const GooglePayForm({
    super.key,
    required this.paymentService,
    required this.userId,
    required this.onSuccess,
    required this.onLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.wallet,
          size: 64,
          color: Colors.green,
        ),
        const SizedBox(height: 24),
        Text(
          'Google Pay',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Use your existing Google Pay account for quick and secure payments.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _setupGooglePay(context),
            icon: const Icon(Icons.wallet),
            label: const Text('Setup Google Pay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _setupGooglePay(BuildContext context) async {
    onLoading(true);

    try {
      // Simulate Google Pay setup
      await Future.delayed(const Duration(seconds: 2));
        final request = PaymentMethodRequest(
        type: PaymentMethodType.googlePay,
        metadata: {'device_id': 'mock_device_id'},
      );

      final paymentMethod = await paymentService.addPaymentMethod(userId, request);
      onSuccess(paymentMethod);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to setup Google Pay: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      onLoading(false);
    }
  }
}

// Apple Pay Form Component
class ApplePayForm extends StatelessWidget {
  final PaymentService paymentService;
  final String userId;
  final Function(PaymentMethod) onSuccess;
  final Function(bool) onLoading;

  const ApplePayForm({
    super.key,
    required this.paymentService,
    required this.userId,
    required this.onSuccess,
    required this.onLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.phone_iphone,
          size: 64,
          color: Colors.black,
        ),
        const SizedBox(height: 24),
        Text(
          'Apple Pay',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Use Touch ID, Face ID, or your passcode to pay securely with Apple Pay.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _setupApplePay(context),
            icon: const Icon(Icons.phone_iphone),
            label: const Text('Setup Apple Pay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _setupApplePay(BuildContext context) async {
    onLoading(true);

    try {
      // Simulate Apple Pay setup
      await Future.delayed(const Duration(seconds: 2));
        final request = PaymentMethodRequest(
        type: PaymentMethodType.applePay,
        metadata: {'device_id': 'mock_device_id'},
      );

      final paymentMethod = await paymentService.addPaymentMethod(userId, request);
      onSuccess(paymentMethod);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to setup Apple Pay: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      onLoading(false);
    }
  }
}
