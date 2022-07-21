/// Data class for EPC-QR codes for SEPA credit transfers (SCT).
///
/// Includes the account information of the beneficiary (the one receiving the money),
/// as well as optional remittance information/payment reference.
class EpcQrData {
  /// The full name of the beneficiary.
  ///
  /// Required for all transfers.
  final String name;

  /// The IBAN of the beneficiary account.
  ///
  /// Required for all transfers.
  final String iban;

  /// The BIC of the beneficiary account bank.
  ///
  /// Optional for transfers within the European Economic Area.
  /// Technically still mandatory for EPC-QR version 001.
  final String bic;

  final num amount;

  /// The SEPA purpose code.
  ///
  /// Optional, 4 letters.
  final String purpose;

  /// Structured creditor reference.
  ///
  /// Optional structured payment reference (remittance information).
  /// Max. 35 symbols.
  /// If this is provided, [referenceText] should be empty.
  final String reference;

  /// Unstructured creditor reference.
  ///
  /// Optional unstructured payment reference (remittance information).
  /// Max. 140 symbols.
  /// If this is provided, [reference] should be empty.
  final String referenceText;

  /// Beneficiary to originator information.
  ///
  /// Optional message for the
  final String note;

  /// EPC-QR version.
  ///
  /// Version 002 allows omitting the BIC for transfers
  /// within the European Economic Area.
  final String version;

  /// Charset to be used.
  ///
  /// '1' is UTF-8.
  final String charset;

  /// The kind of transfer.
  ///
  /// Currently only supports SCT (SEPA credit transfer).
  static const identificationCode = 'SCT';

  EpcQrData({
    required this.name,
    required this.iban,
    this.bic = '',
    this.amount = 0,
    this.purpose = '',
    this.reference = '',
    this.referenceText = '',
    this.note = '',
    this.version = '001',
    this.charset = '1',
  }) : assert(reference.isEmpty || referenceText.isEmpty);

  factory EpcQrData.fromMap(Map<String, dynamic> data) {
    dynamic amountData = data['amount'];
    num? amount;
    if (amountData is num?) {
      amount = amountData;
    } else if (amountData is String?) {
      amount = num.tryParse(amountData?.replaceAll(',', '.') ?? '');
    }

    String? referenceText;
    if ((data['reference'] as String? ?? '').isEmpty) {
      referenceText = data['referenceText'];
    }

    return EpcQrData(
      name: data['name'],
      iban: data['iban'],
      bic: data['bic'] ?? '',
      amount: amount ?? 0,
      purpose: data['purpose'] ?? '',
      reference: data['reference'] ?? '',
      referenceText: referenceText ?? '',
      note: data['note'] ?? '',
    );
  }

  String get qrDataString => """BCD
$version
$charset
$identificationCode
$bic
$name
$iban
EUR${amount.toStringAsFixed(2)}
$purpose
$reference
${reference.isEmpty ? referenceText : ''}
$note
"""
      .trimRight();
}
