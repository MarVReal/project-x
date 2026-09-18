import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceRoleKey) {
  console.warn(
    '[supabaseAdmin] SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY are not set. Server-side Supabase calls will fail until configured — see NEXT_STEPS.txt.'
  );
}

// Service-role client for privileged, server-only operations (e.g. inviting users, writing
// notifications). This key must never be sent to the Angular app or any other client.
export const supabaseAdmin = createClient(supabaseUrl ?? '', supabaseServiceRoleKey ?? '', {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});
