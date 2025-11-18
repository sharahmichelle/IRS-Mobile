import 'package:flutter/material.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';
import 'package:upm_drrm_irs_mobile/widgets/pie_chart_builder.dart';

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
  final List<String> _chartTypes = ['Demographics', 'Response Data', 'Trend Analysis'];

  final dummyEventTotal = EventTotal(
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
    },
  );

  final dummyEvent = Event(
    eventId: "EVT001",
    timeStampStart: DateTime(2025, 1, 15, 9, 0),
    timeStampEnd: DateTime(2025, 1, 15, 17, 0),
    name: "Earthquake Drill",
    description: "University-wide earthquake preparedness drill.",
    status: "Completed",
    action: "Filed Report",
    category: "Drill",
    eventIntro: "This drill simulates an earthquake scenario for safety preparedness.",
    observations: ["Evacuation successful", "Participants followed protocols"],
    scenario: "Magnitude 6.5 simulated quake",
    factSheet: "Prepared by the Disaster Response Committee",
    incidentCommander: "John Doe",
    liasonOfficer: "Jane Smith",
    publicInformationOfficer: "Maria Cruz",
    safetySecurityOfficer: "Carlos Reyes",
    location: "UP Manila Grounds",
  );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 16),
            
            // Chart Type Selector
            _buildChartTypeSelector(),
            const SizedBox(height: 16),
            
            // Main Chart Card - FIXED: Added Expanded with flex to prevent overflow
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildChartCard(),
              ),
            ),
            
            // Statistics Cards - FIXED: Reduced height and spacing
            const SizedBox(height: 12),
            _buildStatisticsCards(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
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
                  Icons.analytics_rounded,
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
                      "Analytics",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Event statistics and demographics",
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
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          _buildNavigationButton(
            icon: Icons.chevron_left_rounded,
            onPressed: _previousChart,
          ),
          
          // Chart Type Label
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _chartTypes[_currentChartIndex],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                Text(
                  'Chart ${_currentChartIndex + 1} of ${_chartTypes.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Next Button
          _buildNavigationButton(
            icon: Icons.chevron_right_rounded,
            onPressed: _nextChart,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: primaryColor),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
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
      child: Column(
        children: [
          // Card Header - FIXED: Reduced padding and font sizes
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.pie_chart_rounded,
                    color: primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Population Distribution",
                        style: TextStyle(
                          fontSize: 16, // Reduced from 18
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        "Earthquake Drill - ${dummyEvent.timeStampStart.year}",
                        style: TextStyle(
                          fontSize: 12, // Reduced from 14
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 12, color: Colors.green), // Smaller icon
                      const SizedBox(width: 4),
                      Text(
                        "Completed",
                        style: TextStyle(
                          fontSize: 10, // Smaller font
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(height: 1, color: Color(0xFFE2E8F0)),
          
          // Chart Area - FIXED: Added constraints to prevent overflow
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4, // Limit maximum height
              ),
              padding: const EdgeInsets.all(12), // Reduced padding
              child: PieChartBuilder(
                eventTotalData: dummyEventTotal,
                eventData: dummyEvent,
                isTop3: true,
              ),
            ),
          ),
          
          // Chart Footer - FIXED: Reduced padding and font sizes
          Container(
            padding: const EdgeInsets.all(12), // Reduced from 16
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // Changed to spaceAround for better distribution
              children: [
                _buildFooterItem("Participants", "${dummyEventTotal.receivedData}"), // Shorter label
                _buildFooterItem("Response", "${((dummyEventTotal.receivedData / dummyEventTotal.expectedData) * 100).toStringAsFixed(1)}%"), // Shorter label
                _buildFooterItem("Complete", "83%"), // Shorter label
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Added to prevent expansion
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14, // Reduced from 16
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10, // Reduced from 12
            color: textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.people_alt_rounded,
              value: "${dummyEventTotal.totalStudents}",
              label: "Students",
              color: Color(0xFF0EA5E9),
            ),
          ),
          const SizedBox(width: 8), // Reduced spacing
          Expanded(
            child: _buildStatCard(
              icon: Icons.school_rounded,
              value: "${dummyEventTotal.totalFaculty}",
              label: "Faculty",
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 8), // Reduced spacing
          Expanded(
            child: _buildStatCard(
              icon: Icons.medical_services_rounded,
              value: "${dummyEventTotal.totalHealthWorkers}",
              label: "Health",
              color: Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      height: 70, // Reduced height from 80
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12), // Slightly smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8, // Reduced blur
            offset: Offset(0, 2), // Reduced offset
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // Reduced padding
        child: Row(
          children: [
            Container(
              width: 32, // Reduced size
              height: 32, // Reduced size
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8), // Smaller radius
              ),
              child: Icon(icon, size: 16, color: color), // Smaller icon
            ),
            const SizedBox(width: 8), // Reduced spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16, // Reduced from 18
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11, // Reduced from 12
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}