import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _clusterController.dispose();
    _headcountFacultyController.dispose();
    _headcountAdminController.dispose();
    _headcountREPSController.dispose();
    _headcountRAController.dispose();
    _headcountStudentController.dispose();
    _headcountPhilcareController.dispose();
    _headcountSecurityController.dispose();
    _headcountConstructionController.dispose();
    _headcountTenantsController.dispose();
    _headcountHealthWorkerController.dispose();
    _headcountNonAcadStaffController.dispose();
    _headcountGuestsController.dispose();
    _numberMissingController.dispose();
    _missingPeopleNamesController.dispose();
    _numberCasualtyController.dispose();
    _identityConditionController.dispose();
    _damageAssessmentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Status Report for UPM NSED Q4 2025",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Basic info
              TextInput(
                label: "Full Name",
                controller: _nameController,
                hintText: "Enter your full name",
                validator: (val) =>
                    val == null || val.isEmpty ? 'Full name is required' : null,
              ),
              TextInput(
                label: "Position",
                controller: _positionController,
                hintText: "Enter your position",
                validator: (val) =>
                    val == null || val.isEmpty ? 'Position is required' : null,
              ),
              TextInput(
                label: "Cluster",
                controller: _clusterController,
                hintText: "Enter your cluster or department",
                validator: (val) =>
                    val == null || val.isEmpty ? 'Cluster is required' : null,
              ),

              const SizedBox(height: 20),
              const Text(
                "Headcount Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              NumberInput(
                label: "Faculty Members",
                controller: _headcountFacultyController,
                hintText: "Enter number of faculty members",
                validator: _requiredNumber,
              ),
              NumberInput(
                label: "Admin Members",
                controller: _headcountAdminController,
                hintText: "Enter number of admin members",
                validator: _requiredNumber,
              ),
              NumberInput(
                label: "REPS Members",
                controller: _headcountREPSController,
                hintText: "Enter number of REPS members",
                validator: _requiredNumber,
              ),
              NumberInput(
                label: "RA Members",
                controller: _headcountRAController,
                hintText: "Enter number of RA members",
                validator: _requiredNumber,
              ),
              NumberInput(
                label: "Students",
                controller: _headcountStudentController,
                hintText: "Enter number of students",
                validator: _requiredNumber,
              ),
              NumberInput(
                label: "Philcare Staff",
                controller: _headcountPhilcareController,
                hintText: "Enter number of Philcare staff",
                validator: _requiredNumber,
              ),
              NumberInput(
                label: "Security Personnel",
                controller: _headcountSecurityController,
                hintText: "Enter number of security personnel",
                validator: _requiredNumber,
              ),
              NumberInput(
                label: "Construction Workers",
                controller: _headcountConstructionController,
                hintText: "Enter number of construction workers",
                validator: _requiredNumber,
              ),
              NumberInput(
                label: "Tenants",
                controller: _headcountTenantsController,
                hintText: "Enter number of tenants",
                validator: _requiredNumber,
              ),
              NumberInput(
                label: "Health Workers",
                controller: _headcountHealthWorkerController,
                hintText: "Enter number of health workers",
                validator: _requiredNumber,
              ),
              NumberInput(
                label: "Non-Academic Staff",
                controller: _headcountNonAcadStaffController,
                hintText: "Enter number of non-academic staff",
                validator: _requiredNumber,
              ),
              NumberInput(
                label: "Guests",
                controller: _headcountGuestsController,
                hintText: "Enter number of guests",
                validator: _requiredNumber,
              ),

              const SizedBox(height: 20),
              const Text(
                "Incident Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              NumberInput(
                label: "Number of Missing Persons",
                controller: _numberMissingController,
                hintText: "Enter number of missing persons",
                validator: _requiredNumber,
              ),
              TextInput(
                label: "Names of Missing Persons",
                controller: _missingPeopleNamesController,
                hintText: "Enter names of missing persons (if any)",
                validator: (val) => null,
              ),
              NumberInput(
                label: "Number of Casualties",
                controller: _numberCasualtyController,
                hintText: "Enter number of casualties",
                validator: _requiredNumber,
              ),
              TextInput(
                label: "Identity and Condition of Casualties",
                controller: _identityConditionController,
                hintText: "Enter details about casualties (if any)",
                validator: (val) => null,
              ),
              TextInput(
                label: "Damage Assessment",
                controller: _damageAssessmentController,
                hintText: "Enter a brief description of damage assessment",
                validator: (val) =>
                    val == null || val.isEmpty ? 'Damage assessment is required' : null,
              ),
              TextInput(
                label: "Location",
                controller: _locationController,
                hintText: "Enter location of the incident",
                validator: (val) =>
                    val == null || val.isEmpty ? 'Location is required' : null,
              ),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if ((_formKey.currentState as FormState).validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Form submitted successfully!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 161, 29, 28),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    "Submit Report",
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
    if (val == null || val.isEmpty) return 'Headcount is required';
    return null;
  }
}
