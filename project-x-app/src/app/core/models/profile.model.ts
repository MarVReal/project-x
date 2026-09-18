import { UserRole, UserStatus } from './enums';

// Flattened view of the current user's `profiles` row joined with their `organization_members` row
// for the active organization. See supabase/migrations/001_initial_schema.sql for the underlying tables.
export interface Profile {
  id: string;
  membership_id: string;
  organization_id: string;
  team_id: string | null;
  full_name: string;
  email: string;
  role: UserRole;
  status: UserStatus;
  avatar_url: string | null;
  created_at: string;
  updated_at: string;
}
