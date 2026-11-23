-- ============================================================
-- GUJARAT POLICE PREP (PSI & CONSTABLE) - COMPLETE SUPABASE SCHEMA
-- Project URL: https://sbujnpiaxyjtjgsszpdn.supabase.co
--
-- INSTRUCTIONS FOR 1-CLICK SETUP:
-- 1. Open your Supabase Dashboard: https://supabase.com/dashboard/project/sbujnpiaxyjtjgsszpdn
-- 2. In the left sidebar, click "SQL Editor"
-- 3. Click "New Query" button
-- 4. Paste this ENTIRE file and click "Run" (Green Button)
-- ============================================================

-- 1. Profiles Table (Students, Coins, Referrals)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    my_referral_code TEXT UNIQUE NOT NULL,
    referred_by TEXT,
    coins INTEGER DEFAULT 50,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Mock Tests Table (Managed by Admin, read by Students)
CREATE TABLE IF NOT EXISTS public.mock_tests (
    id TEXT PRIMARY KEY,
    exam_id TEXT NOT NULL, -- 'constable' or 'psi'
    title TEXT NOT NULL,
    description TEXT,
    is_free BOOLEAN DEFAULT FALSE,
    duration_minutes INTEGER DEFAULT 180,
    total_questions INTEGER DEFAULT 200,
    positive_marks NUMERIC DEFAULT 1.0,
    negative_marks NUMERIC DEFAULT 0.25,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Questions Table (All questions added by Admin or Supabase)
CREATE TABLE IF NOT EXISTS public.questions (
    id TEXT PRIMARY KEY DEFAULT ('q_' || gen_random_uuid()::text),
    test_id TEXT REFERENCES public.mock_tests(id) ON DELETE CASCADE,
    exam_id TEXT DEFAULT 'constable',
    subject TEXT NOT NULL,
    question_text TEXT NOT NULL,
    options JSONB NOT NULL, -- Array: ["Option A", "Option B", "Option C", "Option D", "પ્રયાસ કરેલ નથી"]
    correct_option_index INTEGER NOT NULL, -- 0 to 4
    explanation TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Syllabus Structure Table
CREATE TABLE IF NOT EXISTS public.syllabus (
    id TEXT PRIMARY KEY,
    exam_id TEXT NOT NULL, -- 'constable' or 'psi'
    title TEXT NOT NULL,
    title_gujarati TEXT NOT NULL,
    icon_name TEXT DEFAULT 'gavel',
    total_marks_weightage INTEGER DEFAULT 15,
    topics JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Payment / UPI Withdrawal Requests Table
CREATE TABLE IF NOT EXISTS public.withdrawals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    student_name TEXT NOT NULL,
    student_email TEXT NOT NULL,
    coins_deducted INTEGER NOT NULL,
    amount_inr NUMERIC NOT NULL,
    upi_id TEXT NOT NULL,
    status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    admin_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Wallet Audit Transactions
CREATE TABLE IF NOT EXISTS public.wallet_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    student_email TEXT,
    title TEXT NOT NULL,
    amount TEXT NOT NULL,
    is_credit BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. App Settings Table (Dynamic Social Media Links & Website URL)
CREATE TABLE IF NOT EXISTS public.app_settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Notifications & Alerts Table
CREATE TABLE IF NOT EXISTS public.notifications (
    id TEXT PRIMARY KEY DEFAULT ('notif_' || gen_random_uuid()::text),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'alert', -- 'alert', 'exam', 'test', 'update'
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- SEED INITIAL DATA (Tests with 0 MCQs, Links & Alerts)
-- ============================================================

-- Mock Tests (Initialized with 0 questions - Admin will add MCQs)
INSERT INTO public.mock_tests (id, exam_id, title, description, is_free, duration_minutes, total_questions) VALUES
('constable_1', 'constable', 'કોન્સ્ટેબલ સંપૂર્ણ મોક ટેસ્ટ 01', '🌟 મફત મોક ટેસ્ટ (200 પ્રશ્નો - નવું પેપર પેટર્ન)', true, 180, 200),
('constable_2', 'constable', 'કોન્સ્ટેબલ સંપૂર્ણ મોક ટેસ્ટ 02', '🌟 મફત મોક ટેસ્ટ (ઇતિહાસ, ભૂગોળ, કાયદો વિશેષ)', true, 180, 200),
('constable_3', 'constable', 'કોન્સ્ટેબલ સંપૂર્ણ મોક ટેસ્ટ 03', '🌟 મફત મોક ટેસ્ટ (રીઝનિંગ, ગણિત અને બંધારણ)', true, 180, 200),
('constable_4', 'constable', 'કોન્સ્ટેબલ પ્રીમિયમ મોક ટેસ્ટ 04', '🔒 પ્રીમિયમ ટેસ્ટ (વિડિઓ એડ અથવા 10 કોઈન્સથી અનલોક કરો)', false, 180, 200),
('constable_5', 'constable', 'કોન્સ્ટેબલ પ્રીમિયમ મોક ટેસ્ટ 05', '🔒 પ્રીમિયમ ટેસ્ટ (વિડિઓ એડ અથવા 10 કોઈન્સથી અનલોક કરો)', false, 180, 200),
('psi_1', 'psi', 'PSI પ્રિલિમિનરી મોક ટેસ્ટ 01', '🌟 મફત ટેસ્ટ (જનરલ સ્ટડીઝ, રીઝનિંગ, બંધારણ - 200 ગુણ)', true, 180, 200),
('psi_2', 'psi', 'PSI કાયદો & બંધારણ મોક ટેસ્ટ 02', '🌟 મફત ટેસ્ટ (IPC, CrPC, પુરાવા અને બંધારણ વિશેષ)', true, 180, 200),
('psi_3', 'psi', 'PSI ભાષાકીય & વ્યાકરણ મોક ટેસ્ટ 03', '🌟 મફત ટેસ્ટ (ગુજરાતી ભાષા & વ્યાકરણ વિશેષ)', true, 180, 200),
('psi_4', 'psi', 'PSI પ્રીમિયમ સંપૂર્ણ મોક ટેસ્ટ 04', '🔒 પ્રીમિયમ ટેસ્ટ (વિડિઓ એડ અથવા 10 કોઈન્સથી અનલોક કરો)', false, 180, 200)
ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description;

-- Initial Social Media & Official Website Settings
INSERT INTO public.app_settings (key, value) VALUES
('social_links', '{
    "website": "https://gujaratpoliceprep.in",
    "whatsapp": "https://chat.whatsapp.com/KhakhiPrep2026",
    "telegram": "https://t.me/GujaratPolicePrep",
    "youtube": "https://youtube.com/@GujaratPolicePrep",
    "instagram": "https://instagram.com/gujaratpoliceprep"
}'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- Initial System Notifications
INSERT INTO public.notifications (id, title, message, type) VALUES
('notif_1', '🚨 ગુજરાત પોલીસ કોન્સ્ટેબલ અને PSI પરીક્ષા 2026 અપડેટ', 'સત્તાવાર ભરતી બોર્ડ દ્વારા પરીક્ષાનું નવું માળખું જાહેર કરવામાં આવ્યું છે. તમામ ઉમેદવારોએ સિલેબસ ચેક કરવો.', 'exam'),
('notif_2', '✨ નવી મોક ટેસ્ટ સીરીઝ લાઈવ!', 'નવા 200 ગુણના પેપર મુજબ મોક ટેસ્ટ ઉપલબ્ધ કરવામાં આવી છે. તમારા મિત્રોને રેફર કરો અને ફ્રી કોઈન્સ મેળવો!', 'test'),
('notif_3', '🪙 દૈનિક લોગિન બોનસ મેળવો', 'દરરોજ એપ્લિકેશન ખોલીને 10 ફ્રી કોઈન્સ મેળવો અને પ્રીમિયમ ટેસ્ટ ફ્રીમાં અનલોક કરો.', 'alert')
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- ROW LEVEL SECURITY (RLS) & PUBLIC ACCESS PERMISSIONS
-- ============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mock_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.syllabus ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.withdrawals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Allow Students & Admin apps to seamlessly read and write without auth errors
DROP POLICY IF EXISTS "Public Full Access Mock Tests" ON public.mock_tests;
CREATE POLICY "Public Full Access Mock Tests" ON public.mock_tests FOR ALL USING (true);

DROP POLICY IF EXISTS "Public Full Access Questions" ON public.questions;
CREATE POLICY "Public Full Access Questions" ON public.questions FOR ALL USING (true);

DROP POLICY IF EXISTS "Public Full Access Syllabus" ON public.syllabus;
CREATE POLICY "Public Full Access Syllabus" ON public.syllabus FOR ALL USING (true);

DROP POLICY IF EXISTS "Public Full Access Settings" ON public.app_settings;
CREATE POLICY "Public Full Access Settings" ON public.app_settings FOR ALL USING (true);

DROP POLICY IF EXISTS "Public Full Access Notifications" ON public.notifications;
CREATE POLICY "Public Full Access Notifications" ON public.notifications FOR ALL USING (true);

DROP POLICY IF EXISTS "Public Full Access Withdrawals" ON public.withdrawals;
CREATE POLICY "Public Full Access Withdrawals" ON public.withdrawals FOR ALL USING (true);

DROP POLICY IF EXISTS "Public Full Access Profiles" ON public.profiles;
CREATE POLICY "Public Full Access Profiles" ON public.profiles FOR ALL USING (true);

DROP POLICY IF EXISTS "Public Full Access Wallet" ON public.wallet_transactions;
CREATE POLICY "Public Full Access Wallet" ON public.wallet_transactions FOR ALL USING (true);

-- Enable Supabase Realtime Publication for instant live sync across devices
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.mock_tests;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.questions;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.app_settings;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.withdrawals;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
