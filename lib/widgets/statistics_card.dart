// widgets/graphs_screen/statistics_cards.dart
import 'package:flutter/material.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';

class StatisticsCards extends StatelessWidget {
  final EventTotal currentEventTotal;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;

  const StatisticsCards({
    super.key,
    required this.currentEventTotal,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.people_alt_rounded,
              value: "${currentEventTotal.totalStudents}",
              label: "Students",
              color: Color(0xFF0EA5E9),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              icon: Icons.school_rounded,
              value: "${currentEventTotal.totalFaculty}",
              label: "Faculty",
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              icon: Icons.medical_services_rounded,
              value: "${currentEventTotal.totalHealthWorkers}",
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
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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