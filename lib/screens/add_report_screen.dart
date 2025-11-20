import 'package:flutter/material.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/widgets/compact_number_input.dart';
import 'package:upm_drrm_irs_mobile/widgets/number_input.dart';
import 'package:upm_drrm_irs_mobile/widgets/text_input.dart';
import 'package:upm_drrm_irs_mobile/widgets/screen_header.dart';
import 'package:upm_drrm_irs_mobile/widgets/form_section_header.dart';
import 'package:upm_drrm_irs_mobile/widgets/form_input_row.dart';
import 'package:upm_drrm_irs_mobile/widgets/form_submit_button.dart';
import 'package:upm_drrm_irs_mobile/widgets/success_dialog.dart';

class AddReportScreen extends StatefulWidget {
  final Event currentEvent;

  const AddReportScreen({super.key, required this.currentEvent});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
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

  // Modern color scheme
  final Color primaryColor = Color(0xFFA11D1C);
  final Color backgroundColor = Color(0xFFF8FAFC);
  final Color surfaceColor = Colors.white;
  final Color textPrimary = Color(0xFF1E293B);
  final Color textSecondary = Color(0xFF64748B);
  final Color borderColor = Color(0xFFE2E8F0);

  // Location auto-complete variables
  List<String> _locationSuggestions = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _locationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize any required data
  }

  @override
  void dispose() {
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
      ].where((location) =>
          location.toLowerCase().contains(query.toLowerCase()),
        ).toList();

      setState(() {
        _locationSuggestions = localSuggestions;
      });

      _showSuggestionOverlay();
    } else {
      _removeOverlay();
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
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
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
                  return ListTile(
                    title: Text(
                      suggestion,
                      style: TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      _locationController.text = suggestion;
                      _removeOverlay();
                      _locationFocusNode.unfocus();
                    },
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
        primaryColor: primaryColor,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
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
    return Container(
      width: (MediaQuery.of(context).size.width - 80) / 2,
      child: CompactNumberInput(
        label: label,
        controller: controller,
        hintText: "0",
        validator: _requiredNumber,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: textPrimary,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Add Status Report",
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  ScreenHeader(
                    primaryColor: primaryColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    title: widget.currentEvent.name,
                    subtitle: widget.currentEvent.description,
                    icon: Icons.assignment_rounded,
                  ),
                  const SizedBox(height: 24),

                  // Form Content in Card
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Basic Information Section
                          FormSectionHeader(
                            icon: Icons.person_outline_rounded,
                            title: "Basic Information",
                            subtitle: "Your personal and organizational details",
                            primaryColor: primaryColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                          const SizedBox(height: 20),

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
                          FormSectionHeader(
                            icon: Icons.people_outline_rounded,
                            title: "Headcount Information",
                            subtitle: "Number of people in each category",
                            primaryColor: primaryColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                          const SizedBox(height: 20),

                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _buildCompactNumberInput(
                                label: "Faculty Members",
                                controller: _headcountFacultyController,
                                icon: Icons.school_outlined,
                              ),
                              _buildCompactNumberInput(
                                label: "Admin Members",
                                controller: _headcountAdminController,
                                icon: Icons.work_outline,
                              ),
                              _buildCompactNumberInput(
                                label: "REPS Members",
                                controller: _headcountREPSController,
                                icon: Icons.engineering_outlined,
                              ),
                              _buildCompactNumberInput(
                                label: "RA Members",
                                controller: _headcountRAController,
                                icon: Icons.science_outlined,
                              ),
                              _buildCompactNumberInput(
                                label: "Students",
                                controller: _headcountStudentController,
                                icon: Icons.school_outlined,
                              ),
                              _buildCompactNumberInput(
                                label: "Philcare Staff",
                                controller: _headcountPhilcareController,
                                icon: Icons.medical_services_outlined,
                              ),
                              _buildCompactNumberInput(
                                label: "Security Personnel",
                                controller: _headcountSecurityController,
                                icon: Icons.security_outlined,
                              ),
                              _buildCompactNumberInput(
                                label: "Construction Workers",
                                controller: _headcountConstructionController,
                                icon: Icons.construction_outlined,
                              ),
                              _buildCompactNumberInput(
                                label: "Tenants",
                                controller: _headcountTenantsController,
                                icon: Icons.business_outlined,
                              ),
                              _buildCompactNumberInput(
                                label: "Health Workers",
                                controller: _headcountHealthWorkerController,
                                icon: Icons.medical_information_outlined,
                              ),
                              _buildCompactNumberInput(
                                label: "Non-Academic Staff",
                                controller: _headcountNonAcadStaffController,
                                icon: Icons.work_history_outlined,
                              ),
                              _buildCompactNumberInput(
                                label: "Guests",
                                controller: _headcountGuestsController,
                                icon: Icons.person_outline,
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Incident Details Section
                          FormSectionHeader(
                            icon: Icons.warning_amber_rounded,
                            title: "Incident Details",
                            subtitle: "Critical information about the incident",
                            primaryColor: primaryColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
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
                                    color: textPrimary,
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
                                    hintStyle: TextStyle(color: textSecondary),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
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
                  FormSubmitButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showSuccessDialog();
                      }
                    },
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}