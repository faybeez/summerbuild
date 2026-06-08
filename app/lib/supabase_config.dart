const supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
const supabasePublishableKey = 'YOUR_SUPABASE_PUBLISHABLE_ANON_KEY';

bool get hasSupabaseConfig =>
    !supabaseUrl.startsWith('YOUR_') &&
    !supabasePublishableKey.startsWith('YOUR_');
