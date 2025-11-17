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
    eventIntro:
        "This drill simulates an earthquake scenario for safety preparedness.",
    observations: ["Evacuation successful", "Participants followed protocols"],
    scenario: "Magnitude 6.5 simulated quake",
    factSheet: "Prepared by the Disaster Response Committee",
    incidentCommander: "John Doe",
    liasonOfficer: "Jane Smith",
    publicInformationOfficer: "Maria Cruz",
    safetySecurityOfficer: "Carlos Reyes",
    location: "UP Manila Grounds",
  );

  
  final Color primaryColor = Color.fromARGB(255, 161, 29, 28);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              height: 400,
              child: Card(
                color: Colors.white,
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // ✔ FIXED
                ),
                margin: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.arrow_circle_left_outlined,
                            size: 30,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          "DEMOGRAPHICS",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.arrow_circle_right_outlined,
                            size: 30,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),

                    // ✔ FIX: Give PieChart constraints
                    Expanded(
                      child: PieChartBuilder(
                        eventTotalData: dummyEventTotal,
                        eventData: dummyEvent,
                        isTop3: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
