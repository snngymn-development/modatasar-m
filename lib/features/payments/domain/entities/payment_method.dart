enum PaymentMethod {
  creditCard('Credit Card'),
  debitCard('Debit Card'),
  cash('Cash'),
  bankTransfer('Bank Transfer'),
  digitalWallet('Digital Wallet'),
  check('Check'),
  giftCard('Gift Card'),
  other('Other');

  const PaymentMethod(this.displayName);
  final String displayName;
}
