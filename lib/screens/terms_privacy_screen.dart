// lib/screens/terms_privacy_screen.dart
import 'package:flutter/material.dart';

class TermsPrivacyScreen extends StatefulWidget {
  final bool requireAcceptance;
  const TermsPrivacyScreen({Key? key, this.requireAcceptance = false})
      : super(key: key);

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  static const Color _primaryRed = Color(0xFFE63946);
  static const Color _darkRed = Color(0xFF9D0208);
  final Color _white = const Color(0xFFF8F9FA);
  final Color _textPrimary = const Color(0xFF212529);
  final Color _textSecondary = const Color(0xFF6C757D);
  final Color _borderColor = const Color(0xFFE9ECEF);

  final LinearGradient _headerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE63946), Color(0xFF9D0208)],
  );

  final ScrollController _scrollCtrl = ScrollController();
  bool _hasRead = false;

  @override
  void initState() {
    super.initState();
    if (widget.requireAcceptance) {
      _scrollCtrl.addListener(_onScroll);
    }
  }

  void _onScroll() {
    if (!_hasRead && _scrollCtrl.hasClients) {
      final max = _scrollCtrl.position.maxScrollExtent;
      if (_scrollCtrl.offset >= max - 80) {
        setState(() => _hasRead = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please read these Terms of Use and Privacy Policy carefully before using the UPM DRRM Incident Reporting System. By creating an account, you acknowledge that you have read, understood, and agree to be bound by these policies.',
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Terms of Use ─────────────────────────────────────────────
                  _buildSectionHeader('Terms of Use'),
                  const SizedBox(height: 16),
                  _buildItem('1. Acceptance', 'By registering for and using the UPM DRRM-IRS, you agree to be bound by these Terms of Use. If you do not agree, please do not register or use this application.'),
                  _buildItem('2. Authorized Use', 'This system is exclusively intended for authorized UPM Manila personnel for incident reporting, emergency response coordination, and disaster risk reduction activities. Unauthorized access or use is strictly prohibited.'),
                  _buildItem('3. User Responsibilities', 'You are responsible for providing accurate information in all incident reports, maintaining the confidentiality of your account credentials, reporting incidents promptly and in good faith, and not sharing your account with unauthorized individuals.'),
                  _buildItem('4. Report Accuracy', 'All incident reports must be accurate, complete, and truthful. Submitting false or fabricated reports is a serious violation of university policy and may result in disciplinary action.'),
                  _buildItem('5. Account Security', 'You are responsible for safeguarding your password and all activities that occur under your account. If you suspect unauthorized access, immediately notify the system administrator.'),
                  _buildItem('6. Prohibited Activities', 'Prohibited: submitting false reports, accessing other users\' data, using the system for unrelated purposes, disrupting system infrastructure, or uploading malicious content.'),
                  _buildItem('7. Termination', 'Administrators reserve the right to suspend or terminate your account at any time for violations of these terms.'),
                  _buildItem('8. Changes to Terms', 'UPM reserves the right to modify these Terms at any time. Continued use of the application after changes constitutes acceptance of the revised terms.'),

                  const SizedBox(height: 28),
                  Divider(color: _borderColor, thickness: 1),
                  const SizedBox(height: 28),

                  // ── Privacy Policy ───────────────────────────────────────────
                  _buildSectionHeader('Privacy Policy'),
                  const SizedBox(height: 16),
                  _buildItem('1. Information We Collect', 'We collect your full name, email address, position, office/college, building, cluster, zone, incident report details, and usage data such as login timestamps and actions performed.'),
                  _buildItem('2. How We Use Your Information', 'Information is used for account management, routing incident reports, emergency response coordination, DRRM planning analytics, and sending system notifications related to your submitted reports.'),
                  _buildItem('3. Legal Basis', 'Your personal information is processed in accordance with the Data Privacy Act of 2012 (RA 10173), based on public interest, legal obligations, and your explicit consent at registration.'),
                  _buildItem('4. Data Sharing', 'Your information may be shared with UPM DRRM personnel, university administration, and government agencies (e.g., NDRRMC, MMDA, BFP) as required by law. We do not sell your data to third parties.'),
                  _buildItem('5. Data Retention', 'Incident reports are retained for a minimum of five (5) years. Personal account information is retained for the duration of your affiliation with UPM Manila.'),
                  _buildItem('6. Data Security', 'We implement technical and organizational security measures including encrypted data transmission and secure authentication. No electronic transmission method is 100% secure.'),
                  _buildItem('7. Your Rights', 'Under RA 10173, you have the right to access, correct, delete, and port your data, and to object to processing. Contact the UPM Data Protection Officer to exercise these rights.'),
                  _buildItem('8. Contact', 'Data Protection Officer — University of the Philippines Manila\nEmail: dpo@upm.edu.ph\nPedro Gil Street, Ermita, Manila 1000'),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (widget.requireAcceptance) _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
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
            onPressed: () => Navigator.pop(
                context, widget.requireAcceptance ? false : null),
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 24),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Terms & Privacy Policy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _primaryRed,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _borderColor, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_hasRead)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 15, color: _textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Scroll to the bottom to accept',
                    style: TextStyle(
                        fontSize: 12,
                        color: _textSecondary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Decline',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed:
                      _hasRead ? () => Navigator.pop(context, true) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryRed,
                    disabledBackgroundColor: _borderColor,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: _textSecondary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'I Accept & Agree',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}