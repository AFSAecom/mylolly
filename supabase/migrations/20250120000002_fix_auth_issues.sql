-- Fix authentication issues and disable email confirmation for development

-- Update existing users to mark emails as confirmed
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- Create a function to automatically confirm emails for new users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $
BEGIN
  -- Automatically confirm email for new users in development
  UPDATE auth.users 
  SET email_confirmed_at = NOW()
  WHERE id = NEW.id AND email_confirmed_at IS NULL;
  
  RETURN NEW;
END;
$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a function to handle user role assignment
CREATE OR REPLACE FUNCTION public.handle_user_role_assignment()
RETURNS TRIGGER AS $
BEGIN
  -- Ensure role is properly set and not overridden
  IF NEW.role IS NULL THEN
    NEW.role := 'client';
  END IF;
  
  -- Generate appropriate code_client if not set
  IF NEW.code_client IS NULL THEN
    NEW.code_client := CASE 
      WHEN NEW.role = 'admin' THEN 'ADM' || EXTRACT(EPOCH FROM NOW())::text
      WHEN NEW.role = 'conseillere' THEN 'CNS' || EXTRACT(EPOCH FROM NOW())::text
      ELSE 'C' || EXTRACT(EPOCH FROM NOW())::text
    END;
  END IF;
  
  RETURN NEW;
END;
$ LANGUAGE plpgsql;

-- Create trigger to auto-confirm new users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create trigger to handle role assignment
DROP TRIGGER IF EXISTS on_user_role_assignment ON public.users;
CREATE TRIGGER on_user_role_assignment
  BEFORE INSERT OR UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_user_role_assignment();

-- Ensure RLS is properly configured for users table
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.users;

-- Create policies for users table
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Enable insert for authenticated users only" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Allow service role to manage all users (for admin functions)
CREATE POLICY "Service role can manage all users" ON public.users
  FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_code_client ON public.users(code_client);

-- Enable realtime for users table
ALTER PUBLICATION supabase_realtime ADD TABLE public.users;