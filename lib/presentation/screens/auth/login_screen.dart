import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.length != 10) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1)); // mock
    setState(() {
      _loading = false;
      _otpSent = true;
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1)); // mock
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              _buildHeader(),
              const SizedBox(height: 48),
              _buildForm(),
              const SizedBox(height: 32),
              _buildGuestOption(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.movie_filter_rounded,
              color: Colors.white, size: 30),
        ),
        const SizedBox(height: 24),
        Text(
          _otpSent ? 'Verify OTP' : 'Welcome back!',
          style: AppTextStyles.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          _otpSent
              ? '${AppStrings.otpSentTo}+91 ${_phoneController.text}'
              : 'Enter your phone number to continue',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _otpSent ? _buildOtpField() : _buildPhoneField(),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      key: const ValueKey('phone'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.phoneNumber, style: AppTextStyles.labelLarge),
        const SizedBox(height: 10),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          style: AppTextStyles.bodyLarge,
          decoration: const InputDecoration(
            prefixText: '+91  ',
            prefixStyle: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'Gilroy',
              fontSize: 16,
            ),
            hintText: '9876543210',
          ),
          onSubmitted: (_) => _sendOtp(),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _sendOtp,
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text(AppStrings.sendOtp),
        ),
        const SizedBox(height: 24),
        _buildDivider(),
        const SizedBox(height: 24),
        _buildGoogleButton(),
      ],
    );
  }

  Widget _buildOtpField() {
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.enterOtp, style: AppTextStyles.labelLarge),
        const SizedBox(height: 10),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          style: AppTextStyles.bodyLarge.copyWith(
            letterSpacing: 8,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: '------'),
          autofocus: true,
          onSubmitted: (_) => _verifyOtp(),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _verifyOtp,
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text(AppStrings.verifyOtp),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _sendOtp,
            child: const Text(AppStrings.resendOtp),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _otpSent = false),
            child: Text(
              'Change number',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            AppStrings.orContinueWith,
            style: AppTextStyles.caption,
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
      label: const Text(AppStrings.signInWithGoogle),
    );
  }

  Widget _buildGuestOption() {
    return Center(
      child: TextButton(
        onPressed: () => context.go('/home'),
        child: Text(
          AppStrings.continueAsGuest,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
} 