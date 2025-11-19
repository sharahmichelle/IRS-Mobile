import 'package:flutter/material.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';
import 'package:upm_drrm_irs_mobile/widgets/chart_card.dart';
import 'package:upm_drrm_irs_mobile/widgets/chart_type_selector.dart';
import 'package:upm_drrm_irs_mobile/widgets/event_selector.dart';
import 'package:upm_drrm_irs_mobile/widgets/screen_header.dart';
import 'package:upm_drrm_irs_mobile/widgets/statistics_card.dart';

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  // Modern color scheme
  final Color primaryColor = Color(0xFFA11D1C);
  final Color backgroundColor = Color(0xFFF8FAFC);
  final Color surfaceColor = Colors.white;
  final Color textPrimary = Color(0xFF1E293B);
  final Color textSecondary = Color(0xFF64748B);
  final Color accentColor = Color(0xFF0EA5E9);

  int _currentChartIndex = 0;
  int _currentEventIndex = 0;
  final List<String> _chartTypes = [
    'Demographics',
    'Response Data',
    'Trend Analysis',
  ];

  // Comprehensive Dummy Events Data
  final List<Event> dummyEvents = [
    Event(
      eventId: "EVT001",
      timeStampStart: DateTime(2025, 1, 15, 9, 0),
      timeStampEnd: DateTime(2025, 1, 15, 17, 0),
      name: "Earthquake Drill",
      description:
          "University-wide earthquake preparedness drill focusing on structural safety and evacuation procedures.",
      status: "Completed",
      action: "Filed Report",
      category: "Drill",
      eventIntro:
          "This drill simulates an earthquake scenario for safety preparedness and emergency response training.",
      observations: [
        "Evacuation completed in 8 minutes",
        "98% participation rate from academic departments",
        "Communication systems functioned properly",
      ],
      scenario: "Magnitude 6.5 simulated quake with multiple aftershocks",
      factSheet:
          "Prepared by the Disaster Response Committee in coordination with local emergency services",
      incidentCommander: "Dr. Maria Santos",
      liasonOfficer: "Prof. James Rodriguez",
      publicInformationOfficer: "Ms. Anna Lopez",
      safetySecurityOfficer: "Mr. Carlos Reyes",
      location: "UP Manila Main Campus Grounds",
    ),
    Event(
      eventId: "EVT002",
      timeStampStart: DateTime(2025, 2, 20, 8, 30),
      timeStampEnd: DateTime(2025, 2, 20, 16, 0),
      name: "Fire Safety Training",
      description:
          "Comprehensive fire safety and prevention training with live demonstrations.",
      status: "Completed",
      action: "Report Generated",
      category: "Training",
      eventIntro:
          "Hands-on fire safety training including fire extinguisher usage and evacuation protocols.",
      observations: [
        "All participants practiced with fire extinguishers",
        "Evacuation routes clearly marked and followed",
        "Emergency exits unobstructed",
      ],
      scenario:
          "Multi-story building fire simulation with smoke and heat elements",
      factSheet: "Conducted in partnership with Manila Fire Department",
      incidentCommander: "Engr. Robert Tan",
      liasonOfficer: "Ms. Sarah Lim",
      publicInformationOfficer: "Mr. Michael Chen",
      safetySecurityOfficer: "Officer Mark Dela Cruz",
      location: "UP Manila Engineering Building",
    ),
    Event(
      eventId: "EVT003",
      timeStampStart: DateTime(2025, 3, 10, 10, 0),
      timeStampEnd: DateTime(2025, 3, 10, 15, 30),
      name: "Flood Preparedness Seminar",
      description:
          "Educational seminar on flood risks and emergency response during monsoon season.",
      status: "Ongoing",
      action: "Monitoring",
      category: "Seminar",
      eventIntro:
          "Focus on flood preparedness, early warning systems, and community response coordination.",
      observations: [
        "High attendance from coastal community representatives",
        "Interactive Q&A session generated valuable insights",
        "Resource materials distributed to all participants",
      ],
      scenario: "Simulated heavy monsoon rainfall and rising water levels",
      factSheet: "Developed with PAGASA and MMDA collaboration",
      incidentCommander: "Dr. Elena Cruz",
      liasonOfficer: "Prof. David Martinez",
      publicInformationOfficer: "Ms. Patricia Garcia",
      safetySecurityOfficer: "Mr. Antonio Silva",
      location: "UP Manila Conference Hall A",
    ),
    Event(
      eventId: "EVT004",
      timeStampStart: DateTime(2025, 4, 5, 7, 0),
      timeStampEnd: DateTime(2025, 4, 5, 19, 0),
      name: "Medical Emergency Response Drill",
      description:
          "Full-scale medical emergency simulation with triage and first aid components.",
      status: "Completed",
      action: "Evaluation Pending",
      category: "Medical Drill",
      eventIntro:
          "Comprehensive medical emergency response testing hospital and field capabilities.",
      observations: [
        "Triage system implemented efficiently",
        "Medical supplies adequately stocked",
        "Coordination between departments effective",
      ],
      scenario: "Mass casualty incident with varying injury severity levels",
      factSheet: "Approved by Department of Health and Red Cross",
      incidentCommander: "Dr. Susan Ngo",
      liasonOfficer: "Dr. William Ong",
      publicInformationOfficer: "Ms. Jennifer Wong",
      safetySecurityOfficer: "Mr. Ricardo Santos",
      location: "UP Manila Medical Center & Surrounding Areas",
    ),
    Event(
      eventId: "EVT005",
      timeStampStart: DateTime(2025, 5, 12, 9, 0),
      timeStampEnd: DateTime(2025, 5, 12, 13, 0),
      name: "Cyclone Preparedness Workshop",
      description:
          "Workshop focusing on cyclone risks, shelter management, and post-storm assessment.",
      status: "Upcoming",
      action: "Planning Phase",
      category: "Workshop",
      eventIntro:
          "Interactive workshop for cyclone preparedness and community resilience building.",
      observations: [
        "Community leaders actively participating",
        "Emergency shelter locations identified",
        "Communication protocols established",
      ],
      scenario: "Category 3 cyclone approaching metropolitan area",
      factSheet: "Based on latest PAGASA cyclone tracking data",
      incidentCommander: "Prof. Amanda Reyes",
      liasonOfficer: "Mr. Henry Tan",
      publicInformationOfficer: "Ms. Christine Lim",
      safetySecurityOfficer: "Officer Maria Gonzales",
      location: "UP Manila Disaster Response Center",
    ),
  ];

  final List<EventTotal> dummyEventTotals = [
    EventTotal(
      eventId: "EVT001",
      timeStampStart: DateTime(2025, 1, 15),
      timeStampEnd: DateTime(2025, 1, 16),
      expectedData: 300,
      receivedData: 250,
      isActual: true,
      reportsId: ["RPT001", "RPT002", "RPT003"],
      totalFaculty: 40,
      totalAdminMembers: 30,
      totalRepsMembers: 20,
      totalCustodians: 15,
      totalJoCosMembers: 10,
      totalStudents: 120,
      totalSecurity: 12,
      totalConstructionWorkers: 8,
      totalHealthWorkers: 20,
      totalGuests: 25,
      totalPatients: 18,
      totalMissingPersons: 2,
      totalCasualties: 1,
      totalDistribution: {
        "Faculty": 40,
        "Admin Members": 30,
        "Reps": 20,
        "Students": 120,
        "Guests": 25,
        "Health Workers": 20,
        "Security": 12,
      },
    ),
    EventTotal(
      eventId: "EVT002",
      timeStampStart: DateTime(2025, 2, 20),
      timeStampEnd: DateTime(2025, 2, 20),
      expectedData: 200,
      receivedData: 180,
      isActual: true,
      reportsId: ["RPT004", "RPT005"],
      totalFaculty: 35,
      totalAdminMembers: 25,
      totalRepsMembers: 15,
      totalCustodians: 10,
      totalJoCosMembers: 8,
      totalStudents: 80,
      totalSecurity: 8,
      totalConstructionWorkers: 5,
      totalHealthWorkers: 15,
      totalGuests: 20,
      totalPatients: 12,
      totalMissingPersons: 0,
      totalCasualties: 0,
      totalDistribution: {
        "Faculty": 35,
        "Admin Members": 25,
        "Reps": 15,
        "Students": 80,
        "Guests": 20,
        "Health Workers": 15,
        "Security": 8,
      },
    ),
    EventTotal(
      eventId: "EVT003",
      timeStampStart: DateTime(2025, 3, 10),
      timeStampEnd: DateTime(2025, 3, 10),
      expectedData: 150,
      receivedData: 135,
      isActual: true,
      reportsId: ["RPT006", "RPT007", "RPT008"],
      totalFaculty: 25,
      totalAdminMembers: 20,
      totalRepsMembers: 12,
      totalCustodians: 8,
      totalJoCosMembers: 6,
      totalStudents: 50,
      totalSecurity: 6,
      totalConstructionWorkers: 4,
      totalHealthWorkers: 10,
      totalGuests: 15,
      totalPatients: 8,
      totalMissingPersons: 0,
      totalCasualties: 0,
      totalDistribution: {
        "Faculty": 25,
        "Admin Members": 20,
        "Reps": 12,
        "Students": 50,
        "Guests": 15,
        "Health Workers": 10,
        "Security": 6,
      },
    ),
    EventTotal(
      eventId: "EVT004",
      timeStampStart: DateTime(2025, 4, 5),
      timeStampEnd: DateTime(2025, 4, 5),
      expectedData: 400,
      receivedData: 380,
      isActual: true,
      reportsId: ["RPT009", "RPT010", "RPT011", "RPT012"],
      totalFaculty: 50,
      totalAdminMembers: 35,
      totalRepsMembers: 25,
      totalCustodians: 18,
      totalJoCosMembers: 12,
      totalStudents: 150,
      totalSecurity: 15,
      totalConstructionWorkers: 10,
      totalHealthWorkers: 35,
      totalGuests: 30,
      totalPatients: 25,
      totalMissingPersons: 1,
      totalCasualties: 0,
      totalDistribution: {
        "Faculty": 50,
        "Admin Members": 35,
        "Reps": 25,
        "Students": 150,
        "Guests": 30,
        "Health Workers": 35,
        "Security": 15,
        "Patients": 25,
      },
    ),
    EventTotal(
      eventId: "EVT005",
      timeStampStart: DateTime(2025, 5, 12),
      timeStampEnd: DateTime(2025, 5, 12),
      expectedData: 120,
      receivedData: 0, // Upcoming event, no data yet
      isActual: false,
      reportsId: [],
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
      totalDistribution: {},
    ),
  ];

  Event get currentEvent => dummyEvents[_currentEventIndex];
  EventTotal get currentEventTotal => dummyEventTotals[_currentEventIndex];

  void _nextChart() {
    setState(() {
      _currentChartIndex = (_currentChartIndex + 1) % _chartTypes.length;
    });
  }

  void _previousChart() {
    setState(() {
      _currentChartIndex = (_currentChartIndex - 1) % _chartTypes.length;
      if (_currentChartIndex < 0) _currentChartIndex = _chartTypes.length - 1;
    });
  }

  void _nextEvent() {
    setState(() {
      _currentEventIndex = (_currentEventIndex + 1) % dummyEvents.length;
    });
  }

  void _previousEvent() {
    setState(() {
      _currentEventIndex = (_currentEventIndex - 1) % dummyEvents.length;
      if (_currentEventIndex < 0) _currentEventIndex = dummyEvents.length - 1;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'ongoing':
        return Colors.orange;
      case 'upcoming':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            ScreenHeader(
              primaryColor: primaryColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              title: "Event Analytics",
              subtitle: "Compare statistics across different events",
              icon: Icons.analytics_rounded,
            ),
            const SizedBox(height: 12),

            // Event Selector
            EventSelector(
              currentEvent: currentEvent,
              onPrevious: _previousEvent,
              onNext: _nextEvent,
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 8),

            // Chart Type Selector
            ChartTypeSelector(
              currentChartType: _chartTypes[_currentChartIndex],
              currentEventIndex: _currentEventIndex,
              totalEvents: dummyEvents.length,
              onPrevious: _previousChart,
              onNext: _nextChart,
              surfaceColor: surfaceColor,
              primaryColor: primaryColor,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 12),

            // Main Chart Card
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ChartCard(
                  currentEvent: currentEvent,
                  currentEventTotal: currentEventTotal,
                  surfaceColor: surfaceColor,
                  primaryColor: primaryColor,
                  backgroundColor: backgroundColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  getStatusColor: _getStatusColor,
                ),
              ),
            ),

            // Statistics Cards
            const SizedBox(height: 12),
            StatisticsCards(
              currentEventTotal: currentEventTotal,
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}