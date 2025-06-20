import 'package:flutter/material.dart';
import '../models/payment_method.dart';

enum PaymentMethodAction {
  setDefault,
  delete,
}

class PaymentMethodOptionsDialog extends StatelessWidget {
  final PaymentMethod paymentMethod;

  const PaymentMethodOptionsDialog({
    super.key,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPaymentMethodIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paymentMethod.displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        paymentMethod.typeDisplayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
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
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            if (!paymentMethod.isDefault)
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('Set as Default'),
                subtitle: const Text('Use this payment method by default'),
                onTap: () => Navigator.pop(context, PaymentMethodAction.setDefault),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Remove this payment method'),
              onTap: () => Navigator.pop(context, PaymentMethodAction.delete),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
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
        iconData = Icons.credit_card;
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
}
