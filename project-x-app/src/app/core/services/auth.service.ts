import { Injectable, computed, inject, signal } from '@angular/core';
import type { Session, User } from '@supabase/supabase-js';
import { SupabaseClientService } from './supabase-client.service';
import { Profile, UserRole, UserStatus } from '../models';

// Raw shape returned by the organization_members + profiles join used in loadProfile().
interface MembershipRow {
  id: string;
  organization_id: string;
  team_id: string | null;
  role: UserRole;
  status: UserStatus;
  profiles: {
    id: string;
    full_name: string;
    email: string;
    avatar_url: string | null;
    created_at: string;
    updated_at: string;
  } | null;
}

// Centralizes all Supabase Auth interaction and keeps the current session/profile in sync.
@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly supabaseClientService = inject(SupabaseClientService);
  private readonly supabase = this.supabaseClientService.client;

  private readonly _session = signal<Session | null>(null);
  private readonly _profile = signal<Profile | null>(null);
  private readonly _initialized = signal(false);

  readonly isConfigured = this.supabaseClientService.isConfigured;
  readonly session = this._session.asReadonly();
  readonly profile = this._profile.asReadonly();
  readonly initialized = this._initialized.asReadonly();
  readonly currentUser = computed<User | null>(() => this._session()?.user ?? null);
  readonly isAuthenticated = computed(() => this._session() !== null);

  constructor() {
    if (!this.isConfigured) {
      // No Supabase credentials yet (see NEXT_STEPS.txt) — skip network calls, unblock guards.
      this._initialized.set(true);
      return;
    }

    this.supabase.auth.getSession().then(({ data }) => {
      this._session.set(data.session);
      void this.loadProfile(data.session?.user ?? null).finally(() => this._initialized.set(true));
    });

    this.supabase.auth.onAuthStateChange((_event, session) => {
      this._session.set(session);
      void this.loadProfile(session?.user ?? null);
    });
  }

  private async loadProfile(user: User | null): Promise<void> {
    if (!user) {
      this._profile.set(null);
      return;
    }

    // A user's current organization context comes from organization_members joined with profiles.
    // .limit(1) keeps this working even once a profile can belong to more than one organization.
    const { data, error } = await this.supabase
      .from('organization_members')
      .select('id, organization_id, team_id, role, status, profiles!inner(id, full_name, email, avatar_url, created_at, updated_at)')
      .eq('user_id', user.id)
      .eq('status', 'active')
      .order('created_at', { ascending: true })
      .limit(1)
      .maybeSingle<MembershipRow>();

    if (error) {
      console.error('[AuthService] Failed to load profile', error);
      this._profile.set(null);
      return;
    }

    if (!data || !data.profiles) {
      this._profile.set(null);
      return;
    }

    this._profile.set({
      id: data.profiles.id,
      membership_id: data.id,
      organization_id: data.organization_id,
      team_id: data.team_id,
      full_name: data.profiles.full_name,
      email: data.profiles.email,
      role: data.role,
      status: data.status,
      avatar_url: data.profiles.avatar_url,
      created_at: data.profiles.created_at,
      updated_at: data.profiles.updated_at,
    });
  }

  async refreshProfile(): Promise<void> {
    await this.loadProfile(this.currentUser());
  }

  async signIn(email: string, password: string): Promise<{ error: string | null }> {
    const { error } = await this.supabase.auth.signInWithPassword({ email, password });
    return { error: error?.message ?? null };
  }

  async signOut(): Promise<void> {
    await this.supabase.auth.signOut();
  }

  async requestPasswordReset(email: string): Promise<{ error: string | null }> {
    const { error } = await this.supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`,
    });
    return { error: error?.message ?? null };
  }

  async updatePassword(newPassword: string): Promise<{ error: string | null }> {
    const { error } = await this.supabase.auth.updateUser({ password: newPassword });
    return { error: error?.message ?? null };
  }
}
