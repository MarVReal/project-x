import { Injectable } from '@angular/core';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { environment } from '../../../environments/environment';

// Single shared Supabase client for the whole app (anon key only — never the service-role key).
@Injectable({ providedIn: 'root' })
export class SupabaseClientService {
  // True once SUPABASE_URL/SUPABASE_ANON_KEY have actually been supplied (see NEXT_STEPS.txt).
  readonly isConfigured = Boolean(environment.supabaseUrl && environment.supabaseAnonKey);

  // Fall back to a syntactically valid placeholder so createClient() never throws when
  // unconfigured — AuthService checks isConfigured before making any real calls.
  readonly client: SupabaseClient = createClient(
    environment.supabaseUrl || 'https://placeholder.supabase.co',
    environment.supabaseAnonKey || 'placeholder-anon-key',
    {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
      },
    }
  );
}
