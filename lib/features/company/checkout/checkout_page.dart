import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proven/core/theme/colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.projectTitle,
    required this.developerName,
    required this.price,
    required this.onBack,
    required this.onPaid,
    required this.onBackToMarketplace,
    this.imageUrl,
  });

  final String projectTitle;
  final String developerName;
  final int price;
  final String? imageUrl;

  final VoidCallback onBack;
  final Future<String?> Function(String transactionId) onPaid;
  final VoidCallback onBackToMarketplace;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

enum _PayStatus { idle, processing, failed }

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  _PayStatus _status = _PayStatus.idle;
  String _failureMessage = _declinedMessage;

  static const _declinedMessage = 'Your card was declined. Try another card.';

  @override
  void initState() {
    super.initState();
    _numberController.addListener(_refresh);
    _nameController.addListener(_refresh);
    _expiryController.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _accent => _isDark ? const Color(0xFF7FB3DC) : AppColors.brandNavy;

  Color get _textColor => _isDark ? AppColors.borderOutline : AppColors.textPrimary;

  Color get _secondaryTextColor => _isDark
      ? AppColors.borderOutline.withValues(alpha: 0.7)
      : AppColors.textSecondary;

  Color get _backgroundColor => _isDark ? const Color(0xFF07121C) : AppColors.canvasBackground;

  Color get _elevatedColor => _isDark ? const Color(0xFF132B40) : AppColors.cardSurface;

  Color get _surfaceColor => _isDark ? const Color(0xFF0D1E2D) : AppColors.cardSurface;

  Color get _borderColor => _isDark ? const Color(0xFF2A4A66) : AppColors.borderOutline;

  Color get _errorColor => _isDark ? const Color(0xFFFF8080) : const Color(0xFFC93C3C);

  Color get _successColor => _isDark ? const Color(0xFF4CC38A) : const Color(0xFF14804A);

  String get _priceText {
    final withCommas = widget.price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
    return '$withCommas EGP';
  }

  bool _passesLuhn(String digits) {
    var sum = 0;
    var doubleIt = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);
      if (doubleIt) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      doubleIt = !doubleIt;
    }
    return sum % 10 == 0;
  }

  String? _validateNumber(String? value) {
    final digits = (value ?? '').replaceAll(' ', '');
    if (digits.isEmpty) return 'Card number is required';
    if (digits.length != 16) return 'Card number must have 16 digits';
    if (!_passesLuhn(digits)) return 'Invalid card number';
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Cardholder name is required';
    return null;
  }

  String? _validateExpiry(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Required';

    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(text);
    if (match == null) return 'Use MM/YY';

    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    if (month < 1 || month > 12) return 'Invalid month';

    final now = DateTime.now();
    if (year < now.year || (year == now.year && month < now.month)) {
      return 'Card expired';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < 3) return 'Invalid';
    return null;
  }

  Future<void> _pay() async {
    if (_status == _PayStatus.processing) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _status = _PayStatus.processing);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final digits = _numberController.text.replaceAll(' ', '');
    if (digits == '4000000000000002') {
      _fail(_declinedMessage);
      return;
    }

    final transactionId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';
    final error = await widget.onPaid(transactionId);
    if (!mounted) return;

    if (error != null) {
      _fail(error);
      return;
    }

    setState(() => _status = _PayStatus.idle);
    _showSuccessDialog(transactionId);
  }

  void _fail(String message) {
    setState(() {
      _failureMessage = message;
      _status = _PayStatus.failed;
    });
  }

  void _retry() {
    if (_failureMessage == _declinedMessage) _numberController.clear();
    setState(() => _status = _PayStatus.idle);
  }

  void _showSuccessDialog(String transactionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: _elevatedColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _successColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded, size: 40, color: _successColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Payment successful',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You paid $_priceText',
                    style: TextStyle(fontSize: 14, color: _secondaryTextColor),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Transaction ID',
                    style: TextStyle(fontSize: 13, color: _secondaryTextColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transactionId,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        widget.onBackToMarketplace();
                      },
                      style: _primaryButtonStyle(),
                      child: const Text(
                        'Back to Marketplace',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.brandNavy,
      disabledBackgroundColor: AppColors.brandNavy.withValues(alpha: 0.6),
      foregroundColor: _isDark ? AppColors.borderOutline : Colors.white,
      side: _isDark ? const BorderSide(color: Color(0xFF3F7FB0)) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = _status == _PayStatus.processing;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _elevatedColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: isProcessing ? null : widget.onBack,
          icon: Icon(Icons.arrow_back_rounded, color: _accent),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textColor),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Opacity(
                opacity: isProcessing ? 0.5 : 1,
                child: IgnorePointer(
                  ignoring: isProcessing,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderSummary(),
                      const SizedBox(height: 16),
                      _buildCardPreview(),
                      const SizedBox(height: 20),
                      _buildForm(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 16, color: _accent),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Your card details are not saved.',
                              style: TextStyle(fontSize: 12.5, color: _secondaryTextColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildBottomBar(isProcessing),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: widget.imageUrl != null
                    ? Image.network(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image_outlined, color: _accent),
                      )
                    : Icon(Icons.image_outlined, color: _accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.projectTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.developerName,
                      style: TextStyle(fontSize: 13.5, color: _secondaryTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Project price',
                style: TextStyle(fontSize: 14, color: _secondaryTextColor),
              ),
              Text(
                _priceText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Platform fee (10%) is included',
            style: TextStyle(fontSize: 12.5, color: _secondaryTextColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: _borderColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              Text(
                _priceText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview() {
    const lavender = AppColors.borderOutline;

    final digits = _numberController.text.replaceAll(' ', '').padRight(16, '•');
    final number = '${digits.substring(0, 4)} ${digits.substring(4, 8)} '
        '${digits.substring(8, 12)} ${digits.substring(12, 16)}';

    final name = _nameController.text.trim().isEmpty
        ? 'CARDHOLDER NAME'
        : _nameController.text.trim().toUpperCase();
    final expiry = _expiryController.text.isEmpty ? 'MM/YY' : _expiryController.text;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A4672), AppColors.brandNavy],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3F7FB0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.credit_card_rounded, color: lavender, size: 28),
          const SizedBox(height: 24),
          Text(
            number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: lavender,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: lavender,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                expiry,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: lavender,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Card number'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _numberController,
            validator: _validateNumber,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [_CardNumberFormatter()],
            style: TextStyle(color: _textColor),
            cursorColor: _accent,
            decoration: _fieldDecoration('1234 5678 9012 3456', Icons.credit_card_rounded),
          ),
          const SizedBox(height: 16),
          _buildLabel('Cardholder name'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            validator: _validateName,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            style: TextStyle(color: _textColor),
            cursorColor: _accent,
            decoration: _fieldDecoration('Omar Hassan', Icons.person_outline_rounded),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Expiry'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _expiryController,
                      validator: _validateExpiry,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [_ExpiryFormatter()],
                      style: TextStyle(color: _textColor),
                      cursorColor: _accent,
                      decoration: _fieldDecoration('MM/YY', Icons.calendar_today_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('CVV'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _cvvController,
                      validator: _validateCvv,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      style: TextStyle(color: _textColor),
                      cursorColor: _accent,
                      decoration: _fieldDecoration('•••', Icons.lock_outline_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isProcessing) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: _elevatedColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_status == _PayStatus.failed) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                decoration: BoxDecoration(
                  color: _errorColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _errorColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: _errorColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _failureMessage,
                        style: TextStyle(color: _errorColor, fontSize: 13.5),
                      ),
                    ),
                    TextButton(
                      onPressed: _retry,
                      child: Text(
                        'Retry',
                        style: TextStyle(fontWeight: FontWeight.bold, color: _errorColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isProcessing ? null : _pay,
                style: _primaryButtonStyle(),
                child: isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.borderOutline,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Pay $_priceText',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textColor),
    );
  }

  InputDecoration _fieldDecoration(String hint, IconData icon) {
    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _secondaryTextColor.withValues(alpha: 0.6)),
      prefixIcon: Icon(icon, color: _accent),
      filled: true,
      fillColor: _surfaceColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      errorStyle: TextStyle(color: _errorColor, fontSize: 12),
      border: border(_borderColor, 1),
      enabledBorder: border(_borderColor, 1),
      focusedBorder: border(_accent, 2),
      errorBorder: border(_errorColor, 1),
      focusedErrorBorder: border(_errorColor, 2),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 16) digits = digits.substring(0, 16);

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);

    final text = digits.length >= 3
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}