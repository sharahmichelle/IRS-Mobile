import 'package:flutter/material.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // Modern color scheme matching your sign-up screen
  final Color primaryColor = Color(0xFFA11D1C);
  final Color backgroundColor = Color(0xFFF8FAFC);
  final Color surfaceColor = Colors.white;
  final Color textPrimary = Color(0xFF1E293B);
  final Color textSecondary = Color(0xFF64748B);
  final Color accentColor = Color(0xFF0EA5E9);
  final Color successColor = Color(0xFF10B981);
  final Color warningColor = Color(0xFFF59E0B);

  // State for expanded FAQ items
  final List<bool> _faqExpanded = List.generate(faqItems.length, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header with gradient
              _buildHeader(),
              const SizedBox(height: 32),

              // Emergency Hotlines Card
              _buildEmergencyHotlinesCard(),
              const SizedBox(height: 24),

              // FAQ Section
              _buildFaqSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          // Logo/Icon with modern container
          Container(
            width: 100,
            height: 100,
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
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primaryColor.withOpacity(0.1), Color(0xFFC62828).withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Icon(
                  Icons.help_outline_rounded,
                  size: 48,
                  color: primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Title section
          Column(
            children: [
              Text(
                'Help & Support',
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'FAQs & Emergency Hotlines',
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
                'Find answers and emergency contacts',
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

  Widget _buildEmergencyHotlinesCard() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFDC2626).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.emergency_rounded,
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
                          "Emergency Hotlines",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Immediate assistance contacts",
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
              const SizedBox(height: 24),

              // Emergency Contacts List
              Column(
                children: emergencyHotlines.map((hotline) {
                  return _buildEmergencyContactCard(hotline);
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Important Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: warningColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: warningColor.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'For immediate emergencies, always call the hotline first before submitting a report.',
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyContactCard(Map<String, dynamic> hotline) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: hotline['color'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hotline['icon'] as IconData,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            
            // Title and Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotline['title'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hotline['description'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Phone Number Container
            Container(
              constraints: BoxConstraints(
                minWidth: 100,
                maxWidth: 140,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Phone Icon
                  Icon(
                    Icons.phone_rounded,
                    size: 16,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 4),
                  
                  // Phone Number
                  Text(
                    hotline['number'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FAQ Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, Color(0xFF38BDF8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.question_answer_rounded,
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
                          "Frequently Asked Questions",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Common questions about UPM - DRRMH IRS",
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
              const SizedBox(height: 24),

              // FAQ Items
              Column(
                children: List.generate(faqItems.length, (index) {
                  return _buildFaqItem(faqItems[index], index);
                }),
              ),
              const SizedBox(height: 16),

              // Support Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: successColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.support_agent_rounded,
                        color: successColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need More Help?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Contact our support team at support@upmdrrmh.edu.ph or visit the DRRMH office.',
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                              height: 1.4,
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
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _faqExpanded[index] ? accentColor : Color(0xFFE2E8F0),
          width: _faqExpanded[index] ? 2 : 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        collapsedIconColor: textSecondary,
        iconColor: accentColor,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        trailing: Icon(
          _faqExpanded[index] 
              ? Icons.remove_circle_outline_rounded
              : Icons.add_circle_outline_rounded,
          color: _faqExpanded[index] ? accentColor : textSecondary,
        ),
        title: Text(
          faq['question'] as String,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _faqExpanded[index] = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              faq['answer'] as String,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// FAQ Data
final List<Map<String, dynamic>> faqItems = [
  {
    'question': 'What is UPM - DRRMH IRS?',
    'answer': 'The UPM DRRMH (Disaster Risk Reduction and Management in Health) Incident Reporting System (IRS) is a mobile application designed for reporting and monitoring health-related incidents and emergencies within the University of the Philippines Manila campus. It allows healthcare personnel, students, and staff to quickly report incidents to the Disaster Risk Reduction and Management in Health office.',
  },
  {
    'question': 'Who can use this application?',
    'answer': 'The application is available to all UPM students, faculty, healthcare personnel, staff, and authorized personnel. Registration requires a valid UPM email address. Different user types have different permissions (Encoder, Manager, Admin).',
  },
  {
    'question': 'What types of incidents can I report?',
    'answer': 'You can report various health-related incidents including but not limited to: medical emergencies, infectious disease outbreaks, medication errors, patient safety incidents, environmental hazards, natural disasters affecting health services, and other health safety-related incidents.',
  },
  {
    'question': 'How quickly will my report be addressed?',
    'answer': 'Emergency reports are prioritized and addressed immediately. Non-emergency reports are typically addressed within 24-48 hours. You can track the status of your report in the "My Reports" section.',
  },
  {
    'question': 'Is my personal information secure?',
    'answer': 'Yes, all personal information is secured and protected according to data privacy regulations and healthcare confidentiality standards. Your data is encrypted and only accessible to authorized DRRMH personnel.',
  },
  {
    'question': 'Can I submit an anonymous report?',
    'answer': 'For patient safety and quality improvement purposes, anonymous reporting is allowed for certain types of incidents. However, for follow-up and verification, contact information is preferred.',
  },
  {
    'question': 'How do I update my profile information?',
    'answer': 'You can update your profile information by going to the Profile section and selecting "Edit Profile". Changes to certain information may require verification.',
  },
  {
    'question': 'What should I do if I forget my password?',
    'answer': 'Click on "Forgot Password" on the login screen. You will receive an email with instructions to reset your password. Make sure to check your spam folder if you don\'t see the email.',
  },
  {
    'question': 'Can I access the system offline?',
    'answer': 'Basic information like emergency contacts and FAQs can be accessed offline. However, reporting incidents requires an internet connection to submit data to our servers.',
  },
  {
    'question': 'How do I know if my report was received?',
    'answer': 'You will receive a confirmation notification and email with a reference number. You can also check the status of your report in the "My Reports" section of the app.',
  },
];

// Emergency Hotlines Data
final List<Map<String, dynamic>> emergencyHotlines = [
  {
    'title': 'UPM DRRMH Emergency',
    'description': 'Health Emergency Response',
    'number': '(02) 8554-8400',
    'icon': Icons.local_hospital_rounded,
    'color': Color(0xFFDC2626),
  },
  {
    'title': 'UPM Health Service',
    'description': 'Medical Emergency & First Aid',
    'number': '(02) 8526-4541',
    'icon': Icons.medical_services_rounded,
    'color': Color(0xFF059669),
  },
  {
    'title': 'UP Manila Hospital',
    'description': 'Philippine General Hospital',
    'number': '(02) 8554-8400',
    'icon': Icons.local_hospital_rounded,
    'color': Color(0xFF2563EB),
  },
  {
    'title': 'UPM Security Office',
    'description': '24/7 Campus Security',
    'number': '(02) 8526-4501',
    'icon': Icons.security_rounded,
    'color': Color(0xFF1D4ED8),
  },
  {
    'title': 'Philippine Red Cross',
    'description': 'National Emergency Hotline',
    'number': '143',
    'icon': Icons.emergency_rounded,
    'color': Color(0xFFDC2626),
  },
  {
    'title': 'National Poison Center',
    'description': 'Toxicology & Poison Control',
    'number': '(02) 8524-1078',
    'icon': Icons.science_rounded,
    'color': Color(0xFF7C3AED),
  },
  {
    'title': 'PNP Emergency',
    'description': 'Philippine National Police',
    'number': '117',
    'icon': Icons.local_police_rounded,
    'color': Color(0xFF1D4ED8),
  },
  {
    'title': 'National Emergency',
    'description': 'Emergency Hotline',
    'number': '911',
    'icon': Icons.emergency_share_rounded,
    'color': Color(0xFFDC2626),
  },
];