-- ============================================================
-- GUJARAT POLICE PREP - COMPLETE SUPABASE REALTIME SCHEMA
-- Run this in your Supabase SQL Editor (https://supabase.com)
-- ============================================================

-- 1. Profiles Table (Students, Coins, Referrals)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
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

-- 3. Questions Table (200 MCQs per test)
CREATE TABLE IF NOT EXISTS public.questions (
    id TEXT PRIMARY KEY,
    test_id TEXT REFERENCES public.mock_tests(id) ON DELETE CASCADE,
    subject TEXT NOT NULL,
    question_text TEXT NOT NULL,
    options JSONB NOT NULL, -- Array of 5 options: ["A...", "B...", "C...", "D...", "E..."]
    correct_option_index INTEGER NOT NULL, -- 0 to 4
    explanation TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Payment / Withdrawal Requests Table (UPI Cashout)
CREATE TABLE IF NOT EXISTS public.withdrawals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    student_name TEXT NOT NULL,
    student_email TEXT NOT NULL,
    coins_deducted INTEGER NOT NULL,
    amount_inr NUMERIC NOT NULL,
    upi_id TEXT NOT NULL,
    status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    admin_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Wallet Audit Log
CREATE TABLE IF NOT EXISTS public.wallet_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    amount TEXT NOT NULL,
    is_credit BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mock_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.withdrawals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;

-- Security Policies
CREATE POLICY "Public Read Mock Tests" ON public.mock_tests FOR SELECT USING (true);
CREATE POLICY "Public Read Questions" ON public.questions FOR SELECT USING (true);
CREATE POLICY "Students view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Students view own withdrawals" ON public.withdrawals FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Students insert withdrawals" ON public.withdrawals FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Enable Supabase Realtime for instant updates
ALTER PUBLICATION supabase_realtime ADD TABLE public.mock_tests;
ALTER PUBLICATION supabase_realtime ADD TABLE public.withdrawals;
ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
