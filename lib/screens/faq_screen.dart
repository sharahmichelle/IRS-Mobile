import 'package:flutter/material.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // Red gradient theme matching login/signup
  static const Color _primaryRed = Color(0xFFE63946);
  static const Color _darkRed = Color(0xFFD00000);
  final Color _white = const Color(0xFFF8F9FA);
  final Color _surfaceWhite = const Color(0xFFFFFFFF);
  final Color _textPrimary = const Color(0xFF212529);
  final Color _textSecondary = const Color(0xFF6C757D);
  final Color _textLight = const Color(0xFF9CA3AF);
  final Color _successGreen = const Color(0xFF2A9D8F);

  final LinearGradient _redGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE63946), Color(0xFFD00000)],
  );

  final LinearGradient _headerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE63946), Color(0xFF9D0208)],
  );

  // State for expanded FAQ items
  final List<bool> _faqExpanded = List.generate(faqItems.length, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: Column(
        children: [
          // Header matching Submitted Reports screen
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 20,
            ),
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
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Help & Support',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'FAQs and emergency contacts',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/favicon.png',
                      width: 80,
                      height: 80,
                      color: _primaryRed,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.help_outline_rounded,
                          size: 60,
                          color: _primaryRed,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Frequently Asked',
                          style: TextStyle(
                            fontSize: 20,
                            color: _textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Questions',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Emergency Hotlines Section (removed icon)
                  _buildSectionHeader('Emergency Hotlines'),
                  const SizedBox(height: 16),
                  
                  ...emergencyHotlines.map((hotline) {
                    return _buildEmergencyContactCard(hotline);
                  }).toList(),
                  
                  const SizedBox(height: 32),

                  // FAQ Section (removed icon)
                  _buildSectionHeader('Common Questions'),
                  const SizedBox(height: 16),

                  ...List.generate(faqItems.length, (index) {
                    return _buildFaqItem(faqItems[index], index);
                  }),
                  
                  const SizedBox(height: 24),

                  // Support Note
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _successGreen.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.support_agent_rounded,
                          color: _successGreen,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need More Help?',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Contact support@upmdrrmh.edu.ph',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactCard(Map<String, dynamic> hotline) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _textLight.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hotline['color'] as Color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hotline['icon'] as IconData,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Expanded column for text with proper constraints
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hotline['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                  // Removed maxLines and overflow to allow natural wrapping
                ),
                const SizedBox(height: 4),
                Text(
                  hotline['description'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: _textSecondary,
                  ),
                  // Removed maxLines and overflow to allow natural wrapping
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Phone number container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              hotline['number'] as String,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _primaryRed,
              ),
              textAlign: TextAlign.center,
              // Removed maxLines and overflow to allow natural wrapping
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _faqExpanded[index]
              ? _primaryRed
              : _textLight.withOpacity(0.3),
          width: _faqExpanded[index] ? 2 : 1,
        ),
        boxShadow: _faqExpanded[index]
            ? [
                BoxShadow(
                  color: _primaryRed.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          collapsedIconColor: _textSecondary,
          iconColor: _primaryRed,
          backgroundColor: _surfaceWhite,
          collapsedBackgroundColor: _surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          trailing: Icon(
            _faqExpanded[index]
                ? Icons.remove_circle_outline_rounded
                : Icons.add_circle_outline_rounded,
            color: _faqExpanded[index] ? _primaryRed : _textSecondary,
            size: 26,
          ),
          title: Text(
            faq['question'] as String,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _faqExpanded[index] = expanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Text(
                faq['answer'] as String,
                style: TextStyle(
                  fontSize: 15,
                  color: _textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FAQ Data
final List<Map<String, dynamic>> faqItems = [
  {
    'question': 'What is UPM - DRRMH IRS?',
    'answer':
        'The UPM DRRMH (Disaster Risk Reduction and Management in Health) Incident Reporting System (IRS) is a mobile application designed for reporting and monitoring health-related incidents and emergencies within the University of the Philippines Manila campus.',
  },
  {
    'question': 'Who can use this application?',
    'answer':
        'The application is available to all UPM students, faculty, healthcare personnel, staff, and authorized personnel. Registration requires a valid UPM email address.',
  },
  {
    'question': 'What types of incidents can I report?',
    'answer':
        'You can report various health-related incidents including medical emergencies, infectious disease outbreaks, medication errors, patient safety incidents, environmental hazards, and natural disasters affecting health services.',
  },
  {
    'question': 'How quickly will my report be addressed?',
    'answer':
        'Emergency reports are prioritized and addressed immediately. Non-emergency reports are typically addressed within 24-48 hours. You can track the status of your report in the "My Reports" section.',
  },
  {
    'question': 'Is my personal information secure?',
    'answer':
        'Yes, all personal information is secured and protected according to data privacy regulations and healthcare confidentiality standards. Your data is encrypted and only accessible to authorized DRRMH personnel.',
  },
  {
    'question': 'Can I submit an anonymous report?',
    'answer':
        'For patient safety and quality improvement purposes, anonymous reporting is allowed for certain types of incidents. However, for follow-up and verification, contact information is preferred.',
  },
  {
    'question': 'How do I update my profile information?',
    'answer':
        'You can update your profile information by going to the Profile section and selecting "Edit Profile". Changes to certain information may require verification.',
  },
  {
    'question': 'What should I do if I forget my password?',
    'answer':
        'Click on "Forgot Password" on the login screen. You will receive an email with instructions to reset your password. Make sure to check your spam folder if you don\'t see the email.',
  },
  {
    'question': 'Can I access the system offline?',
    'answer':
        'Basic information like emergency contacts and FAQs can be accessed offline. However, reporting incidents requires an internet connection to submit data to our servers.',
  },
  {
    'question': 'How do I know if my report was received?',
    'answer':
        'You will receive a confirmation notification and email with a reference number. You can also check the status of your report in the "My Reports" section of the app.',
  },
];

// Emergency Hotlines Data
final List<Map<String, dynamic>> emergencyHotlines = [
  {
    'title': 'UPM DRRMH Emergency',
    'description': 'Health Emergency Response',
    'number': '(02) 8554-8400',
    'icon': Icons.local_hospital_rounded,
    'color': Color(0xFFE63946),
  },
  {
    'title': 'UPM Health Service',
    'description': 'Medical Emergency',
    'number': '(02) 8526-4541',
    'icon': Icons.medical_services_rounded,
    'color': Color(0xFF2A9D8F),
  },
  {
    'title': 'UP Manila Hospital',
    'description': 'PGH Emergency',
    'number': '(02) 8554-8400',
    'icon': Icons.local_hospital_rounded,
    'color': Color(0xFF457B9D),
  },
  {
    'title': 'UPM Security Office',
    'description': 'Campus Security',
    'number': '(02) 8526-4501',
    'icon': Icons.security_rounded,
    'color': Color(0xFF1D3557),
  },
  {
    'title': 'Philippine Red Cross',
    'description': 'National Emergency',
    'number': '143',
    'icon': Icons.emergency_rounded,
    'color': Color(0xFFDC2626),
  },
  {
    'title': 'National Poison Center',
    'description': 'Poison Control',
    'number': '(02) 8524-1078',
    'icon': Icons.science_rounded,
    'color': Color(0xFF7C3AED),
  },
  {
    'title': 'PNP Emergency',
    'description': 'Police Hotline',
    'number': '117',
    'icon': Icons.local_police_rounded,
    'color': Color(0xFF1D4ED8),
  },
  {
    'title': 'National Emergency',
    'description': 'Emergency Hotline',
    'number': '911',
    'icon': Icons.emergency_share_rounded,
    'color': Color(0xFFE63946),
  },
];