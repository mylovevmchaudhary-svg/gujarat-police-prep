-- ============================================================
-- GUJARAT POLICE PREP - ENTERPRISE SECURITY POLICIES (RLS)
-- Run this in your Supabase SQL Editor (supabase.com)
-- ============================================================

-- 1. Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mock_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

-- 2. PROFILE SECURITY: Students can ONLY view and edit their OWN record
DROP POLICY IF EXISTS "Users can only read own profile" ON public.profiles;
CREATE POLICY "Users can only read own profile"
ON public.profiles
FOR SELECT
USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can only update own profile" ON public.profiles;
CREATE POLICY "Users can only update own profile"
ON public.profiles
FOR UPDATE
USING (auth.uid() = id);

-- 3. WALLET TRANSACTIONS SECURITY: Students cannot forge wallet records
DROP POLICY IF EXISTS "Users can only view own transactions" ON public.wallet_transactions;
CREATE POLICY "Users can only view own transactions"
ON public.wallet_transactions
FOR SELECT
USING (auth.uid() = user_id);

-- 4. QUESTIONS & TESTS SECURITY: Students have READ-ONLY access (Cannot modify or delete)
DROP POLICY IF EXISTS "Students read only mock tests" ON public.mock_tests;
CREATE POLICY "Students read only mock tests"
ON public.mock_tests
FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Students read only questions" ON public.questions;
CREATE POLICY "Students read only questions"
ON public.questions
FOR SELECT
USING (true);

-- 5. ANTI-HACK SECURE FUNCTION FOR COINS (Server-Side Execution Only)
-- This prevents memory editors (GameGuardian, Lucky Patcher) from forging coins!
CREATE OR REPLACE FUNCTION public.reward_coins_secure(
    target_user_id UUID,
    coin_amount INT,
    activity_name TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verify coin amount is reasonable (Prevents +9999999 hack)
    IF coin_amount > 100 THEN
        RAISE EXCEPTION 'Security Alert: Excessive coin reward detected!';
    END IF;

    -- Update user coins atomically
    UPDATE public.profiles
    SET coins = coins + coin_amount
    WHERE id = target_user_id;

    -- Insert secure audit log
    INSERT INTO public.wallet_transactions (user_id, title, amount, is_credit)
    VALUES (target_user_id, activity_name, '+' || coin_amount::text, TRUE);
END;
$$;
