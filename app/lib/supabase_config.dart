const supabaseUrl = 'http://10.0.2.2:54321';
const supabasePublishableKey = 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH';

bool get hasSupabaseConfig =>
    !supabaseUrl.startsWith('YOUR_') &&
    !supabasePublishableKey.startsWith('YOUR_');
