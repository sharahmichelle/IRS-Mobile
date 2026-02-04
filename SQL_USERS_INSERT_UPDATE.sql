-- ============================================================================
-- UPM DRRM-IRS: Insert/Update Users in Supabase
-- ============================================================================
-- Instructions:
-- 1. Get auth user IDs from Supabase Dashboard → Authentication → Users
--    (copy the user's UUID id)
-- 2. Replace '<AUTH_ID_UUID_HERE>' with actual auth user IDs
-- 3. Run this script in Supabase SQL Editor (Dashboard → SQL Editor → New Query)
-- 4. After running, sign out and sign in to reload profile data in the app
-- ============================================================================

-- ============================================================================
-- OPTION A: INSERT NEW USERS (use if user row doesn't exist yet)
-- ============================================================================

INSERT INTO public.users (
  username, firstname, middlename, lastname, suffix,
  email, authid, cluster, office, bldgname, position, usertype
) VALUES
-- User 1: John M Doe - Encoder
('jdoe', 'John', 'M', 'Doe', '',
 'jdoe@example.com', '<AUTH_ID_UUID_HERE_1>', 'UPM', 'DRRM-H', 'Building A', 'Encoder', 1),

-- User 2: Maria Santos - Supervisor
('msantos', 'Maria', '', 'Santos', '',
 'msantos@example.com', '<AUTH_ID_UUID_HERE_2>', 'UPM', 'DRRM-H', 'Building B', 'Supervisor', 2),

-- User 3: Carlos Cruz - Admin
('ccruz', 'Carlos', 'R', 'Cruz', 'Jr.',
 'ccruz@example.com', '<AUTH_ID_UUID_HERE_3>', 'UPM', 'DRRM-H', '', 'Admin', 3),

-- User 4: Anna Reyes - Encoder
('areyes', 'Anna', 'P', 'Reyes', '',
 'areyes@example.com', '<AUTH_ID_UUID_HERE_4>', 'UPM', 'DRRM-H', 'Building C', 'Encoder', 1),

-- User 5: Miguel Fernandez - Data Analyst
('mfernandez', 'Miguel', '', 'Fernandez', '',
 'mfernandez@example.com', '<AUTH_ID_UUID_HERE_5>', 'UPM', 'DRRM-H', 'Building A', 'Data Analyst', 2)

ON CONFLICT (username) DO NOTHING;  -- Skip if user already exists


-- ============================================================================
-- OPTION B: UPDATE EXISTING USERS (add missing authid)
-- ============================================================================
-- Uncomment and use these if users already exist but authid is NULL/empty

-- UPDATE public.users SET authid = '<AUTH_ID_UUID_HERE_1>' WHERE username = 'jdoe';
-- UPDATE public.users SET authid = '<AUTH_ID_UUID_HERE_2>' WHERE username = 'msantos';
-- UPDATE public.users SET authid = '<AUTH_ID_UUID_HERE_3>' WHERE username = 'ccruz';
-- UPDATE public.users SET authid = '<AUTH_ID_UUID_HERE_4>' WHERE username = 'areyes';
-- UPDATE public.users SET authid = '<AUTH_ID_UUID_HERE_5>' WHERE username = 'mfernandez';


-- ============================================================================
-- HELPER: Get all current users to verify
-- ============================================================================
SELECT username, firstname, lastname, email, authid, position, usertype 
FROM public.users 
ORDER BY username;


-- ============================================================================
-- HELPER: Get auth user IDs to copy into the script above
-- ============================================================================
-- Run this query in a separate SQL tab to see all auth users and their IDs
-- SELECT id, email FROM auth.users ORDER BY email;

