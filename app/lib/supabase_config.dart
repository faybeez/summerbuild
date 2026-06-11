const supabaseUrl = 'http://192.168.0.101:54321';
const supabasePublishableKey = 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH';

bool get hasSupabaseConfig =>
    !supabaseUrl.startsWith('YOUR_') &&
    !supabasePublishableKey.startsWith('YOUR_');
