import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';
import 'package:upm_drrm_irs_mobile/providers/event_totals_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  // Modern color scheme
  final Color primaryColor = Color(0xFFA11D1C);
  final Color backgroundColor = Color(0xFFF8FAFC);
  final Color surfaceColor = Colors.white;
  final Color textPrimary = Color(0xFF1E293B);
  final Color textSecondary = Color(0xFF64748B);

  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  // New controllers for additional fields
  final _eventIntroController = TextEditingController();
  final _scenarioController = TextEditingController();
  final _factSheetController = TextEditingController();
  final _incidentCommanderController = TextEditingController();
  final _liasonOfficerController = TextEditingController();
  final _actionController = TextEditingController();
  final _publicInformationOfficerController = TextEditingController();
  final _safetySecurityOfficerController = TextEditingController();

  String selectedCategory = "Drill";
  String selectedStatus = "Upcoming";
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<String> categories = ["Drill", "Emergency", "Training", "Meeting", "Assessment"];
  final List<String> statuses = ["Upcoming", "Ongoing", "Completed", "Cancelled"];
  final List<Color> categoryColors = [
    Color(0xFF0EA5E9), // Blue
    Color(0xFFEF4444), // Red
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
  ];

  final List<Color> statusColors = [
    Color(0xFF3B82F6), // Blue
    Color(0xFFF97316), // Orange
    Color(0xFF10B981), // Green
    Color(0xFF6B7280), // Gray
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _eventIntroController.dispose();
    _scenarioController.dispose();
    _factSheetController.dispose();
    _incidentCommanderController.dispose();
    _liasonOfficerController.dispose();
    _actionController.dispose();
    _publicInformationOfficerController.dispose();
    _safetySecurityOfficerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
          // Ensure end date is not before start date
          if (_startDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select both start and end dates'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      DateTime startDateFull = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime?.hour ?? 0,
        _startTime?.minute ?? 0,
      );

      DateTime endDateFull = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime?.hour ?? 0,
        _endTime?.minute ?? 0,
      );

      // First, add the event to Events provider
      final Event newEvent = Event(
        eventId: '', // This will be generated by Firestore
        eventName: _titleController.text,
        eventDescription: _descriptionController.text,
        category: selectedCategory,
        timeStampStart: startDateFull,
        timeStampEnd: endDateFull,
        location: _locationController.text,
        eventIntroduction: _eventIntroController.text,
        eventObservations: [], 
        eventScenario: _scenarioController.text,
        factSheet: _factSheetController.text,
        incidentCommander: _incidentCommanderController.text,
        liasonOfficer: _liasonOfficerController.text,
        status: selectedStatus,
        action: _actionController.text,
        publicInformationOfficer: _publicInformationOfficerController.text,
        safetySecurityOfficer: _safetySecurityOfficerController.text,
      );

      try {
        // Add event and get the generated event ID
        final eventId = await context.read<Events>().addEvent(newEvent);
        
        // Now add the corresponding event total
        // Use read with listen: false since we're in an async callback
        final eventTotalsProvider = context.read<EventTotals>();
        await eventTotalsProvider.addEventTotal(
          EventTotal(
            eventId: eventId, 
            timeStampStart: startDateFull,
            timeStampEnd: endDateFull,
            expectedData: 0,
            receivedData: 0,
            totalFaculty: 0,
            totalAdminMembers: 0,
            totalRepsMembers: 0,
            totalCustodians: 0,
            totalJoCosMembers: 0,
            totalStudents: 0,
            totalSecurity: 0,
            totalConstructionWorkers: 0,
            totalHealthWorkers: 0,
            totalGuests: 0,
            totalPatients: 0,
            totalMissingPersons: 0,
            totalCasualties: 0,
            isActual: false,
            reportsId: [],
            totalDistribution: {},
          )
        );

        // Form is valid, proceed with submission
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back or reset form
        Future.delayed(Duration(seconds: 1), () {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating event: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Create New Event'),
        backgroundColor: surfaceColor,
        elevation: 0,
        foregroundColor: textPrimary,
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: Text(
              'Save',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 32),

                // Event Title
                _buildSectionHeader('Event Title', Icons.title_rounded),
                const SizedBox(height: 12),
                _buildTextFormField(
                  controller: _titleController,
                  hintText: 'Enter event title',
                  validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 24),

                // Event Description
                _buildSectionHeader('Description', Icons.description_rounded),
                const SizedBox(height: 12),
                _buildTextFormField(
                  controller: _descriptionController,
                  hintText: 'Describe the event purpose and details',
                  maxLines: 4,
                  validator: (val) => val == null || val.isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 24),

                // Event Intro
                _buildSectionHeader('Event Introduction', Icons.info_rounded),
                const SizedBox(height: 12),
                _buildTextFormField(
                  controller: _eventIntroController,
                  hintText: 'Enter event introduction and overview',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Scenario
                _buildSectionHeader('Scenario', Icons.assignment_rounded),
                const SizedBox(height: 12),
                _buildTextFormField(
                  controller: _scenarioController,
                  hintText: 'Describe the event scenario',
                  maxLines: 4,
                ),
                const SizedBox(height: 24),

                // Fact Sheet
                _buildSectionHeader('Fact Sheet', Icons.fact_check_rounded),
                const SizedBox(height: 12),
                _buildTextFormField(
                  controller: _factSheetController,
                  hintText: 'Enter key facts and information',
                  maxLines: 4,
                ),
                const SizedBox(height: 24),

                // Event Category
                _buildSectionHeader('Event Category', Icons.category_rounded),
                const SizedBox(height: 12),
                _buildCategorySelector(),
                const SizedBox(height: 24),

                // Date & Time Section
                _buildSectionHeader('Date & Time', Icons.access_time_rounded),
                const SizedBox(height: 12),

                // Start Date & Time
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'Start Date',
                        date: _startDate,
                        onTap: () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeField(
                        label: 'Start Time',
                        time: _startTime,
                        onTap: () => _selectTime(context, true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // End Date & Time
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'End Date',
                        date: _endDate,
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeField(
                        label: 'End Time',
                        time: _endTime,
                        onTap: () => _selectTime(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Location
                _buildSectionHeader('Location', Icons.location_on_rounded),
                const SizedBox(height: 12),
                _buildTextFormField(
                  controller: _locationController,
                  hintText: 'Enter event location',
                  validator: (val) => val == null || val.isEmpty ? 'Location is required' : null,
                ),
                const SizedBox(height: 24),

                // Incident Command Team Section
                _buildSectionHeader('Incident Command Team', Icons.groups_rounded),
                const SizedBox(height: 16),

                // Incident Commander
                _buildPersonnelField(
                  controller: _incidentCommanderController,
                  hintText: 'Enter Incident Commander name',
                  label: 'Incident Commander',
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 16),

                // Liaison Officer
                _buildPersonnelField(
                  controller: _liasonOfficerController,
                  hintText: 'Enter Liaison Officer name',
                  label: 'Liaison Officer',
                  icon: Icons.contact_phone_rounded,
                ),
                const SizedBox(height: 16),

                // Public Information Officer
                _buildPersonnelField(
                  controller: _publicInformationOfficerController,
                  hintText: 'Enter Public Information Officer name',
                  label: 'Public Information Officer',
                  icon: Icons.mic_rounded,
                ),
                const SizedBox(height: 16),

                // Safety Security Officer
                _buildPersonnelField(
                  controller: _safetySecurityOfficerController,
                  hintText: 'Enter Safety Security Officer name',
                  label: 'Safety Security Officer',
                  icon: Icons.security_rounded,
                ),
                const SizedBox(height: 24),

                // Status
                _buildSectionHeader('Current Status', Icons.assessment_rounded),
                const SizedBox(height: 12),
                _buildStatusSelector(),
                const SizedBox(height: 24),

                // Action
                _buildSectionHeader('Actions Required', Icons.playlist_add_check_rounded),
                const SizedBox(height: 12),
                _buildTextFormField(
                  controller: _actionController,
                  hintText: 'Enter required actions and next steps',
                  maxLines: 4,
                ),
                const SizedBox(height: 40),

                // Submit Button
                _buildSubmitButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... (rest of your helper methods remain the same)
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
                Icons.event_rounded,
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
                    "Create Event",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    "Schedule a new event or drill",
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
        const SizedBox(height: 8),
        Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryColor, Color(0xFFC62828)]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: primaryColor),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: textPrimary, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: textSecondary),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }

  Widget _buildPersonnelField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(color: textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: textSecondary),
            filled: true,
            fillColor: surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: Icon(icon, size: 20, color: textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          final color = categoryColors[index];
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(
                category,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
              },
              backgroundColor: surfaceColor,
              selectedColor: color,
              side: BorderSide(color: color),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(statuses.length, (index) {
          final status = statuses[index];
          final isSelected = selectedStatus == status;
          final color = statusColors[index];
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedStatus = status;
                });
              },
              backgroundColor: surfaceColor,
              selectedColor: color,
              side: BorderSide(color: color),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 20, color: textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null 
                        ? '${date.month}/${date.day}/${date.year}'
                        : 'Select date',
                    style: TextStyle(
                      color: date != null ? textPrimary : textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded, size: 20, color: textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    time != null 
                        ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                        : 'Select time',
                    style: TextStyle(
                      color: time != null ? textPrimary : textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Create Event',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}