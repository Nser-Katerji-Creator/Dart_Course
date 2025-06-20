import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_method.dart';
import 'payment_service.dart';

class LocalPaymentService implements PaymentService {
  static const String _paymentMethodsKey = 'payment_methods';
  
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
      
      final prefs = await _prefs;
      final String? paymentMethodsJson = prefs.getString('${_paymentMethodsKey}_$userId');
      
      if (paymentMethodsJson == null || paymentMethodsJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> decodedList = json.decode(paymentMethodsJson);
      return decodedList
          .map((item) => PaymentMethod.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw PaymentException('Failed to load payment methods: ${e.toString()}');
    }
  }
  @override
  Future<PaymentMethod> addPaymentMethod(String userId, PaymentMethodRequest request) async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate processing time
      
      final currentMethods = await getPaymentMethods(userId);
        // Create new payment method
      final String? lastFour;
      if (request.cardNumber != null) {
        final cleanCardNumber = request.cardNumber!.replaceAll(RegExp(r'[^\d]'), '');
        lastFour = cleanCardNumber.length >= 4 
            ? cleanCardNumber.substring(cleanCardNumber.length - 4)
            : null;
      } else {
        lastFour = null;
      }
      
      final paymentMethod = PaymentMethod(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: request.type,
        token: 'tok_${DateTime.now().millisecondsSinceEpoch}',
        lastFourDigits: lastFour,
        cardBrand: _detectCardBrand(request.cardNumber),
        expiryMonth: request.expiryMonth,
        expiryYear: request.expiryYear,
        holderName: request.holderName,
        email: request.paypalEmail,
        isDefault: currentMethods.isEmpty, // First method becomes default
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: request.metadata,
      );

      // Add to current list
      currentMethods.add(paymentMethod);
      
      // Save to persistent storage
      await _savePaymentMethods(userId, currentMethods);
      
      return paymentMethod;
    } catch (e) {
      throw PaymentException('Failed to add payment method: ${e.toString()}');
    }
  }
  @override
  Future<void> deletePaymentMethod(String userId, String paymentMethodId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final currentMethods = await getPaymentMethods(userId);
      
      // Find and remove the payment method
      final removedMethod = currentMethods.where((pm) => pm.id == paymentMethodId).firstOrNull;
      currentMethods.removeWhere((pm) => pm.id == paymentMethodId);
      
      // If we removed the default method, set another as default
      if (removedMethod?.isDefault == true && currentMethods.isNotEmpty) {
        currentMethods[0] = currentMethods[0].copyWith(isDefault: true);
      }
      
      await _savePaymentMethods(userId, currentMethods);
    } catch (e) {
      throw PaymentException('Failed to delete payment method: ${e.toString()}');
    }
  }
  @override
  Future<PaymentMethod> setDefaultPaymentMethod(String userId, String paymentMethodId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final currentMethods = await getPaymentMethods(userId);
      
      // Reset all to non-default
      for (int i = 0; i < currentMethods.length; i++) {
        currentMethods[i] = currentMethods[i].copyWith(isDefault: false);
      }
      
      // Set the selected one as default
      final index = currentMethods.indexWhere((pm) => pm.id == paymentMethodId);
      if (index == -1) {
        throw PaymentException('Payment method not found');
      }
      
      currentMethods[index] = currentMethods[index].copyWith(
        isDefault: true,
        updatedAt: DateTime.now(),
      );
      
      await _savePaymentMethods(userId, currentMethods);
      return currentMethods[index];
    } catch (e) {
      throw PaymentException('Failed to set default payment method: ${e.toString()}');
    }
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
    return true; // Success
  }

  Future<void> _savePaymentMethods(String userId, List<PaymentMethod> paymentMethods) async {
    try {
      final prefs = await _prefs;
      final jsonList = paymentMethods.map((pm) => pm.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString('${_paymentMethodsKey}_$userId', jsonString);
    } catch (e) {
      throw PaymentException('Failed to save payment methods: ${e.toString()}');
    }
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

  // Utility method to clear all stored payment methods (for testing/debugging)
  Future<void> clearAllPaymentMethods(String userId) async {
    final prefs = await _prefs;
    await prefs.remove('${_paymentMethodsKey}_$userId');
  }
}
