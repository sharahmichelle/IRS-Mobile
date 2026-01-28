import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/report_model.dart';
import 'package:upm_drrm_irs_mobile/providers/auth_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/event_totals_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/reports_provider.dart';
import 'package:upm_drrm_irs_mobile/widgets/compact_number_input.dart';
import 'package:upm_drrm_irs_mobile/widgets/number_input.dart';
import 'package:upm_drrm_irs_mobile/widgets/text_input.dart';
import 'package:upm_drrm_irs_mobile/widgets/form_input_row.dart';
import 'package:upm_drrm_irs_mobile/widgets/success_dialog.dart';

class AddReportScreen extends StatefulWidget {
  final Event currentEvent;

  const AddReportScreen({super.key, required this.currentEvent});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _clusterController = TextEditingController();
  final TextEditingController _headcountFacultyController =
      TextEditingController();
  final TextEditingController _headcountAdminController =
      TextEditingController();
  final TextEditingController _headcountREPSController =
      TextEditingController();
  final TextEditingController _headcountRAController = TextEditingController();
  final TextEditingController _headcountStudentController =
      TextEditingController();
  final TextEditingController _headcountPhilcareController =
      TextEditingController();
  final TextEditingController _headcountSecurityController =
      TextEditingController();
  final TextEditingController _headcountConstructionController =
      TextEditingController();
  final TextEditingController _headcountTenantsController =
      TextEditingController();
  final TextEditingController _headcountHealthWorkerController =
      TextEditingController();
  final TextEditingController _headcountNonAcadStaffController =
      TextEditingController();
  final TextEditingController _headcountGuestsController =
      TextEditingController();
  final TextEditingController _numberMissingController =
      TextEditingController();
  final TextEditingController _missingPeopleNamesController =
      TextEditingController();
  final TextEditingController _numberCasualtyController =
      TextEditingController();
  final TextEditingController _identityConditionController =
      TextEditingController();
  final TextEditingController _damageAssessmentController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Location auto-complete variables
  List<String> _locationSuggestions = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _locationFocusNode = FocusNode();

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
    
    _locationFocusNode.addListener(() {
      if (!_locationFocusNode.hasFocus) {
        _onLocationUnfocus();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _locationFocusNode.dispose();
    _removeOverlay();

    // Dispose all controllers
    final controllers = [
      _nameController,
      _positionController,
      _clusterController,
      _headcountFacultyController,
      _headcountAdminController,
      _headcountREPSController,
      _headcountRAController,
      _headcountStudentController,
      _headcountPhilcareController,
      _headcountSecurityController,
      _headcountConstructionController,
      _headcountTenantsController,
      _headcountHealthWorkerController,
      _headcountNonAcadStaffController,
      _headcountGuestsController,
      _numberMissingController,
      _missingPeopleNamesController,
      _numberCasualtyController,
      _identityConditionController,
      _damageAssessmentController,
      _locationController,
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
          ]
          .where(
            (location) => location.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

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
    
    if (_formKey.currentState!.validate()) {
      final String reportId;
      reportId = await context.read<Reports>().addReport(
            Report(
              encoderId: currentUser != null ? currentUser.authId : "unknown",
              reportId: "",
              upSystem: currentUser != null ? currentUser.upCampus : "unknown",
              office: currentUser != null ? currentUser.office : "unknown",
              encoderPosition: _positionController.text,
              headCountFaculty: int.parse(_headcountFacultyController.text),
              headCountadminMember: int.parse(_headcountAdminController.text),
              headCountRepsMember: int.parse(_headcountREPSController.text),
              headCountCustodian: int.parse(_headcountRAController.text),
              headCountStudent: int.parse(_headcountStudentController.text),
              headCountSecurity: int.parse(_headcountSecurityController.text),
              headCountConstructionWorker: int.parse(
                _headcountConstructionController.text,
              ),
              headCountHealthWorker: int.parse(
                _headcountHealthWorkerController.text,
              ),
              headCountGuest: int.parse(_headcountGuestsController.text),
              headCountPatient: 0,
              numMissingPerson: int.parse(_numberMissingController.text),
              numCasualty: int.parse(_numberCasualtyController.text),
            ),
          );

      context.read<EventTotals>().addReportToEventTotal(
        widget.currentEvent.eventID,
        "UP System A",
        reportId,
        {
          "headCountFaculty": int.parse(_headcountFacultyController.text),
          "headCountadminMember": int.parse(_headcountAdminController.text),
          "headCountRepsMember": int.parse(_headcountREPSController.text),
          "headCountCustodian": int.parse(_headcountRAController.text),
          "headCountStudent": int.parse(_headcountStudentController.text),
          "headCountSecurity": int.parse(_headcountSecurityController.text),
          "headCountConstructionWorker": int.parse(
            _headcountConstructionController.text,
          ),
          "headCountHealthWorker": int.parse(
            _headcountHealthWorkerController.text,
          ),
          "headCountGuest": int.parse(_headcountGuestsController.text),
          "numMissingPerson": int.parse(_numberMissingController.text),
          "numCasualty": int.parse(_numberCasualtyController.text),
        },
      );

      _showSuccessDialog();
      Navigator.of(context).pop();
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
          offset: Offset(0, 50),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: _surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              constraints: BoxConstraints(maxHeight: 200),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: _textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textPrimary,
                                  fontWeight: FontWeight.w500,
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
    Future.delayed(Duration(milliseconds: 100), () {
      _removeOverlay();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        onDone: () {
          Navigator.of(context).pop();
          _formKey.currentState!.reset();
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

  Widget _buildCompactNumberInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: SizedBox(
              width: (MediaQuery.of(context).size.width - 80) / 2,
              child: CompactNumberInput(
                label: label,
                controller: controller,
                hintText: "0",
                validator: _requiredNumber,
                icon: icon,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: _textPrimary,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  "Add Incident Report",
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              body: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Header Card with Emergency Styling
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: _headerGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryRed.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.emergency_rounded,
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
                                      widget.currentEvent.eventName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.currentEvent.eventDescription,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
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
                        const SizedBox(height: 24),

                        // Form Content in Card
                        Container(
                          decoration: BoxDecoration(
                            color: _surfaceWhite,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
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
                              children: [
                                // Basic Information Section
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: _emergencyGradient,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: _white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Basic Information",
                                            style: TextStyle(
                                              color: _textPrimary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          Text(
                                            "Your personal and organizational details",
                                            style: TextStyle(
                                              color: _textSecondary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                FormInputRow(
                                  children: [
                                    Expanded(
                                      child: TextInput(
                                        label: "Full Name",
                                        controller: _nameController,
                                        hintText: "Enter your full name",
                                        validator: (val) => val == null || val.isEmpty
                                            ? 'Full name is required'
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                FormInputRow(
                                  children: [
                                    Expanded(
                                      child: TextInput(
                                        label: "Position",
                                        controller: _positionController,
                                        hintText: "Enter your position",
                                        validator: (val) => val == null || val.isEmpty
                                            ? 'Position is required'
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextInput(
                                        label: "Cluster",
                                        controller: _clusterController,
                                        hintText: "Enter your cluster",
                                        validator: (val) => val == null || val.isEmpty
                                            ? 'Cluster is required'
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // Headcount Section
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [_accentBlue, _emergencyBlue],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.people_rounded,
                                          color: _white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Headcount Information",
                                            style: TextStyle(
                                              color: _textPrimary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          Text(
                                            "Number of people in each category",
                                            style: TextStyle(
                                              color: _textSecondary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    _buildCompactNumberInput(
                                      label: "Faculty Members",
                                      controller: _headcountFacultyController,
                                      icon: Icons.school_rounded,
                                    ),
                                    _buildCompactNumberInput(
                                      label: "Admin Members",
                                      controller: _headcountAdminController,
                                      icon: Icons.work_rounded,
                                    ),
                                    _buildCompactNumberInput(
                                      label: "REPS Members",
                                      controller: _headcountREPSController,
                                      icon: Icons.engineering_rounded,
                                    ),
                                    _buildCompactNumberInput(
                                      label: "RA Members",
                                      controller: _headcountRAController,
                                      icon: Icons.science_rounded,
                                    ),
                                    _buildCompactNumberInput(
                                      label: "Students",
                                      controller: _headcountStudentController,
                                      icon: Icons.school_rounded,
                                    ),
                                    _buildCompactNumberInput(
                                      label: "Philcare Staff",
                                      controller: _headcountPhilcareController,
                                      icon: Icons.medical_services_rounded,
                                    ),
                                    _buildCompactNumberInput(
                                      label: "Security Personnel",
                                      controller: _headcountSecurityController,
                                      icon: Icons.security_rounded,
                                    ),
                                    _buildCompactNumberInput(
                                      label: "Construction Workers",
                                      controller: _headcountConstructionController,
                                      icon: Icons.construction_rounded,
                                    ),
                                    _buildCompactNumberInput(
                                      label: "Tenants",
                                      controller: _headcountTenantsController,
                                      icon: Icons.business_rounded,
                                    ),
                                    _buildCompactNumberInput(
                                      label: "Health Workers",
                                      controller: _headcountHealthWorkerController,
                                      icon: Icons.medical_information_rounded,
                                    ),
                                    _buildCompactNumberInput(
                                      label: "Non-Academic Staff",
                                      controller: _headcountNonAcadStaffController,
                                      icon: Icons.work_history_rounded,
                                    ),
                                    _buildCompactNumberInput(
                                      label: "Guests",
                                      controller: _headcountGuestsController,
                                      icon: Icons.person_rounded,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // Incident Details Section
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _warningOrange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _warningOrange.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.warning_amber_rounded,
                                          color: _warningOrange,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Incident Details",
                                            style: TextStyle(
                                              color: _textPrimary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          Text(
                                            "Critical information about the incident",
                                            style: TextStyle(
                                              color: _textSecondary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                FormInputRow(
                                  children: [
                                    Expanded(
                                      child: NumberInput(
                                        label: "Missing Persons",
                                        controller: _numberMissingController,
                                        hintText: "Number of missing",
                                        validator: _requiredNumber,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: NumberInput(
                                        label: "Casualties",
                                        controller: _numberCasualtyController,
                                        hintText: "Number of casualties",
                                        validator: _requiredNumber,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                TextInput(
                                  label: "Names of Missing Persons",
                                  controller: _missingPeopleNamesController,
                                  hintText: "Enter names separated by commas (if any)",
                                  validator: (val) => null,
                                ),
                                const SizedBox(height: 16),

                                TextInput(
                                  label: "Identity and Condition of Casualties",
                                  controller: _identityConditionController,
                                  hintText: "Provide details about casualties (if any)",
                                  validator: (val) => null,
                                ),
                                const SizedBox(height: 16),

                                TextInput(
                                  label: "Damage Assessment",
                                  controller: _damageAssessmentController,
                                  hintText: "Brief description of damage assessment",
                                  validator: (val) => val == null || val.isEmpty
                                      ? 'Damage assessment is required'
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                // Location Field with Auto-complete
                                CompositedTransformTarget(
                                  link: _layerLink,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Location",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _locationController,
                                        focusNode: _locationFocusNode,
                                        onChanged: _updateLocationSuggestions,
                                        onTap: () {
                                          if (_locationController.text.isNotEmpty &&
                                              _locationSuggestions.isNotEmpty) {
                                            _showSuggestionOverlay();
                                          }
                                        },
                                        onTapOutside: (event) {
                                          _onLocationUnfocus();
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Enter location of the incident",
                                          hintStyle: TextStyle(color: _textSecondary),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: _borderColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: _primaryRed,
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.location_on_rounded,
                                            color: _textSecondary,
                                          ),
                                        ),
                                        validator: (val) => val == null || val.isEmpty
                                            ? 'Location is required'
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Submit Button
                        Container(
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
                              onTap: _onSubmit,
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: _white, size: 22),
                                    const SizedBox(width: 12),
                                    Text(
                                      'SUBMIT INCIDENT REPORT',
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
                        const SizedBox(height: 32),
                      ],
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

  Color get _borderColor => const Color(0xFFE2E8F0);
}