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