-- ============================================================
-- GUJARAT POLICE PREP - SUPABASE DATABASE SCHEMA
-- Run this script in your Supabase SQL Editor (supabase.com)
-- ============================================================

-- 1. Profiles Table (Stores Students, Coins, Referral Codes)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    my_referral_code TEXT UNIQUE NOT NULL,
    referred_by TEXT,
    coins INTEGER DEFAULT 30,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Mock Tests Table
CREATE TABLE IF NOT EXISTS public.mock_tests (
    id TEXT PRIMARY KEY,
    exam_id TEXT NOT NULL, -- 'constable' or 'psi'
    title TEXT NOT NULL,
    description TEXT,
    is_free BOOLEAN DEFAULT FALSE,
    duration_minutes INTEGER DEFAULT 180,
    positive_marks NUMERIC DEFAULT 1.0,
    negative_marks NUMERIC DEFAULT 0.25,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Questions Table
CREATE TABLE IF NOT EXISTS public.questions (
    id TEXT PRIMARY KEY,
    test_id TEXT REFERENCES public.mock_tests(id) ON DELETE CASCADE,
    subject TEXT NOT NULL,
    question_text TEXT NOT NULL,
    options JSONB NOT NULL, -- Array of 5 strings: ["A...", "B...", "C...", "D...", "E..."]
    correct_option_index INTEGER NOT NULL, -- 0 to 4
    explanation TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Wallet Transactions Table
CREATE TABLE IF NOT EXISTS public.wallet_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    amount TEXT NOT NULL,
    is_credit BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Announcements / Notifications Table
CREATE TABLE IF NOT EXISTS public.announcements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mock_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

-- Allow Public Read for Mock Tests & Questions
CREATE POLICY "Public Read Mock Tests" ON public.mock_tests FOR SELECT USING (true);
CREATE POLICY "Public Read Questions" ON public.questions FOR SELECT USING (true);
CREATE POLICY "Public Read Announcements" ON public.announcements FOR SELECT USING (true);
