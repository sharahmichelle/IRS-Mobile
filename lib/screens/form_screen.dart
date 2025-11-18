import 'package:flutter/material.dart';
import 'package:upm_drrm_irs_mobile/widgets/compact_number_input.dart';
import 'package:upm_drrm_irs_mobile/widgets/number_input.dart';
import 'package:upm_drrm_irs_mobile/widgets/text_input.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
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

  // Modern color scheme
  final Color primaryColor = Color(0xFFA11D1C);
  final Color backgroundColor = Color(0xFFF8FAFC);
  final Color surfaceColor = Colors.white;
  final Color textPrimary = Color(0xFF1E293B);
  final Color textSecondary = Color(0xFF64748B);
  final Color borderColor = Color(0xFFE2E8F0);

  @override
  void dispose() {
    // Dispose all controllers
    final controllers = [
      _nameController, _positionController, _clusterController,
      _headcountFacultyController, _headcountAdminController, _headcountREPSController,
      _headcountRAController, _headcountStudentController, _headcountPhilcareController,
      _headcountSecurityController, _headcountConstructionController, _headcountTenantsController,
      _headcountHealthWorkerController, _headcountNonAcadStaffController, _headcountGuestsController,
      _numberMissingController, _missingPeopleNamesController, _numberCasualtyController,
      _identityConditionController, _damageAssessmentController, _locationController,
    ];
    
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
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
                  _buildHeader(),
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
                          _buildSectionHeader(
                            icon: Icons.person_outline_rounded,
                            title: "Basic Information",
                            subtitle: "Your personal and organizational details",
                          ),
                          const SizedBox(height: 20),

                          _buildInputRow(
                            children: [
                              Expanded(
                                child: TextInput(
                                  label: "Full Name",
                                  controller: _nameController,
                                  hintText: "Enter your full name",
                                  validator: (val) =>
                                      val == null || val.isEmpty ? 'Full name is required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildInputRow(
                            children: [
                              Expanded(
                                child: TextInput(
                                  label: "Position",
                                  controller: _positionController,
                                  hintText: "Enter your position",
                                  validator: (val) =>
                                      val == null || val.isEmpty ? 'Position is required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextInput(
                                  label: "Cluster",
                                  controller: _clusterController,
                                  hintText: "Enter your cluster",
                                  validator: (val) =>
                                      val == null || val.isEmpty ? 'Cluster is required' : null,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Headcount Section
                          _buildSectionHeader(
                            icon: Icons.people_outline_rounded,
                            title: "Headcount Information",
                            subtitle: "Number of people in each category",
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
                          _buildSectionHeader(
                            icon: Icons.warning_amber_rounded,
                            title: "Incident Details",
                            subtitle: "Critical information about the incident",
                          ),
                          const SizedBox(height: 20),

                          _buildInputRow(
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
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Damage assessment is required' : null,
                          ),
                          const SizedBox(height: 16),

                          TextInput(
                            label: "Location",
                            controller: _locationController,
                            hintText: "Exact location of the incident",
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Location is required' : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              ),
              child: Icon(
                Icons.assignment_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Status Report",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    "UPM NSED Q4 2025",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, Color(0xFFC62828)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputRow({required List<Widget> children}) {
    return Row(
      children: children,
    );
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

  Widget _buildSubmitButton() {
    return Center(
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, Color(0xFFC62828)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _showSuccessDialog();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                "Submit Report",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
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
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Report Submitted!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your status report has been successfully submitted.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Optionally clear form
                    _formKey.currentState!.reset();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  String? _requiredNumber(String? val) {
    if (val == null || val.isEmpty) return 'This field is required';
    final number = int.tryParse(val);
    if (number == null || number < 0) return 'Enter a valid number';
    return null;
  }
}