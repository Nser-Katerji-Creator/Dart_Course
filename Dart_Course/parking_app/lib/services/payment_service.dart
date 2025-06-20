import '../models/payment_method.dart';

abstract class PaymentService {
  Future<List<PaymentMethod>> getPaymentMethods(String userId);
  Future<PaymentMethod> addPaymentMethod(PaymentMethodRequest request);
  Future<void> deletePaymentMethod(String paymentMethodId);
  Future<PaymentMethod> setDefaultPaymentMethod(String paymentMethodId);
  Future<PaymentIntent> createPaymentIntent(PaymentIntentRequest request);
  Future<bool> processPayment(String paymentIntentId, String paymentMethodId);
}

class PaymentMethodRequest {
  final PaymentMethodType type;
  final String? cardNumber;
  final String? expiryMonth;
  final String? expiryYear;
  final String? cvv;
  final String? holderName;
  final BillingAddress? billingAddress;
  final String? paypalEmail;
  final Map<String, dynamic>? metadata;

  const PaymentMethodRequest({
    required this.type,
    this.cardNumber,
    this.expiryMonth,
    this.expiryYear,
    this.cvv,
    this.holderName,
    this.billingAddress,
    this.paypalEmail,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'cardNumber': cardNumber,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
      'holderName': holderName,
      'billingAddress': billingAddress?.toJson(),
      'paypalEmail': paypalEmail,
      'metadata': metadata,
    };
  }
}

class PaymentIntentRequest {
  final double amount;
  final String currency;
  final String description;
  final String userId;
  final Map<String, dynamic>? metadata;

  const PaymentIntentRequest({
    required this.amount,
    required this.currency,
    required this.description,
    required this.userId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'description': description,
      'userId': userId,
      'metadata': metadata,
    };
  }
}

class PaymentIntent {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final String clientSecret;
  final Map<String, dynamic>? metadata;

  const PaymentIntent({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.clientSecret,
    this.metadata,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      clientSecret: json['clientSecret'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class PaymentException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  const PaymentException(this.message, {this.code, this.details});

  @override
  String toString() => 'PaymentException: $message';
}

// Mock implementation for development
class MockPaymentService implements PaymentService {
  final List<PaymentMethod> _paymentMethods = [];

  @override
  Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_paymentMethods);
  }

  @override
  Future<PaymentMethod> addPaymentMethod(PaymentMethodRequest request) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate payment processor tokenization
    final paymentMethod = PaymentMethod(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: request.type,
      token: 'tok_${DateTime.now().millisecondsSinceEpoch}',
      lastFourDigits: request.cardNumber?.substring(request.cardNumber!.length - 4),
      cardBrand: _detectCardBrand(request.cardNumber),
      expiryMonth: request.expiryMonth,
      expiryYear: request.expiryYear,
      holderName: request.holderName,
      email: request.paypalEmail,
      isDefault: _paymentMethods.isEmpty,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: request.metadata,
    );

    _paymentMethods.add(paymentMethod);
    return paymentMethod;
  }

  @override
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _paymentMethods.removeWhere((pm) => pm.id == paymentMethodId);
  }

  @override
  Future<PaymentMethod> setDefaultPaymentMethod(String paymentMethodId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Reset all to non-default
    for (int i = 0; i < _paymentMethods.length; i++) {
      _paymentMethods[i] = _paymentMethods[i].copyWith(isDefault: false);
    }
    
    // Set the selected one as default
    final index = _paymentMethods.indexWhere((pm) => pm.id == paymentMethodId);
    if (index != -1) {
      _paymentMethods[index] = _paymentMethods[index].copyWith(isDefault: true);
      return _paymentMethods[index];
    }
    
    throw PaymentException('Payment method not found');
  }

  @override
  Future<PaymentIntent> createPaymentIntent(PaymentIntentRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return PaymentIntent(
      id: 'pi_${DateTime.now().millisecondsSinceEpoch}',
      amount: request.amount,
      currency: request.currency,
      status: 'requires_payment_method',
      clientSecret: 'pi_${DateTime.now().millisecondsSinceEpoch}_secret',
      metadata: request.metadata,
    );
  }

  @override
  Future<bool> processPayment(String paymentIntentId, String paymentMethodId) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate payment processing
    // In real implementation, this would communicate with payment processor
    return true; // Success
  }

  CardBrand? _detectCardBrand(String? cardNumber) {
    if (cardNumber == null || cardNumber.isEmpty) return null;
    
    // Remove spaces and non-digits
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanNumber.startsWith('4')) return CardBrand.visa;
    if (cleanNumber.startsWith(RegExp(r'5[1-5]')) || 
        cleanNumber.startsWith(RegExp(r'2[2-7]'))) return CardBrand.mastercard;
    if (cleanNumber.startsWith(RegExp(r'3[47]'))) return CardBrand.amex;
    if (cleanNumber.startsWith('6')) return CardBrand.discover;
    if (cleanNumber.startsWith(RegExp(r'62|81'))) return CardBrand.unionpay;
    
    return CardBrand.unknown;
  }
}
