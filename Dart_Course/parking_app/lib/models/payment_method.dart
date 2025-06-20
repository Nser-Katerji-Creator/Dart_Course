enum PaymentMethodType {
  creditCard,
  debitCard,
  paypal,
  googlePay,
  applePay,
}

enum CardBrand {
  visa,
  mastercard,
  amex,
  discover,
  unionpay,
  unknown,
}

class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String? lastFourDigits;
  final CardBrand? cardBrand;
  final String? expiryMonth;
  final String? expiryYear;
  final String? holderName;
  final String? email; // For PayPal
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String token; // Tokenized payment method from payment processor
  final Map<String, dynamic>? metadata;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.token,
    this.lastFourDigits,
    this.cardBrand,
    this.expiryMonth,
    this.expiryYear,
    this.holderName,
    this.email,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  PaymentMethod copyWith({
    String? id,
    PaymentMethodType? type,
    String? lastFourDigits,
    CardBrand? cardBrand,
    String? expiryMonth,
    String? expiryYear,
    String? holderName,
    String? email,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? token,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      cardBrand: cardBrand ?? this.cardBrand,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      holderName: holderName ?? this.holderName,
      email: email ?? this.email,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      token: token ?? this.token,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'lastFourDigits': lastFourDigits,
      'cardBrand': cardBrand?.name,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'holderName': holderName,
      'email': email,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'token': token,
      'metadata': metadata,
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      type: PaymentMethodType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentMethodType.creditCard,
      ),
      lastFourDigits: json['lastFourDigits'] as String?,
      cardBrand: json['cardBrand'] != null
          ? CardBrand.values.firstWhere(
              (e) => e.name == json['cardBrand'],
              orElse: () => CardBrand.unknown,
            )
          : null,
      expiryMonth: json['expiryMonth'] as String?,
      expiryYear: json['expiryYear'] as String?,
      holderName: json['holderName'] as String?,
      email: json['email'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      token: json['token'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  String get displayName {
    switch (type) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        final brand = cardBrand?.name.toUpperCase() ?? 'CARD';
        return '$brand •••• $lastFourDigits';
      case PaymentMethodType.paypal:
        return 'PayPal ${email ?? ''}';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case PaymentMethodType.creditCard:
        return 'Credit Card';
      case PaymentMethodType.debitCard:
        return 'Debit Card';
      case PaymentMethodType.paypal:
        return 'PayPal';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethod && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PaymentMethod(id: $id, type: $type, displayName: $displayName, isDefault: $isDefault)';
  }
}

class BillingAddress {
  final String firstName;
  final String lastName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String countryCode;

  const BillingAddress({
    required this.firstName,
    required this.lastName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.countryCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'countryCode': countryCode,
    };
  }

  factory BillingAddress.fromJson(Map<String, dynamic> json) {
    return BillingAddress(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      countryCode: json['countryCode'] as String,
    );
  }

  @override
  String toString() {
    return '$addressLine1${addressLine2 != null ? ', $addressLine2' : ''}, $city, $state $postalCode';
  }
}
