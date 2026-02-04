-- ============================================================================
-- UPM DRRM-IRS: Insert Events in Supabase
-- ============================================================================
-- Instructions:
-- 1. Run this script in Supabase SQL Editor (Dashboard → SQL Editor → New Query)
-- 2. Replace placeholder values with actual data
-- 3. Ensure dates are in ISO 8601 format (e.g., '2024-01-15T09:00:00Z')
-- 4. For array fields like eventObservations, use PostgreSQL array syntax: '{"item1", "item2"}'
-- ============================================================================

-- ============================================================================
-- INSERT NEW EVENTS
-- ============================================================================

INSERT INTO public.events (
  eventid,
  eventName,
  eventDescription,
  eventIntroduction,
  eventObservations,
  eventScenario,
  factSheet,
  incidentCommander,
  liasonOfficer,
  publicInformationOfficer,
  safetySecurityOfficer,
  status,
  action,
  location,
  category,
  timeStampStart,
  timeStampEnd,
  eventStarted
) VALUES
-- Example Event 1: Earthquake Drill
(
  '550e8400-e29b-41d4-a716-446655440000',
  'Earthquake Emergency Drill 2024',
  'Annual earthquake preparedness drill for all university personnel and students',
  'This drill simulates a major earthquake scenario to test emergency response procedures',
  '{"Building evacuation completed in 3 minutes", "Assembly points reached by 95% of participants"}',
  'Magnitude 7.2 earthquake centered 10km from campus',
  'Expected casualties: 50-100, Duration: 2 hours, Affected buildings: Main Campus',
  'Dr. Maria Santos',
  'Prof. Carlos Reyes',
  'Ms. Anna Cruz',
  'Sgt. Miguel Fernandez',
  'Completed',
  'Review evacuation times, Improve communication protocols',
  'University of the Philippines Manila Campus',
  'Drill',
  '2024-03-15T09:00:00Z',
  '2024-03-15T11:00:00Z',
  true
),

-- Example Event 2: Fire Emergency Training
(
  '550e8400-e29b-41d4-a716-446655440001',
  'Fire Safety Training Session',
  'Monthly fire safety training for faculty and staff',
  'Comprehensive training on fire prevention, evacuation procedures, and firefighting equipment usage',
  '{"All participants demonstrated proper fire extinguisher usage", "Evacuation drill completed successfully"}',
  'Small fire in laboratory building requiring evacuation',
  'Fire type: Chemical, Location: Chemistry Lab, Response time: 5 minutes',
  'Engr. Roberto Diaz',
  'Ms. Elena Torres',
  'Mr. Jose Garcia',
  'Officer Lina Santos',
  'Completed',
  'Schedule quarterly refresher training, Update emergency contact lists',
  'Chemistry Building, UPM',
  'Training',
  '2024-04-10T14:00:00Z',
  '2024-04-10T16:00:00Z',
  true
),

-- Example Event 3: Flood Assessment
(
  '550e8400-e29b-41d4-a716-446655440002',
  'Flood Risk Assessment Meeting',
  'Assessment of campus flood preparedness and infrastructure improvements',
  'Review of recent flood incidents and planning for monsoon season preparedness',
  '{"Low-lying areas identified", "Drainage system inspection completed"}',
  'Heavy monsoon rains causing localized flooding in campus grounds',
  'Affected areas: Parking lot, Garden area, Rainfall: 150mm in 2 hours',
  'Dr. Antonio Morales',
  'Ms. Cristina Lopez',
  'Dr. Ricardo Silva',
  'Lt. Pedro Ramirez',
  'Ongoing',
  'Install additional drainage systems, Create flood evacuation routes',
  'UPM Administration Building',
  'Assessment',
  '2024-05-20T10:00:00Z',
  '2024-05-20T12:00:00Z',
  false
);

-- ============================================================================
-- HELPER: Get all current events to verify
-- ============================================================================
SELECT
  id,
  eventName,
  category,
  status,
  location,
  timeStampStart,
  timeStampEnd,
  incidentCommander
FROM public.events
ORDER BY timeStampStart DESC;

-- ============================================================================
-- OPTIONAL: Update existing event status
-- ============================================================================
-- Uncomment and modify as needed
-- UPDATE public.events
-- SET status = 'Completed', timeStampEnd = '2024-03-15T11:00:00Z'
-- WHERE eventName = 'Earthquake Emergency Drill 2024';

-- ============================================================================
-- OPTIONAL: Delete test events (be careful!)
-- ============================================================================
-- Uncomment and modify as needed
-- DELETE FROM public.events WHERE eventName LIKE '%Test%';
