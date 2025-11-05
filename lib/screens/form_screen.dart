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
  final GlobalKey _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Status Report for UPM NSED Q4 2025", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
                // Full name
              TextInput(label: "Full Name", controller: _nameController ,hintText: "Enter your full name", validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Full name is required';
                }
                return null;
              },),
                // Position
                // Cluster
                // Headcount Faculty
              NumberInput(label: "Headcount of Faculty members", controller: _headcountFacultyController ,hintText: "Enter number of faculty members", validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Headcount is required';
                }
                return null;
              },),
                // Headcount Admin members
              NumberInput(label: "Headcount of Admin members", controller: _headcountAdminController ,hintText: "Enter number of admin members", validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Headcount is required';
                }
                return null;
              },),
                // Headcount REPS members
              NumberInput(label: "Headcount of REPS members", controller: _headcountREPSController ,hintText: "Enter number of REPS members", validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Headcount is required';
                }
                return null;
              },),
                // Headcount RA members
              NumberInput(label: "Headcount of RA members", controller: _headcountRAController, hintText: "Enter number of RA members", validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Headcount is required';
                }
                return null;
              },),
                // Headcount of Students
              NumberInput(label: "Headcount of Students", controller: _headcountStudentController, hintText: "Enter number of Students", validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Headcount is required';
                }
                return null;
              },)
              ],
          ),
        ),
      ),
    );
  }
}