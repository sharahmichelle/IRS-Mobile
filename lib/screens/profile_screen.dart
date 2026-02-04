import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore_for_file: unused_field
import 'package:upm_drrm_irs_mobile/models/user_model.dart';
import 'package:upm_drrm_irs_mobile/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  // 2025 Modern Color Scheme
  final Color _primaryRed = const Color(0xFFE63946); // Vibrant emergency red
  final Color _darkRed = const Color(0xFF9D0208); // Deep emergency red
  final Color _emergencyBlue = const Color(0xFF1D3557); // Dark blue for contrast
  final Color _accentBlue = const Color(0xFF457B9D); // Medium blue
  final Color _lightBlue = const Color(0xFFA8DADC); // Light blue accent
  final Color _white = const Color(0xFFF8F9FA); // Pure white background
  final Color _surfaceWhite = const Color(0xFFFFFFFF); // Card surface
  final Color _textPrimary = const Color(0xFF212529); // Near black
  final Color _textSecondary = const Color(0xFF6C757D); // Medium gray
  final Color _successGreen = const Color(0xFF2A9D8F); // Teal green
  final Color _warningOrange = const Color(0xFFE9C46A); // Amber
  final Color _infoCyan = const Color(0xFF4CC9F0); // Bright cyan

  // Header gradient matching main_screen.dart
  final LinearGradient _headerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE63946), Color(0xFF9D0208)],
    stops: [0.0, 0.8],
    transform: GradientRotation(0.5),
  );

  final LinearGradient _emergencyGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE63946), Color(0xFFD00000)],
  );

  final LinearGradient _blueGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF457B9D), Color(0xFF1D3557)],
  );

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Header matching main_screen.dart
  PreferredSizeWidget get _appBar {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: _headerGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: const SizedBox.shrink(),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "UP MANILA DRRM-H IRS",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/favicon.png',
                        width: 18,
                        height: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    // Show loading if user data is not yet loaded
    if (authProvider.isLoading) {
      return Scaffold(
        appBar: _appBar,
        backgroundColor: _white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(_primaryRed),
                  strokeWidth: 4,
                  backgroundColor: _primaryRed.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading Profile',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Show error or empty state if no user
    if (currentUser == null) {
      return Scaffold(
        appBar: _appBar,
        backgroundColor: _white,
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_lightBlue, _white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person_off_rounded,
                              size: 56,
                              color: _accentBlue.withOpacity(0.6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'No User Data',
                          style: TextStyle(
                            fontSize: 24,
                            color: _textPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            'Please sign in again to access your profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: _textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          height: 56,
                          width: 200,
                          decoration: BoxDecoration(
                            gradient: _emergencyGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryRed.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed('/');
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.login_rounded, color: _white, size: 22),
                                    const SizedBox(width: 12),
                                    Text(
                                      'GO TO LOGIN',
                                      style: TextStyle(
                                        color: _white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Build full name with optional middle name and suffix
    String getFullName() {
      final nameParts = [];
      if (currentUser.firstName.isNotEmpty) nameParts.add(currentUser.firstName);
      if (currentUser.middleName.isNotEmpty) {
        nameParts.add('${currentUser.middleName[0]}.');
      }
      if (currentUser.lastName.isNotEmpty) nameParts.add(currentUser.lastName);
      if (currentUser.suffix.isNotEmpty) {
        nameParts.add(currentUser.suffix);
      }
      // Fallback to formatted username if no name parts are available
      if (nameParts.isEmpty) {
        // Format username like "encoder1" to "Encoder 1"
        final userName = currentUser.userName;
        if (userName.startsWith('encoder') && userName.length > 7) {
          final number = userName.substring(7);
          return 'Encoder $number';
        }
        return userName;
      }
      return nameParts.join(' ');
    }

    final userDetails = [
      {
        "icon": Icons.school_rounded,
        "label": "Cluster",
        "value": currentUser.cluster.isNotEmpty ? currentUser.cluster : "Not specified",
        "color": _accentBlue,
      },
      {
        "icon": Icons.business_rounded,
        "label": "Office / College",
        "value": currentUser.office.isNotEmpty ? currentUser.office : "Not specified",
        "color": _infoCyan,
      },
      {
        "icon": Icons.location_city_rounded,
        "label": "Building Name",
        "value": currentUser.bldgName.isNotEmpty ? currentUser.bldgName : "Not specified",
        "color": _successGreen,
      },
    ];

    return Scaffold(
      appBar: _appBar,
      backgroundColor: _white,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Profile Content (without the gradient header from before)
                      _buildProfileContent(currentUser, getFullName()),
                      const SizedBox(height: 24),

                      // User Info Card
                      _buildUserInfoCard(currentUser, userDetails),
                      const SizedBox(height: 24),

                      // Action Cards
                      _buildActionCards(context, authProvider),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(UserModel user, String fullName) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Profile Avatar with Edit Button
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryRed, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.network(
                      "https://avatar.iran.liara.run/public/boy",
                      width: 116,
                      height: 116,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, _lightBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 60,
                            color: _accentBlue,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Edit Photo Button
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _surfaceWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => _showEditPhotoOptions(),
                  icon: Icon(
                    Icons.camera_alt_rounded,
                    size: 22,
                    color: _primaryRed,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // User Name with improved overflow handling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              fullName,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),

          // Position with improved overflow handling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              user.position.isNotEmpty ? user.position : "No position specified",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),

          // Email with improved overflow handling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: _primaryRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primaryRed.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email_rounded,
                    size: 18,
                    color: _primaryRed,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: _textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
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

  Widget _buildUserInfoCard(UserModel user, List<Map<String, dynamic>> details) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        decoration: BoxDecoration(
          color: _surfaceWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: _primaryRed.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: _emergencyGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: _white,
                        size: 24,
                      ),
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
                            color: _textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          "Your account and profile details",
                          style: TextStyle(
                            fontSize: 13,
                            color: _textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Details Grid with proper constraints
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 600 ? 2 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: constraints.maxWidth > 600 ? 2.2 : 2.8,
                      mainAxisExtent: constraints.maxWidth > 600 ? null : 120,
                    ),
                    itemCount: details.length,
                    itemBuilder: (context, index) {
                      final item = details[index];
                      return _buildDetailItem(
                        icon: item['icon'] as IconData,
                        label: item['label'] as String,
                        value: item['value'] as String,
                        color: item['color'] as Color,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value * 0.5),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 100,
              ),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(icon, size: 20, color: color),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        color: _textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildActionCards(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // FAQ Card
          _buildActionCard(
            icon: Icons.help_rounded,
            title: "FAQs & Help Center",
            subtitle: "Get answers to common questions",
            gradient: LinearGradient(
              colors: [_accentBlue, _emergencyBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => _showFAQs(),
          ),
          const SizedBox(height: 16),

          // Logout Card
          _buildActionCard(
            icon: Icons.logout_rounded,
            title: "Log Out",
            subtitle: "Sign out of your account",
            gradient: _emergencyGradient,
            isLogout: true,
            onTap: () => _showModernLogoutConfirmation(context, authProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value * 0.3),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryRed.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: _surfaceWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 32,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _textSecondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Update Profile Photo",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildPhotoOption(
                icon: Icons.photo_library_rounded,
                title: "Choose from Gallery",
                onTap: () {
                  Navigator.pop(context);
                  // Implement gallery selection
                },
              ),
              _buildPhotoOption(
                icon: Icons.camera_alt_rounded,
                title: "Take Photo",
                onTap: () {
                  Navigator.pop(context);
                  // Implement camera
                },
              ),
              const SizedBox(height: 16),
              Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
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

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: _primaryRed, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: _textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFAQs() {
    // Implement FAQ screen navigation
    Navigator.of(context).pushNamed('/faq');
  }

  void _showModernLogoutConfirmation(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value * 0.5),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _surfaceWhite,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 40,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        "Log Out?",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Are you sure you want to log out? You'll need to sign in again to access your account.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: _textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Buttons
                      Row(
                        children: [
                          // Cancel Button
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: _white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _borderColor),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
                                    child: Text(
                                      "CANCEL",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _textSecondary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Logout Button
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: _emergencyGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: _primaryRed.withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    await authProvider.signOut(context);
                                    Navigator.of(context).pushReplacementNamed('/');
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.logout_rounded, color: _white, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          "LOG OUT",
                                          style: TextStyle(
                                            color: _white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
          },
        ),
      ),
    );
  }

  Color get _borderColor => const Color(0xFFE2E8F0);
}