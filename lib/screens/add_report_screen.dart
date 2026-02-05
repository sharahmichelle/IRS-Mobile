import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/report_model.dart';
import 'package:upm_drrm_irs_mobile/providers/auth_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/event_totals_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/reports_provider.dart';
import 'package:upm_drrm_irs_mobile/widgets/success_dialog.dart';
import 'package:upm_drrm_irs_mobile/screens/submitted_reports_screen.dart';

class AddReportScreen extends StatefulWidget {
  final Event currentEvent;
  final Report? existingReport;

  const AddReportScreen({super.key, required this.currentEvent, this.existingReport});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _clusterController = TextEditingController();
  final TextEditingController _headcountFacultyController = TextEditingController();
  final TextEditingController _headcountAdminController = TextEditingController();
  final TextEditingController _headcountREPSController = TextEditingController();
  final TextEditingController _headcountRAController = TextEditingController();
  final TextEditingController _headcountStudentController = TextEditingController();
  final TextEditingController _headcountPhilcareController = TextEditingController();
  final TextEditingController _headcountSecurityController = TextEditingController();
  final TextEditingController _headcountConstructionController = TextEditingController();
  final TextEditingController _headcountTenantsController = TextEditingController();
  final TextEditingController _headcountHealthWorkerController = TextEditingController();
  final TextEditingController _headcountNonAcadStaffController = TextEditingController();
  final TextEditingController _headcountGuestsController = TextEditingController();
  final TextEditingController _numberMissingController = TextEditingController();
  final TextEditingController _missingPeopleNamesController = TextEditingController();
  final TextEditingController _numberCasualtyController = TextEditingController();
  final TextEditingController _identityConditionController = TextEditingController();
  final TextEditingController _damageAssessmentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 2025 Modern Color Scheme - Enhanced
  final Color _primaryRed = const Color(0xFFE63946);
  final Color _darkRed = const Color(0xFF9D0208);
  final Color _emergencyBlue = const Color(0xFF1D3557);
  final Color _accentBlue = const Color(0xFF457B9D);
  final Color _lightBlue = const Color(0xFFA8DADC);
  final Color _white = const Color(0xFFF8F9FA);
  final Color _surfaceWhite = const Color(0xFFFFFFFF);
  final Color _textPrimary = const Color(0xFF212529);
  final Color _textSecondary = const Color(0xFF6C757D);
  final Color _successGreen = const Color(0xFF2A9D8F);
  final Color _warningOrange = const Color(0xFFE9C46A);
  final Color _infoCyan = const Color(0xFF4CC9F0);
  final Color _glassEffect = const Color(0x10FFFFFF);
  final Color _shadowColor = const Color(0x0A000000);

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

  late final LinearGradient _blueGradient;
  late final LinearGradient _orangeGradient;

  // Modern Icons
  final IconData _headcountIcon = Icons.people_alt_rounded;
  final IconData _incidentIcon = Icons.warning_amber_rounded;
  final IconData _missingIcon = Icons.person_search_rounded;
  final IconData _casualtyIcon = Icons.local_hospital_rounded;
  final IconData _damageIcon = Icons.home_work_rounded;
  final IconData _locationIcon = Icons.location_on_rounded;
  final IconData _submitIcon = Icons.check_circle_rounded;
  final IconData _backIcon = Icons.arrow_back_ios_new_rounded;
  final IconData _emergencyIcon = Icons.emergency_rounded;

  // Category Icons for Headcount
  final Map<String, IconData> _categoryIcons = {
    "Faculty Members": Icons.school_rounded,
    "Admin Members": Icons.business_center_rounded,
    "REPS Members": Icons.engineering_rounded,
    "RA Members": Icons.cleaning_services_rounded,
    "Students": Icons.school_rounded,
    "Philcare Staff": Icons.medical_services_rounded,
    "Security Personnel": Icons.security_rounded,
    "Construction Workers": Icons.construction_rounded,
    "Tenants": Icons.apartment_rounded,
    "Health Workers": Icons.health_and_safety_rounded,
    "Non-Academic Staff": Icons.work_rounded,
    "Guests": Icons.people_rounded,
  };

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Location auto-complete variables
  List<String> _locationSuggestions = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _locationFocusNode = FocusNode();

  // Tracks whether user attempted to submit so we show validation outlines
  bool _submitAttempted = false;

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

    // Initialize gradients that depend on instance color fields
    _blueGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_accentBlue, _emergencyBlue],
    );

    _orangeGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_warningOrange, const Color(0xFFF4A261)],
    );

    _locationFocusNode.addListener(() {
      if (!_locationFocusNode.hasFocus) {
        _onLocationUnfocus();
      }
    });

    // Prefill location from current event
    if (widget.currentEvent.location.isNotEmpty) {
      _locationController.text = widget.currentEvent.location;
    }

    // Add listeners to all controllers to trigger rebuild and update outline colors
    final allControllers = [
      _nameController, _positionController, _clusterController,
      _headcountFacultyController, _headcountAdminController,
      _headcountREPSController, _headcountRAController,
      _headcountStudentController, _headcountPhilcareController,
      _headcountSecurityController, _headcountConstructionController,
      _headcountTenantsController, _headcountHealthWorkerController,
      _headcountNonAcadStaffController, _headcountGuestsController,
      _numberMissingController, _missingPeopleNamesController,
      _numberCasualtyController, _identityConditionController,
      _damageAssessmentController, _locationController,
    ];

    for (var c in allControllers) {
      c.addListener(() {
        if (mounted) setState(() {});
      });
    }

    // If we're editing an existing report, prefill controllers
    if (widget.existingReport != null) {
      final r = widget.existingReport!;
      _positionController.text = r.encoderposition;
      _headcountFacultyController.text = (r.facultymembers != 0 ? r.facultymembers : 0).toString();
      _headcountAdminController.text = (r.adminmembers != 0 ? r.adminmembers : 0).toString();
      _headcountREPSController.text = (r.repsmembers != 0 ? r.repsmembers : 0).toString();
      _headcountRAController.text = (r.ramembers != 0 ? r.ramembers : 0).toString();
      _headcountStudentController.text = (r.students != 0 ? r.students : 0).toString();
      _headcountPhilcareController.text = (r.philcarestaff != 0 ? r.philcarestaff : 0).toString();
      _headcountSecurityController.text = (r.securitypersonnel != 0 ? r.securitypersonnel : 0).toString();
      _headcountConstructionController.text = (r.constructionworkers != 0 ? r.constructionworkers : 0).toString();
      _headcountTenantsController.text = (r.tenants != 0 ? r.tenants : 0).toString();
      _headcountHealthWorkerController.text = (r.healthworkers != 0 ? r.healthworkers : 0).toString();
      _headcountNonAcadStaffController.text = (r.nonacademicstaff != 0 ? r.nonacademicstaff : 0).toString();
      _headcountGuestsController.text = (r.guests != 0 ? r.guests : 0).toString();
      _numberMissingController.text = (r.nummissingpersons != 0 ? r.nummissingpersons : 0).toString();
      _missingPeopleNamesController.text = r.namesofmissingpersons;
      _numberCasualtyController.text = (r.numcasualties != 0 ? r.numcasualties : 0).toString();
      _identityConditionController.text = r.identityandconditionofcasualties;
      _damageAssessmentController.text = r.damageassessment;
      _locationController.text = r.exactlocation.isNotEmpty ? r.exactlocation : _locationController.text;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _locationFocusNode.dispose();
    _removeOverlay();

    // Dispose all controllers
    final controllers = [
      _nameController, _positionController, _clusterController,
      _headcountFacultyController, _headcountAdminController,
      _headcountREPSController, _headcountRAController,
      _headcountStudentController, _headcountPhilcareController,
      _headcountSecurityController, _headcountConstructionController,
      _headcountTenantsController, _headcountHealthWorkerController,
      _headcountNonAcadStaffController, _headcountGuestsController,
      _numberMissingController, _missingPeopleNamesController,
      _numberCasualtyController, _identityConditionController,
      _damageAssessmentController, _locationController,
    ];
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateLocationSuggestions(String query) {
    if (query.length > 2) {
      final localSuggestions = [
        'UP Manila Main Building',
        'UP Manila College of Medicine',
        'UP Manila College of Nursing',
        'UP Manila College of Public Health',
        'UP Manila Philippine General Hospital',
        'UP Manila Calderon Hall',
        'UP Manila Lara Hall',
        'UP Manila Sports Center',
        'UP Manila Library',
        'UP Manila Student Center',
        'UP Manila Paz Mendoza Building',
        'UP Manila Central Administration Building',
        'UP Manila Museum of a History of Ideas',
        'UP Manila Chapel',
        'UP Manila Gymnasium',
      ].where(
        (location) => location.toLowerCase().contains(query.toLowerCase()),
      ).toList();

      setState(() {
        _locationSuggestions = localSuggestions;
      });

      _showSuggestionOverlay();
    } else {
      _removeOverlay();
    }
  }

  Future<void> _onSubmit() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    // mark that the user tried to submit so we show outlines for empty required fields
    setState(() {
      _submitAttempted = true;
    });

    // Required fields: numeric headcounts and location
    final requiredControllers = [
      _headcountFacultyController,
      _headcountAdminController,
      _headcountREPSController,
      _headcountRAController,
      _headcountStudentController,
      _headcountSecurityController,
      _headcountConstructionController,
      _headcountHealthWorkerController,
      _headcountGuestsController,
      _headcountPhilcareController,
      _headcountTenantsController,
      _headcountNonAcadStaffController,
    ];

    final hasMissingRequired = requiredControllers.any((c) => c.text.trim().isEmpty) || _locationController.text.trim().isEmpty;

    if (hasMissingRequired) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please complete required fields.'),
            backgroundColor: Colors.redAccent.withOpacity(0.9),
          ),
        );
      }
      return;
    }

    // All required fields filled; proceed

    final report = Report(
      encoderId: currentUser != null ? currentUser.authId : "unknown",
      reportId: widget.currentEvent.eventId,
      cluster: currentUser != null ? currentUser.cluster : "unknown",
      bldgName: currentUser != null ? currentUser.bldgName : "unknown",
      office: currentUser != null ? currentUser.office : "unknown",
      encoderposition: _positionController.text,
      facultymembers: int.tryParse(_headcountFacultyController.text) ?? 0,
      adminmembers: int.tryParse(_headcountAdminController.text) ?? 0,
      repsmembers: int.tryParse(_headcountREPSController.text) ?? 0,
      ramembers: int.tryParse(_headcountRAController.text) ?? 0,
      students: int.tryParse(_headcountStudentController.text) ?? 0,
      philcarestaff: int.tryParse(_headcountPhilcareController.text) ?? 0,
      securitypersonnel: int.tryParse(_headcountSecurityController.text) ?? 0,
      constructionworkers: int.tryParse(_headcountConstructionController.text) ?? 0,
      tenants: int.tryParse(_headcountTenantsController.text) ?? 0,
      healthworkers: int.tryParse(_headcountHealthWorkerController.text) ?? 0,
      nonacademicstaff: int.tryParse(_headcountNonAcadStaffController.text) ?? 0,
      guests: int.tryParse(_headcountGuestsController.text) ?? 0,
      nummissingpersons: int.tryParse(_numberMissingController.text) ?? 0,
      numcasualties: int.tryParse(_numberCasualtyController.text) ?? 0,
      namesofmissingpersons: _missingPeopleNamesController.text.trim(),
      identityandconditionofcasualties: _identityConditionController.text.trim(),
      damageassessment: _damageAssessmentController.text.trim(),
      exactlocation: _locationController.text.trim(),
    );

    if (widget.existingReport != null && widget.existingReport!.id.isNotEmpty) {
      // Edit existing report
      final editMap = {
        'reportId': widget.currentEvent.eventId,
        'facultymembers': report.facultymembers,
        'adminmembers': report.adminmembers,
        'repsmembers': report.repsmembers,
        'ramembers': report.ramembers,
        'students': report.students,
        'philcarestaff': report.philcarestaff,
        'securitypersonnel': report.securitypersonnel,
        'constructionworkers': report.constructionworkers,
        'tenants': report.tenants,
        'healthworkers': report.healthworkers,
        'nonacademicstaff': report.nonacademicstaff,
        'guests': report.guests,
        'nummissingpersons': report.nummissingpersons,
        'numcasualties': report.numcasualties,
        'namesofmissingpersons': report.namesofmissingpersons,
        'identityandconditionofcasualties': report.identityandconditionofcasualties,
        'damageassessment': report.damageassessment,
        'exactlocation': report.exactlocation,
        'encoderposition': report.encoderposition,
      };

      if (context.mounted) {
        await context.read<Reports>().editReport(widget.existingReport!.id, editMap);
        // Reload reports and event totals
        context.read<Reports>().fetchReports();
        context.read<EventTotals>().fetchEventTotals();
      }

      // Show success and pop back
      _showSuccessAndClose();
      return;
    }

    // Create new report
    String reportId;
    try {
      if (!context.mounted) return;
      reportId = await context.read<Reports>().addReport(report);
    } catch (e) {
      final errMsg = e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $errMsg'), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    // Add report to event totals (RPC) and ensure totals are refreshed
    try {
      if (!context.mounted) return;
      await context.read<EventTotals>().addReportToEventTotal(
        widget.currentEvent.eventId,
        currentUser != null ? currentUser.cluster : "unknown",
        reportId,
        {
          "headCountFaculty": report.facultymembers,
          "headCountadminMember": report.adminmembers,
          "headCountRepsMember": report.repsmembers,
          "headCountRAMember": report.ramembers,
          "headCountStudent": report.students,
          "headCountPhilcare": report.philcarestaff,
          "headCountSecurity": report.securitypersonnel,
          "headCountConstructionWorker": report.constructionworkers,
          "headCountTenant": report.tenants,
          "headCountNonAcademicStaff": report.nonacademicstaff,
          "headCountHealthWorker": report.healthworkers,
          "headCountGuest": report.guests,
          "numMissingPerson": report.nummissingpersons,
          "numCasualty": report.numcasualties,
        },
      );

      if (context.mounted) {
        context.read<EventTotals>().fetchEventTotals();
      }
    } catch (e) {
      final errMsg = e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update event totals: $errMsg'), backgroundColor: Colors.orangeAccent),
        );
      }
      // Continue — report record may still exist, but totals couldn't be updated.
    }

    // Show success and redirect to Submitted Reports screen
    _showSuccessAndRedirect();

    // Reset submit attempted flag after successful submission
    if (mounted) {
      setState(() {
        _submitAttempted = false;
      });
    }
  }

  void _showSuggestionOverlay() {
    _removeOverlay();

    if (_locationSuggestions.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 40,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: _surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: _lightBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _locationSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _locationSuggestions[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _locationController.text = suggestion;
                        _removeOverlay();
                        _locationFocusNode.unfocus();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _accentBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  _locationIcon,
                                  color: _accentBlue,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onLocationUnfocus() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _removeOverlay();
    });
  }

  void _showSuccessAndRedirect() {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        onDone: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => SubmittedReportsScreen()),
          );
        },
        primaryColor: _primaryRed,
        textPrimary: _textPrimary,
        textSecondary: _textSecondary,
      ),
    );
  }

  void _showSuccessAndClose() {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        onDone: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(); // close add/edit screen
        },
        primaryColor: _primaryRed,
        textPrimary: _textPrimary,
        textSecondary: _textSecondary,
      ),
    );
  }

  String? _requiredNumber(String? val) {
    if (val == null || val.isEmpty) return 'This field is required';
    final number = int.tryParse(val);
    if (number == null || number < 0) return 'Enter a valid number';
    return null;
  }

  Widget _buildModernSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 26,
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
                    color: _textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCategoryInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    bool requiredField = false,
  }) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _accentBlue.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: _accentBlue,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: _surfaceWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: readOnly
                    ? Colors.grey.withOpacity(0.18)
                    : (requiredField && controller.text.isEmpty && _submitAttempted)
                        ? Colors.red.withOpacity(0.5)
                        : _lightBlue.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              readOnly: readOnly,
              enabled: !readOnly,
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: readOnly ? Colors.grey[700] : _textPrimary,
              ),
              decoration: InputDecoration(
                hintText: "0",
                hintStyle: TextStyle(
                  color: readOnly ? Colors.grey[600] : _textSecondary.withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (_) => null,
            ),
          ),
        ],
      );
  }
  Widget _buildModernIncidentInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    String? hintText,
    String? Function(String?)? validator,
    bool isNumber = false,
    bool readOnly = false,
    bool requiredField = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _warningOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _warningOrange.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: _warningOrange,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: readOnly
                  ? Colors.grey.withOpacity(0.18)
                  : (requiredField && controller.text.isEmpty && _submitAttempted)
                      ? Colors.red.withOpacity(0.5)
                      : _lightBlue.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            readOnly: readOnly,
            enabled: !readOnly,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: readOnly ? Colors.grey[700] : _textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: readOnly ? Colors.grey[600] : _textSecondary.withOpacity(0.5),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (_) => null,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInput({bool readOnly = false}) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _infoCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _infoCyan.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _locationIcon,
                    color: _infoCyan,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Location of Incident",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: _surfaceWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: readOnly
                    ? Colors.grey.withOpacity(0.18)
                    : ((_locationController.text.isEmpty && _submitAttempted)
                        ? Colors.red.withOpacity(0.5)
                        : _lightBlue.withOpacity(0.4)),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _locationController,
              focusNode: _locationFocusNode,
              onChanged: readOnly ? null : _updateLocationSuggestions,
              onTap: readOnly
                  ? null
                  : () {
                      if (_locationController.text.isNotEmpty && _locationSuggestions.isNotEmpty) {
                        _showSuggestionOverlay();
                      }
                    },
              onTapOutside: (event) {
                _onLocationUnfocus();
              },
              readOnly: readOnly,
              enabled: !readOnly,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: readOnly ? Colors.grey[700] : _textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Type to enter or refine location (prefilled from event)',
                hintStyle: TextStyle(
                  color: readOnly ? Colors.grey[600] : _textSecondary.withOpacity(0.5),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(
                    _locationIcon,
                    color: readOnly ? Colors.grey[600] : _infoCyan,
                    size: 20,
                  ),
                ),
              ),
              validator: (_) => null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    // Determine event status to control submission behavior
    final status = widget.currentEvent.status.toLowerCase();
    final bool isUpcoming = status == 'upcoming';
    final bool isCompleted = status == 'completed';
    final bool isSubmissionDisabled = isUpcoming || isCompleted;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Scaffold(
              backgroundColor: _white,
              appBar: AppBar(
                backgroundColor: _surfaceWhite,
                elevation: 0,
                leading: IconButton(
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _backIcon,
                        color: _textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  "Add Incident Report",
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                centerTitle: false,
              ),
              body: SafeArea(
                bottom: false,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWideScreen ? 28 : 16,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Emergency Event Header
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              gradient: _emergencyGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryRed.withOpacity(0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _emergencyIcon,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.currentEvent.eventName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.4,
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _locationController.text.isNotEmpty
                                            ? _locationController.text
                                            : "Enter location in the form below",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Status banner for upcoming/completed events
                          if (isSubmissionDisabled)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isUpcoming ? _warningOrange.withOpacity(0.12) : Colors.grey.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isUpcoming ? _warningOrange.withOpacity(0.2) : Colors.grey.withOpacity(0.18),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isUpcoming ? Icons.info_outline_rounded : Icons.event_busy_rounded,
                                    color: isUpcoming ? _warningOrange : Colors.grey[700],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      isUpcoming
                                          ? 'This incident is still not available for submission.'
                                          : 'Submission for this incident is already closed.',
                                      style: TextStyle(
                                        color: isUpcoming ? _warningOrange : Colors.grey[800],
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // ── Main Form Content ──────────────────────────────
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Headcount Section
                              Text(
                                "Headcount Information",
                                style: TextStyle(
                                  color: _textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Enter the number of people in each category",
                                style: TextStyle(
                                  color: _textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Headcount Cards Grid
                              // Row 1
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildModernCategoryInput(
                                      label: "Faculty Members",
                                      controller: _headcountFacultyController,
                                      icon: _categoryIcons["Faculty Members"]!,
                                      readOnly: isSubmissionDisabled,
                                      requiredField: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildModernCategoryInput(
                                      label: "Admin Members",
                                      controller: _headcountAdminController,
                                      icon: _categoryIcons["Admin Members"]!,
                                      readOnly: isSubmissionDisabled,
                                      requiredField: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Row 2
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildModernCategoryInput(
                                      label: "REPS Members",
                                      controller: _headcountREPSController,
                                      icon: _categoryIcons["REPS Members"]!,
                                      readOnly: isSubmissionDisabled,
                                      requiredField: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildModernCategoryInput(
                                      label: "RA Members",
                                      controller: _headcountRAController,
                                      icon: _categoryIcons["RA Members"]!,
                                      readOnly: isSubmissionDisabled,
                                      requiredField: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Row 3
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildModernCategoryInput(
                                      label: "Students",
                                      controller: _headcountStudentController,
                                      icon: _categoryIcons["Students"]!,
                                      readOnly: isSubmissionDisabled,
                                      requiredField: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildModernCategoryInput(
                                      label: "Philcare Staff",
                                      controller: _headcountPhilcareController,
                                      icon: _categoryIcons["Philcare Staff"]!,
                                      readOnly: isSubmissionDisabled,
                                      requiredField: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Row 4
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildModernCategoryInput(
                                      label: "Security Personnel",
                                      controller: _headcountSecurityController,
                                      icon: _categoryIcons["Security Personnel"]!,
                                      readOnly: isSubmissionDisabled,
                                      requiredField: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildModernCategoryInput(
                                      label: "Construction Workers",
                                      controller: _headcountConstructionController,
                                      icon: _categoryIcons["Construction Workers"]!,
                                      readOnly: isSubmissionDisabled,
                                      requiredField: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Row 5
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildModernCategoryInput(
                                      label: "Tenants",
                                      controller: _headcountTenantsController,
                                      icon: _categoryIcons["Tenants"]!,
                                      readOnly: isSubmissionDisabled,
                                      requiredField: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildModernCategoryInput(
                                      label: "Health Workers",
                                      controller: _headcountHealthWorkerController,
                                      icon: _categoryIcons["Health Workers"]!,
                                      readOnly: isSubmissionDisabled,
                                      requiredField: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Row 6
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildModernCategoryInput(
                                      label: "Non-Academic Staff",
                                      controller: _headcountNonAcadStaffController,
                                      icon: _categoryIcons["Non-Academic Staff"]!,
                                      readOnly: isSubmissionDisabled,
                                      requiredField: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildModernCategoryInput(
                                      label: "Guests",
                                      controller: _headcountGuestsController,
                                      icon: _categoryIcons["Guests"]!,
                                      readOnly: isSubmissionDisabled,
                                      requiredField: true,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 36),

                              // Incident Details Section
                              Text(
                                "Incident Details",
                                style: TextStyle(
                                  color: _textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Critical information about the incident",
                                style: TextStyle(
                                  color: _textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Incident Details Grid
                              Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildModernIncidentInput(
                                          label: "Missing Persons",
                                          controller: _numberMissingController,
                                          icon: _missingIcon,
                                          hintText: "0",
                                          isNumber: true,
                                          readOnly: isSubmissionDisabled,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildModernIncidentInput(
                                          label: "Casualties",
                                          controller: _numberCasualtyController,
                                          icon: _casualtyIcon,
                                          hintText: "0",
                                          isNumber: true,
                                          readOnly: isSubmissionDisabled,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  _buildModernIncidentInput(
                                    label: "Names of Missing Persons",
                                    controller: _missingPeopleNamesController,
                                    icon: Icons.person_rounded,
                                    maxLines: 2,
                                    hintText: "Enter names separated by commas (if any)",
                                    readOnly: isSubmissionDisabled,
                                  ),
                                  const SizedBox(height: 20),

                                  _buildModernIncidentInput(
                                    label: "Identity and Condition of Casualties",
                                    controller: _identityConditionController,
                                    icon: Icons.medical_information_rounded,
                                    maxLines: 2,
                                    hintText: "Provide details about casualties (if any)",
                                    readOnly: isSubmissionDisabled,
                                  ),
                                  const SizedBox(height: 20),

                                  _buildModernIncidentInput(
                                    label: "Damage Assessment",
                                    controller: _damageAssessmentController,
                                    icon: _damageIcon,
                                    maxLines: 3,
                                    hintText: "Brief description of damage assessment",
                                    validator: (val) => val == null || val.isEmpty
                                        ? 'Damage assessment is required'
                                        : null,
                                    readOnly: isSubmissionDisabled,
                                  ),
                                  const SizedBox(height: 20),

                                  // Location Field
                                  _buildLocationInput(readOnly: isSubmissionDisabled),
                                ],
                              ),

                              const SizedBox(height: 36),

                              // ── Submit Button ──────────────────────────────
                              Container(
                                height: 58,
                                decoration: BoxDecoration(
                                  gradient: isSubmissionDisabled
                                      ? LinearGradient(
                                          colors: [Colors.grey.withOpacity(0.12), Colors.grey.withOpacity(0.08)],
                                        )
                                      : _emergencyGradient,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isSubmissionDisabled
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: _primaryRed.withOpacity(0.4),
                                            blurRadius: 20,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: isSubmissionDisabled ? null : _onSubmit,
                                    borderRadius: BorderRadius.circular(16),
                                    highlightColor: Colors.white.withOpacity(0.1),
                                    splashColor: Colors.white.withOpacity(0.2),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: isSubmissionDisabled ? Colors.grey.withOpacity(0.18) : Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                _submitIcon,
                                                color: isSubmissionDisabled ? Colors.grey[700] : _white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            widget.existingReport != null ? 'UPDATE INCIDENT REPORT' : 'SUBMIT INCIDENT REPORT',
                                            style: TextStyle(
                                              color: isSubmissionDisabled ? Colors.grey[700] : _white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 36),
                            ],
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}