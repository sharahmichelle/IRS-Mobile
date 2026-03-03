// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upm_drrm_irs_mobile/providers/auth_provider.dart';
import 'package:upm_drrm_irs_mobile/screens/terms_privacy_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/register';
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _suffixCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _clusterCtrl = TextEditingController();
  final _officeCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _bldgNameCtrl = TextEditingController();
  final _zoneCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _showZoneDropdown = false;

  static const Color _primaryRed = Color(0xFFE63946);
  static const Color _darkRed = Color(0xFFD00000);
  final Color _white = const Color(0xFFF8F9FA);
  final Color _textPrimary = const Color(0xFF212529);
  final Color _textSecondary = const Color(0xFF6C757D);
  final Color _textLight = const Color(0xFF9CA3AF);
  final Color _successGreen = const Color(0xFF2A9D8F);

  final LinearGradient _redGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE63946), Color(0xFFD00000)],
  );

  final List<String> _clusterOptions = [
    'Select cluster',
    'PGH',
    'Padre Faura',
    'Pedro Gil',
    'Taft',
    'SHS',
    'Not Applicable'
  ];

  final List<String> _zoneOptions = [
    'Select zone',
    'Zone 1',
    'Zone 2',
    'Zone 3',
    'Zone 4',
    'Zone 5',
    'Zone 6',
    'Zone 7',
    'Zone 8',
    'Zone 9',
    'Zone 10',
    'Zone 11',
    'Zone 12'
  ];

  @override
  void initState() {
    super.initState();
    _clusterCtrl.addListener(_onClusterChanged);
  }

  void _onClusterChanged() {
    setState(() {
      _showZoneDropdown = _clusterCtrl.text == 'PGH';
      if (!_showZoneDropdown) _zoneCtrl.text = '';
    });
  }

  @override
  void dispose() {
    _clusterCtrl.removeListener(_onClusterChanged);
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _suffixCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _clusterCtrl.dispose();
    _officeCtrl.dispose();
    _positionCtrl.dispose();
    _bldgNameCtrl.dispose();
    _zoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _openTermsScreen() async {
    final accepted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const TermsPrivacyScreen(requireAcceptance: true),
      ),
    );
    if (accepted == true) {
      setState(() => _agreeToTerms = true);
    }
  }

  Future<void> _submit(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    if (_clusterCtrl.text == 'Select cluster' || _clusterCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a cluster'),
          backgroundColor: _primaryRed,
        ),
      );
      return;
    }

    if (_clusterCtrl.text == 'PGH' &&
        (_zoneCtrl.text.isEmpty || _zoneCtrl.text == 'Select zone')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a zone for PGH'),
          backgroundColor: _primaryRed,
        ),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: _primaryRed,
          content: const Text(
            'Please read and accept the Terms & Privacy Policy to continue.',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          action: SnackBarAction(
            label: 'Read Now',
            textColor: Colors.white,
            onPressed: _openTermsScreen,
          ),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      final error = await authProvider.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        middleName: _middleNameCtrl.text.trim(),
        suffix: _suffixCtrl.text.trim(),
        cluster: _clusterCtrl.text,
        office: _officeCtrl.text,
        position: _positionCtrl.text,
        bldgName: _bldgNameCtrl.text.trim(),
        zone: _zoneCtrl.text.trim(),
        userType: 1,
      );

      if (error == null) {
        _showSuccessDialog(context);
      } else {
        _showErrorDialog(context, error);
      }
    } catch (e) {
      _showErrorDialog(context, 'An unexpected error occurred. Please try again.');
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded, size: 40, color: _successGreen),
              ),
              const SizedBox(height: 20),
              Text(
                'Registration Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please check your email for verification link before signing in.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        authProvider.verifyEmail();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: _primaryRed, width: 2),
                      ),
                      child: Text(
                        'Resend Email',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _primaryRed,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _redGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context)
                          ..pop()
                          ..pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _primaryRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_rounded, size: 40, color: _primaryRed),
              ),
              const SizedBox(height: 20),
              Text(
                'Registration Failed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _redGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateName(String? v, String fieldName) {
    if (fieldName == 'First Name' || fieldName == 'Last Name') {
      if (v == null || v.trim().isEmpty) return 'Please enter $fieldName';
      if (v.length < 2) return '$fieldName must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter email';
    const pattern = r'^[^@]+@[^@]+\.[^@]+$';
    if (!RegExp(pattern).hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter password';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Include at least one uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Include at least one number';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm password';
    if (v != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  String? _validateRequiredField(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return 'Please enter $fieldName';
    return null;
  }

  String? _validateCluster(String? v) {
    if (v == null || v.isEmpty || v == 'Select cluster')
      return 'Please select a cluster';
    return null;
  }

  String? _validateZone(String? v) {
    if (_showZoneDropdown && (v == null || v.isEmpty || v == 'Select zone'))
      return 'Please select a zone';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: _white,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),

                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/favicon.png',
                            width: 100,
                            height: 100,
                            color: _primaryRed,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.shield_rounded,
                              size: 80,
                              color: _primaryRed,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Register to access the app',
                          style: TextStyle(
                            fontSize: 18,
                            color: _textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 32),

                        _buildMinimalTextField(
                          controller: _firstNameCtrl,
                          label: 'First Name',
                          icon: Icons.person_outline_rounded,
                          hintText: 'Enter first name',
                          validator: (v) => _validateName(v, 'First Name'),
                        ),
                        const SizedBox(height: 16),
                        _buildMinimalTextField(
                          controller: _lastNameCtrl,
                          label: 'Last Name',
                          icon: Icons.person_outline_rounded,
                          hintText: 'Enter last name',
                          validator: (v) => _validateName(v, 'Last Name'),
                        ),
                        const SizedBox(height: 16),
                        _buildMinimalTextField(
                          controller: _middleNameCtrl,
                          label: 'Middle Name (Optional)',
                          icon: Icons.person_outline_rounded,
                          hintText: 'Enter middle name',
                          validator: (_) => null,
                        ),
                        const SizedBox(height: 16),
                        _buildMinimalTextField(
                          controller: _suffixCtrl,
                          label: 'Suffix (Optional)',
                          icon: Icons.credit_card_outlined,
                          hintText: 'Enter suffix',
                          validator: (_) => null,
                        ),
                        const SizedBox(height: 16),
                        _buildMinimalTextField(
                          controller: _emailCtrl,
                          label: 'Email Address',
                          icon: Icons.email_rounded,
                          hintText: 'Enter email address',
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          controller: _clusterCtrl,
                          label: 'Cluster',
                          icon: Icons.account_tree_rounded,
                          hintText: 'Select cluster',
                          options: _clusterOptions,
                          validator: _validateCluster,
                          onChanged: (value) {
                            if (value != null) {
                              _clusterCtrl.text = value;
                              _onClusterChanged();
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_showZoneDropdown) ...[
                          _buildDropdownField(
                            controller: _zoneCtrl,
                            label: 'Zone',
                            icon: Icons.map_rounded,
                            hintText: 'Select zone',
                            options: _zoneOptions,
                            validator: _validateZone,
                          ),
                          const SizedBox(height: 16),
                        ],
                        _buildMinimalTextField(
                          controller: _officeCtrl,
                          label: 'Office/College',
                          icon: Icons.business_rounded,
                          hintText: 'Enter office or college',
                          validator: (v) =>
                              _validateRequiredField(v, 'Office/College'),
                        ),
                        const SizedBox(height: 16),
                        _buildMinimalTextField(
                          controller: _bldgNameCtrl,
                          label: 'Building Name',
                          icon: Icons.apartment_rounded,
                          hintText: 'Enter building name',
                          validator: (v) =>
                              _validateRequiredField(v, 'Building Name'),
                        ),
                        const SizedBox(height: 16),
                        _buildMinimalTextField(
                          controller: _positionCtrl,
                          label: 'Position',
                          icon: Icons.work_outline_rounded,
                          hintText: 'Enter position',
                          validator: (v) =>
                              _validateRequiredField(v, 'Position'),
                        ),
                        const SizedBox(height: 16),
                        _buildMinimalTextField(
                          controller: _passwordCtrl,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          hintText: 'Enter password',
                          obscureText: _obscurePassword,
                          validator: _validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _textSecondary,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMinimalTextField(
                          controller: _confirmPasswordCtrl,
                          label: 'Confirm Password',
                          icon: Icons.lock_reset_rounded,
                          hintText: 'Confirm password',
                          obscureText: _obscureConfirmPassword,
                          validator: _validateConfirmPassword,
                          onFieldSubmitted: (_) => _submit(context),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _textSecondary,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildPasswordRequirements(),
                        const SizedBox(height: 24),

                        // ── Terms checkbox row ───────────────────────────────
                        _buildTermsRow(),
                        const SizedBox(height: 32),

                        // Create Account button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient:
                                  authProvider.isLoading ? null : _redGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: authProvider.isLoading
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: _primaryRed.withOpacity(0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                            ),
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () => _submit(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: authProvider.isLoading
                                    ? _textLight.withOpacity(0.3)
                                    : Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: authProvider.isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: _textSecondary,
                                      ),
                                    )
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sign in link
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(
                                      color: _textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Sign In',
                                    style: TextStyle(
                                      color: _primaryRed,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading overlay
                if (authProvider.isLoading)
                  Container(color: Colors.black.withOpacity(0.3)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Terms row: plain checkbox + inline tappable link ─────────────────────────
  Widget _buildTermsRow() {
    return GestureDetector(
      onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
      behavior: HitTestBehavior.translucent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _agreeToTerms ? _primaryRed : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _agreeToTerms ? _primaryRed : _textLight.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: _agreeToTerms
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),

          // Label with tappable link
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: _openTermsScreen,
                      child: Text(
                        'Terms & Privacy Policy',
                        style: TextStyle(
                          color: _primaryRed,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: _primaryRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    String? hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: _textLight, fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: _textSecondary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: _textLight.withOpacity(0.3), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: _textLight.withOpacity(0.3), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryRed, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryRed, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryRed, width: 2),
            ),
            errorStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    required List<String> options,
    String? Function(String?)? validator,
    ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: controller.text.isNotEmpty && options.contains(controller.text)
              ? controller.text
              : null,
          hint: Text(hintText,
              style: TextStyle(color: _textLight, fontSize: 15)),
          items: options
              .map((value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) controller.text = newValue;
            onChanged?.call(newValue);
          },
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: _textSecondary),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: _textLight.withOpacity(0.3), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: _textLight.withOpacity(0.3), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryRed, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryRed, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryRed, width: 2),
            ),
          ),
          style: TextStyle(
            color: _textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _passwordCtrl.text;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _textLight.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          _buildRequirementRow('At least 8 characters', password.length >= 8),
          const SizedBox(height: 6),
          _buildRequirementRow(
              'One uppercase letter', RegExp(r'[A-Z]').hasMatch(password)),
          const SizedBox(height: 6),
          _buildRequirementRow(
              'One number', RegExp(r'[0-9]').hasMatch(password)),
          const SizedBox(height: 6),
          _buildRequirementRow(
            'Passwords match',
            _confirmPasswordCtrl.text.isNotEmpty &&
                _confirmPasswordCtrl.text == _passwordCtrl.text,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isMet ? _successGreen.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isMet ? _successGreen : _textLight.withOpacity(0.5),
            ),
          ),
          child: isMet
              ? Icon(Icons.check_rounded, size: 10, color: _successGreen)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isMet ? _successGreen : _textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}