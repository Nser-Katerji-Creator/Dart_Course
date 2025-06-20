import 'package:flutter/material.dart';
import '../models/payment_method.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final VoidCallback? onTap;

  const PaymentMethodCard({
    super.key,
    required this.paymentMethod,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildPaymentMethodIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            paymentMethod.displayName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (paymentMethod.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'DEFAULT',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSubtitle(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.more_vert,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildPaymentMethodIcon() {
    IconData iconData;
    Color iconColor;

    switch (paymentMethod.type) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        iconData = _getCardIcon();
        iconColor = _getCardColor();
        break;
      case PaymentMethodType.paypal:
        iconData = Icons.account_balance_wallet;
        iconColor = Colors.blue.shade600;
        break;
      case PaymentMethodType.googlePay:
        iconData = Icons.wallet;
        iconColor = Colors.green.shade600;
        break;
      case PaymentMethodType.applePay:
        iconData = Icons.phone_iphone;
        iconColor = Colors.black;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        size: 24,
        color: iconColor,
      ),
    );
  }

  IconData _getCardIcon() {
    switch (paymentMethod.cardBrand) {
      case CardBrand.visa:
        return Icons.credit_card;
      case CardBrand.mastercard:
        return Icons.credit_card;
      case CardBrand.amex:
        return Icons.credit_card;
      case CardBrand.discover:
        return Icons.credit_card;
      case CardBrand.unionpay:
        return Icons.credit_card;
      case CardBrand.unknown:
      case null:
        return Icons.credit_card;
    }
  }

  Color _getCardColor() {
    switch (paymentMethod.cardBrand) {
      case CardBrand.visa:
        return Colors.blue.shade700;
      case CardBrand.mastercard:
        return Colors.red.shade700;
      case CardBrand.amex:
        return Colors.green.shade700;
      case CardBrand.discover:
        return Colors.orange.shade700;
      case CardBrand.unionpay:
        return Colors.purple.shade700;
      case CardBrand.unknown:
      case null:
        return Colors.grey.shade600;
    }
  }

  String _getSubtitle() {
    switch (paymentMethod.type) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        final expiry = paymentMethod.expiryMonth != null && paymentMethod.expiryYear != null
            ? 'Expires ${paymentMethod.expiryMonth}/${paymentMethod.expiryYear}'
            : '';
        return expiry;
      case PaymentMethodType.paypal:
        return paymentMethod.email ?? 'PayPal Account';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
    }
  }
}
