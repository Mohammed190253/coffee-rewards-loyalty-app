import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../data/models/registration_request.dart';
import '../data/repositories/auth_repository_impl.dart';

/// Simulated OTP for demo / development verification flow.
const String kDemoVerificationCode = '1234';

class VerificationScreen extends StatefulWidget {
  final RegistrationRequest registrationRequest;

  const VerificationScreen({
    super.key,
    required this.registrationRequest,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _digitControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final _authRepository = AuthRepositoryImpl();

  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final controller in _digitControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _enteredCode =>
      _digitControllers.map((controller) => controller.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      _digitControllers[index].text = value.substring(value.length - 1);
      _digitControllers[index].selection = const TextSelection.collapsed(offset: 1);
    }

    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() => _errorMessage = null);
  }

  Future<void> _handleVerifyAndCreateAccount() async {
    final code = _enteredCode;

    if (code.length != 4) {
      setState(() => _errorMessage = 'Please enter the full 4-digit verification code.');
      return;
    }

    if (code != kDemoVerificationCode) {
      setState(() => _errorMessage = 'Invalid verification code. Please try again.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.registerCustomer(widget.registrationRequest);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please sign in.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maskedPhone = widget.registrationRequest.phoneNumber;

    return Scaffold(
      backgroundColor: AppColors.primaryTeal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.astrolabeGold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.astrolabeGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.astrolabeGold.withOpacity(0.35)),
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    color: AppColors.astrolabeGold,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Verify Your Number',
                  style: TextStyle(
                    color: AppColors.astrolabeGold,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'A 4-digit verification code has been sent to your phone number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  maskedPhone,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 62,
                      child: TextField(
                        controller: _digitControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.astrolabeGold.withOpacity(0.25),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.astrolabeGold,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (value) => _onDigitChanged(index, value),
                      ),
                    );
                  }),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                _isVerifying
                    ? const CircularProgressIndicator(color: AppColors.astrolabeGold)
                    : AstrolabeButton(
                        label: 'VERIFY & CREATE ACCOUNT',
                        onPressed: _handleVerifyAndCreateAccount,
                      ),
                const SizedBox(height: 20),
                Text(
                  'Demo code: $kDemoVerificationCode',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
