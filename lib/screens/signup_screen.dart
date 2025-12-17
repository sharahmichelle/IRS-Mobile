// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upm_drrm_irs_mobile/providers/auth_provider.dart';

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
  final _upCampusCtrl = TextEditingController();
  final _officeCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _bldgNameCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  // Modern color scheme matching login screen
  final Color primaryColor = Color(0xFFA11D1C);
  final Color backgroundColor = Color(0xFFF8FAFC);
  final Color surfaceColor = Colors.white;
  final Color textPrimary = Color(0xFF1E293B);
  final Color textSecondary = Color(0xFF64748B);
  final Color accentColor = Color(0xFF0EA5E9);
  final Color successColor = Color(0xFF10B981);
  final Color warningColor = Color(0xFFF59E0B);
  final Color errorColor = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    // Set default values for dropdowns
    _upCampusCtrl.text = 'UPM';
    _officeCtrl.text = 'DRRM-H';
    _positionCtrl.text = 'Encoder';
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _suffixCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _upCampusCtrl.dispose();
    _officeCtrl.dispose();
    _positionCtrl.dispose();
    _bldgNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    if (!_agreeToTerms) {
      _showTermsAlert();
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    try {
      // Call the sign-up API through the provider
      final error = await authProvider.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        middleName: _middleNameCtrl.text.trim(),
        suffix: _suffixCtrl.text.trim(),
        upCampus: _upCampusCtrl.text,
        office: _officeCtrl.text,
        position: _positionCtrl.text,
        bldgName: _bldgNameCtrl.text.trim(),
        userType: 1, // Default to Encoder role
      );

      if (error == null) {
        // Registration successful
        _showSuccessDialog(context);
      } else {
        // Show error message
        _showErrorDialog(context, error);
      }
    } catch (e) {
      _showErrorDialog(
        context,
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 40,
                  color: successColor,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "Registration Successful!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                "Your account has been created successfully. Please check your email for verification link before signing in.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        authProvider.verifyEmail();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: primaryColor, width: 2),
                      ),
                      child: Text(
                        "Resend Email",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                          ..pop()
                          ..pop(); // Go back to login screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_rounded, size: 40, color: errorColor),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "Registration Failed",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Error Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Try Again",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
    // Middle name and suffix are optional, no validation needed
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
    if (!RegExp(r'[A-Z]').hasMatch(v))
      return 'Include at least one uppercase letter';
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

  void _showTermsAlert() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: warningColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: 40,
                  color: warningColor,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "Terms Required",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                "Please agree to the Terms & Conditions and Privacy Policy to create your account.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Got It",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final bool isLoading = authProvider.isLoading;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Header with gradient matching login screen
                      _buildSignUpHeader(),
                      const SizedBox(height: 32),

                      // Sign Up Form Card
                      _buildSignUpFormCard(authProvider),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black38,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignUpHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo with modern container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background pattern
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.1),
                        Color(0xFFC62828).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Center(
                  child: Image.asset(
                    'assets/favicon.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Modern title section
          Column(
            children: [
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Join UPM DRRM-H IRS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.95),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start your incident reporting journey',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpFormCard(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 32,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Modern form header
                Container(
                  padding: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, Color(0xFFC62828)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.app_registration_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Personal Information",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Fill in your details to get started",
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Modern form fields
                Column(
                  children: [
                    _buildModernFormField(
                      controller: _firstNameCtrl,
                      label: 'First Name',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (v) => _validateName(v, 'First Name'),
                      isRequired: true,
                    ),
                    const SizedBox(height: 20),
                    _buildModernFormField(
                      controller: _lastNameCtrl,
                      label: 'Last Name',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (v) => _validateName(v, 'Last Name'),
                      isRequired: true,
                    ),
                    const SizedBox(height: 20),
                    _buildModernFormField(
                      controller: _middleNameCtrl,
                      label: 'Middle Name (Optional)',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (v) => _validateName(v, 'Middle Name'),
                      isRequired: false,
                    ),
                    const SizedBox(height: 20),
                    _buildModernFormField(
                      controller: _suffixCtrl,
                      label: 'Suffix (Optional)',
                      icon: Icons.credit_card_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          null, // No validation for optional field
                      isRequired: false,
                    ),
                    const SizedBox(height: 20),

                    // Email field
                    _buildModernFormField(
                      controller: _emailCtrl,
                      label: 'Email Address',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      isRequired: true,
                    ),
                    const SizedBox(height: 20),

                    // UP Campus dropdown
                    _buildDropdownField(
                      controller: _upCampusCtrl,
                      label: 'UP Campus',
                      icon: Icons.school_rounded,
                      options: ['UPM', 'UPLB', 'UPD', 'UPV', 'UPMIN'],
                    ),
                    const SizedBox(height: 20),

                    // Office field
                    _buildModernFormField(
                      controller: _officeCtrl,
                      label: 'Office/Department',
                      icon: Icons.business_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          _validateRequiredField(v, 'Office/Department'),
                      isRequired: true,
                    ),
                    const SizedBox(height: 20),

                    // Position field
                    _buildModernFormField(
                      controller: _positionCtrl,
                      label: 'Position',
                      icon: Icons.work_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (v) => _validateRequiredField(v, 'Position'),
                      isRequired: true,
                    ),
                    const SizedBox(height: 20),

                    // Building Name field (optional)
                    _buildModernFormField(
                      controller: _bldgNameCtrl,
                      label: 'Building Name (Optional)',
                      icon: Icons.location_city_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (v) => null, // Optional field
                      isRequired: false,
                    ),
                    const SizedBox(height: 20),

                    // Password field
                    _buildModernFormField(
                      controller: _passwordCtrl,
                      label: 'Password',
                      icon: Icons.lock_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      validator: _validatePassword,
                      isRequired: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password field
                    _buildModernFormField(
                      controller: _confirmPasswordCtrl,
                      label: 'Confirm Password',
                      icon: Icons.lock_reset_rounded,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      validator: _validateConfirmPassword,
                      onFieldSubmitted: (_) => _submit(context),
                      isRequired: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Password requirements
                _buildPasswordRequirements(),
                const SizedBox(height: 24),

                // Terms agreement
                _buildTermsAgreement(),
                const SizedBox(height: 32),

                // Modern sign up button
                SizedBox(
                  width: double.infinity,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: authProvider.isLoading
                            ? null
                            : LinearGradient(
                                colors: [primaryColor, Color(0xFFC62828)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: authProvider.isLoading
                            ? []
                            : [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _submit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: authProvider.isLoading
                              ? Color(0xFF94A3B8)
                              : Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: Colors.transparent,
                        ),
                        child: authProvider.isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Modern divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Modern login section
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFFE2E8F0), width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.login_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sign In to Existing Account',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Privacy text
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Your information is secured and protected',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: successColor,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onFieldSubmitted,
    Widget? suffixIcon,
    bool isRequired = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        style: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(left: 20, right: 16),
            child: Icon(icon, size: 20, color: textSecondary),
          ),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffixIcon,
                )
              : null,
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 0,
          ),
          suffix: !isRequired
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 10,
                      color: textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<String> options,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: controller.text.isNotEmpty ? controller.text : options.first,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            controller.text = newValue;
          }
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(left: 20, right: 16),
            child: Icon(icon, size: 20, color: textSecondary),
          ),
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 0,
          ),
        ),
        style: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        dropdownColor: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        icon: Icon(Icons.arrow_drop_down_rounded, color: textSecondary),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _passwordCtrl.text;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements',
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _buildRequirementRow('At least 8 characters', password.length >= 8),
          const SizedBox(height: 8),
          _buildRequirementRow(
            'At least one uppercase letter',
            RegExp(r'[A-Z]').hasMatch(password),
          ),
          const SizedBox(height: 8),
          _buildRequirementRow(
            'At least one number',
            RegExp(r'[0-9]').hasMatch(password),
          ),
          const SizedBox(height: 8),
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
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isMet ? successColor.withOpacity(0.1) : Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(color: isMet ? successColor : Color(0xFFE2E8F0)),
          ),
          child: isMet
              ? Icon(Icons.check_rounded, size: 12, color: successColor)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isMet ? successColor : textSecondary,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAgreement() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _agreeToTerms
                ? successColor.withOpacity(0.05)
                : Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _agreeToTerms ? successColor : Color(0xFFE2E8F0),
              width: 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: _agreeToTerms ? successColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _agreeToTerms ? successColor : Color(0xFF94A3B8),
                    width: 2,
                  ),
                ),
                child: _agreeToTerms
                    ? Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: ' and ',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: ' of UPM DRRM-H IRS',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
