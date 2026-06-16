create table public.style_profiles (
  user_id uuid primary key
    references auth.users(id) on delete cascade,
  experience text,          
  color_group text,   
  fit_preference text,
  vibe_tags text[],
  systems text[],  
  goals text[],    
  raw_quiz jsonb,
  updated_at timestamptz default now()
);

-- Policies

ALTER TABLE public.style_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS style_profiles_crud_own_data ON public.style_profiles;

CREATE POLICY style_profiles_crud_own_data
ON public.style_profiles
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.style_profiles TO authenticated;